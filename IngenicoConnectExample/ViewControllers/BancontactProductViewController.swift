//
//  BancontactProductViewController.swift
//  IngenicoConnectExample
//
//  Created for Ingenico ePayments on 08/06/2017.
//  Copyright © 2017 Ingenico. All rights reserved.
//

import UIKit
import IngenicoConnectKit
import CoreImage
class BancontactProductViewController: PaymentProductViewController {
    let qrCodeString: String
    let appRedirectURL: String
    var thirdPartyStatus: ThirdPartyStatus = .Waiting
    let statusViewController: ExternalAppStatusViewController = ExternalAppStatusViewController()
    let paymentId: String
    var polling: Bool = false

    init(
        paymentItem: PaymentItem,
        accountOnFile: AccountOnFile?,
        customServerJSON: [String: Any]
    ) {
        let payment = (customServerJSON["payment"] as? [String: Any])!
        guard let paymentId = (payment["id"]) as? String else {
            fatalError("Could not cast payment['id'] as String")
        }
        self.paymentId = paymentId
        guard let merchantAction = customServerJSON["merchantAction"] as? [String: Any] else {
            fatalError("Could not cast customServerJSON['merchantAction'] as [String: Any]")
        }
        guard let formFields = merchantAction["formFields"] as? [[String: Any]] else {
            fatalError("Could not cast merchantAction['formFields'] as [[String: Any]]")
        }
        paymentItem.fields.paymentProductFields.removeAll()
        for fieldJSON in formFields {
            if let fieldData = try? JSONSerialization.data(withJSONObject: fieldJSON),
               let field = try? JSONDecoder().decode(PaymentProductField.self, from: fieldData) {
                paymentItem.fields.paymentProductFields.append(field)
            }
        }
        guard let showData = merchantAction["showData"] as? [[String: String]] else {
            fatalError("Could not cast merchantAction['showData'] as [[String: String]]")
        }
        self.appRedirectURL = showData.first(where: { (dict) -> Bool in
            return dict["key"]! == "URLINTENT"
        })!["value"]!
        self.qrCodeString = showData.first(where: { (dict) -> Bool in
            return dict["key"]! == "QRCODE"
        })!["value"]!
        super.init(
            paymentItem: paymentItem,
            accountOnFile: accountOnFile
        )
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad {
            self.startPolling()
        }
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch formRows[indexPath.row] {
        case let row as FormRowSmallLogo:
            return LogoTableViewCell.cellSize(width: min(tableView.bounds.size.width, 320), for: row).height
        case let row as FormRowImage:
            return ImageTableViewCell.cellSize(width: min(tableView.bounds.size.width, 320), for: row).height
        default:
            return super.tableView(tableView, heightForRowAt: indexPath)
        }
    }

    override func updateTextFieldCell(cell: TextFieldTableViewCell, row: FormRowTextField) {
        super.updateTextFieldCell(cell: cell, row: row)

        // Add card logo for cardNumber field
        if row.paymentProductField.identifier == "cardNumber" {
            if confirmedPaymentProducts.contains(paymentItem.identifier) {
                let view = UIImageView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
                view.contentMode = .scaleAspectFit
                row.logo = paymentItem.displayHints.logoImage
                view.image = row.logo
                cell.rightView = view
            } else {
                row.logo = nil
                cell.rightView = UIView()
            }
        }
    }
    override func formRowCell(for row: FormRow, indexPath: IndexPath) -> UITableViewCell {
        var cell: TableViewCell?
        if let formRow = row as? FormRowQRCode {
            cell = self.cell(for: formRow, tableView: tableView)
        } else if let formRow = row as? FormRowSmallLogo {
            cell = self.cell(for: formRow, tableView: tableView)
        } else if let formRow = row as? FormRowImage {
            cell = self.cell(for: formRow, tableView: tableView)
        } else if let formRow = row as? FormRowSeparator {
            cell = self.cell(for: formRow, tableView: tableView)
        } else {
            cell = super.formRowCell(for: row, indexPath: indexPath) as? TableViewCell
        }
        return cell!
    }

    override func registerReuseIdentifiers() {
        super.registerReuseIdentifiers()
        tableView.register(ImageTableViewCell.self, forCellReuseIdentifier: ImageTableViewCell.reuseIdentifier)
        tableView.register(SeparatorTableViewCell.self, forCellReuseIdentifier: SeparatorTableViewCell.reuseIdentifier)
        tableView.register(LogoTableViewCell.self, forCellReuseIdentifier: LogoTableViewCell.reuseIdentifier)
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        super.tableView(tableView, didSelectRowAt: indexPath)

        if let row = formRows[indexPath.row] as? PaymentProductsTableRow {
            switchToPaymentProduct(paymentProductId: row.paymentProductIdentifier)
        }

        if formRows[indexPath.row] is FormRowCoBrandsSelection || formRows[indexPath.row] is PaymentProductsTableRow {
            formRows = formRows.map {
                if $0 is FormRowCoBrandsExplanation || $0 is PaymentProductsTableRow {
                    $0.isEnabled = !$0.isEnabled
                }
                return $0
            }
            updateFormRows()
        }
    }

    /// Sets up a timer that fires at most once every second
    func startPolling() {
        self.polling = true
        var callback: (() -> Void)! = nil
        callback = {
            self.poll { (_: ThirdPartyStatus) in
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: callback)
            }
        }
        callback()

    }

    /// Receives the status of the Bancontact App from the server,
    /// and changes the current state according to the received data
    ///
    /// - Parameters:
    ///     - callback: Executed if current viewController will not be dismissed.
    ///     - status: The new app status.
    /// - Remark:
    ///    The callback is supposed to run this method after some time on the main thread if regular polling is required
    func poll(execute callback: @escaping (_ status: ThirdPartyStatus) -> Void) {
        // Note:
        let success = { (response: ThirdPartyStatusResponse) -> Void in
            _ = self.formRows.map({ (formRow) -> FormRow in
                return formRow
            })

            let thirdPartyStatus = response.thirdPartyStatus

            guard self.thirdPartyStatus != thirdPartyStatus else {
                if self.thirdPartyStatus != .Completed {
                    callback(self.thirdPartyStatus)
                }
                return
            }
            self.thirdPartyStatus = thirdPartyStatus
            switch thirdPartyStatus {
            case .Waiting:
                callback(thirdPartyStatus)
            case .Initialized:
                self.present(self.statusViewController, animated: true) {
                    self.statusViewController.externalAppStatus = .Initialized
                    callback(thirdPartyStatus)
                }
            case .Authorized:
                self.statusViewController.externalAppStatus = .Authorized
                callback(thirdPartyStatus)
            case .Completed:
                self.statusViewController.externalAppStatus = .Completed
                self.statusViewController.dismiss(animated: true) {
                    guard let paymentItem = self.paymentItem as? PaymentProduct else {
                        fatalError("Could not cast paymentItem to PaymentProduct")
                    }
                    // Don't run callback, because this is the last time we poll
                    self.paymentRequestTarget?.didSubmitPaymentRequest(
                        paymentRequest: PaymentRequest(
                            paymentProduct: paymentItem,
                            accountOnFile: self.accountOnFile,
                            tokenize: self.inputData.tokenize
                        )
                    )
                }
            }
        }

        ConnectSDK.clientApi.thirdPartyStatus(
            forPayment: self.paymentId,
            success: success,
            failure: { error in
                Macros.DLog(message: error.localizedDescription)
            },
            apiFailure: { errorResponse in
                Macros.DLog(message: errorResponse.errors[0].message)
            }
        )
    }

    /// Dequeues a SeparatorTableViewCell, and initializes the text according to the model
    ///
    /// - Parameters:
    ///   - row: The row of the model containing details for this cell.
    ///   - tableView: The UITableView that will contain this row.
    /// - Returns: A fully configured cell.
    func cell(for row: FormRowSeparator, tableView: UITableView) -> SeparatorTableViewCell {
        guard let cell =
            tableView.dequeueReusableCell(
                withIdentifier: SeparatorTableViewCell.reuseIdentifier
            ) as? SeparatorTableViewCell else {
             fatalError("Could not cast cell to LogoTableViewCell")
        }

        cell.separatorText = row.text as NSString?
        return cell
    }

    /// Dequeues an ImageTableViewCell, and initializes the image according to the model.
    ///
    /// - Parameters:
    ///    - row: The row of the model containing details for this cell.
    ///    - tableView: The UITableView that will contain this row
    /// - Returns: A fully configured ImageTableViewCell.
    func cell(for row: FormRowImage, tableView: UITableView) -> ImageTableViewCell {
        guard let cell =
            tableView.dequeueReusableCell(
                withIdentifier: ImageTableViewCell.reuseIdentifier
            ) as? ImageTableViewCell else {
             fatalError("Could not cast cell to ImageTableViewCell")
        }

        cell.displayImage = row.image
        return cell

    }

    /// Dequeues a LogoTableViewCell, and initializes the logo according to the model.
    ///
    /// - Parameters:
    ///    - row: The row of the model containing details for this cell.
    ///    - tableView: The UITableView that will contain this row
    /// - Returns: A fully configured LogoTableViewCell.
    func cell(for row: FormRowSmallLogo, tableView: UITableView) -> LogoTableViewCell {
        guard let cell =
            tableView.dequeueReusableCell(
                withIdentifier: LogoTableViewCell.reuseIdentifier
            ) as? LogoTableViewCell else {
             fatalError("Could not cast cell to LogoTableViewCell")
        }

        cell.displayImage = row.image
        return cell
    }

    // periphery:ignore
    /// Called when the user switches back from the Bancontact app.
    /// The app was not polling before, it starts the polling process.
    ///
    /// - Parameter obj: The sender of the notification.
    @objc func didReturn(obj: AnyObject) {
        if !self.polling {
            self.startPolling()
        }
    }

    /// Called in response to press of the "Open App" button.
    /// Opens the Bancontact app, and registers a notification to see when the app retrurns.
    @objc func didTapOpenAppButton() {
        guard let url = URL(string: self.appRedirectURL) else {
            return
        }

        guard UIApplication.shared.canOpenURL(url) else {
            return
        }
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:]) { (_) in

            }
        } else {
            UIApplication.shared.openURL(url)
        }
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didReturn),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }

    /// Fully initializes a model for a separator row with an "Or" label, or a localization of it,
    /// and inserts it as first row.
    private func insertSeparator() {
        let separatorTextKey = "gc.general.paymentProducts.3012.divider"
        let separatorTextValue =
            NSLocalizedString(
                separatorTextKey,
                tableName: SDKConstants.kSDKLocalizable,
                bundle: AppConstants.sdkBundle,
                value: "Or",
                comment: ""
            ).uppercased()
        self.formRows.insert(FormRowSeparator(text: separatorTextValue), at: 0)

    }

    /// Fully initializes a model for a button and inserts it as first row.
    ///
    /// - Parameters:
    ///     - selector: The selector for the button action.
    ///     - key: The key to lookup the localization for the button caption.
    ///     - value: The value to use for the button caption if the localization is not found.
    private func insertButton(selector: Selector, key: String, value: String) {
        let translation =
            NSLocalizedString(
                key,
                tableName: SDKConstants.kSDKLocalizable,
                bundle: AppConstants.sdkBundle,
                value: value,
                comment: ""
            )

        let row = FormRowButton(title: translation, target: self, action: selector)
        row.isEnabled = true
        self.formRows.insert(row, at: 0)
    }

    /// Fully initializes a model for a label and inserts it as first row.
    ///
    /// - Parameters:
    ///     - bold: True if the label should be displayed in bold, false otherwise.
    ///     - key: The key to lookup the localization for the label text.
    ///     - value: The value to use for the label text if the localization is not found.
    private func insertLabel(bold: Bool, key: String, value: String) {
        let translation =
            NSLocalizedString(
                key,
                tableName: SDKConstants.kSDKLocalizable,
                bundle: AppConstants.sdkBundle,
                value: value,
                comment: ""
            )

        let row = FormRowLabel(text: translation)
        row.isBold = bold
        self.formRows.insert(row, at: 0)
    }

    /**
     Fully initializes a model for the bancontact logo and inserts it as first row.
     
     */
    private func insertLogo() {
        formRows.insert(FormRowSmallLogo(image: paymentItem.displayHints.logoImage!), at: 0)
    }

    /**
     Initialized the BancontactViewController with the Bancontact specific formrows,
     in addition to the general formRows.
     */
    override func initializeFormRows() {
        super.initializeFormRows()

        let insertQRCode = { self.formRows.insert(FormRowQRCode(qrCodeString: self.qrCodeString), at: 0) }

        insertLabel(
            bold: true,
            key: "gc.general.paymentProducts.3012.payWithCardLabel",
            value: "Pay with your Bancontact card"
        )

        if UIDevice.current.userInterfaceIdiom == .pad {
            insertSeparator()

            // BADI18n: Localization entries are different from
            insertLabel(
                bold: false,
                key: "gc.general.paymentProducts.3012.qrCodeLabel",
                value: "Open the app on your phone, click 'Pay' and scan with a QR code."
            )

            insertQRCode()

            // BADI18n: missing localization for this text
            insertLabel(bold: true, key: "gc.general.paymentProducts.3012.qrCodeShortLabel", value: "Scan a QR code")

        }
        insertSeparator()

        insertButton(
            selector: #selector(didTapOpenAppButton),
            key: "gc.general.paymentProducts.3012.payWithAppButtonText",
            value: "Open App"
        )

        insertLabel(
            bold: true,
            key: "gc.general.paymentProducts.3012.payWithAppButtonText",
            value: "Pay with your bancontact app"
        )

        insertLabel(
            bold: false,
            key: "gc.general.paymentProducts.3012.introduction",
            value: "How would you like to pay?"
        )

        insertLogo()

    }
}
