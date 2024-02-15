//
//  StartViewController.swift
//  IngenicoConnectExample
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2016 Global Collect Services. All rights reserved.
//

import Foundation
import PassKit
import UIKit
import SVProgressHUD
import IngenicoConnectKit

// Enable subscripting userdefaults
extension UserDefaults {
    subscript(key: String) -> Any? {
        get {
            return object(forKey: key)
        }
        set {
            set(newValue, forKey: key)
        }
    }
}

class StartViewController: UIViewController, ContinueShoppingTarget, PaymentFinishedTarget, ParseJsonTarget {

    var containerView: UIView!
    var scrollView: UIScrollView!
    var parsableFieldsContainer: UIView!

    var explanation: UITextView!
    var clientSessionIdLabel: Label!
    var clientSessionIdTextField: TextField!
    var baseURLLabel: Label!
    var baseURLTextField: TextField!
    var assetsBaseURLLabel: Label!
    var assetsBaseURLTextField: TextField!

    var customerIdLabel: Label!
    var customerIdTextField: TextField!
    var jsonButton: UIButton!
    var merchantIdLabel: Label!
    var merchantIdTextField: TextField!
    var amountLabel: Label!
    var amountTextField: TextField!
    var countryCodeLabel: Label!
    var countryCodeTextField: TextField!
    var currencyCodeLabel: Label!
    var currencyCodeTextField: TextField!
    var isRecurringLabel: Label!
    var isRecurringSwitch: Switch!
    var payButton: UIButton!
    var shouldGroupProductsSwitch: UISwitch!

    var paymentProductsViewControllerTarget: PaymentProductsViewControllerTarget?

    var amountValue: Int = 0

    var context: PaymentContext?

    let jsonDialogViewController = JsonDialogViewController()

    override func viewDidLoad() {
        super.viewDidLoad()
        initializeTapRecognizer()

        if responds(to: #selector(getter: edgesForExtendedLayout)) {
            edgesForExtendedLayout = []
        }

        scrollView = UIScrollView(frame: view.bounds)
        scrollView.delaysContentTouches = false
        scrollView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        view.addSubview(scrollView)

        let superContainerView = UIView()
        superContainerView.translatesAutoresizingMaskIntoConstraints = false
        superContainerView.autoresizingMask = .flexibleWidth
        scrollView.addSubview(superContainerView)

        containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        superContainerView.addSubview(containerView!)

        explanation = UITextView()
        explanation.translatesAutoresizingMaskIntoConstraints = false
        explanation.text =
            NSLocalizedString(
                "SetupExplanation",
                tableName: AppConstants.kAppLocalizable,
                bundle: AppConstants.appBundle,
                value: "",
                comment:
                    """
                    To process a payment using the services provided by the Ingenico ePayments platform,
                    the following information must be provided by a merchant.
                    After providing the information requested below, this example app can process a payment.
                    """
            )
        explanation.isEditable = false
        explanation.backgroundColor =
            UIColor(red: CGFloat(0.85), green: CGFloat(0.94), blue: CGFloat(0.97), alpha: CGFloat(1))
        explanation.textColor = UIColor(red: CGFloat(0), green: CGFloat(0.58), blue: CGFloat(0.82), alpha: CGFloat(1))
        explanation.layer.cornerRadius = 5.0
        explanation.isScrollEnabled = false
        containerView.addSubview(explanation)

        parsableFieldsContainer = UIView()
        parsableFieldsContainer.translatesAutoresizingMaskIntoConstraints = false
        parsableFieldsContainer.layer.backgroundColor = UIColor.lightGray.withAlphaComponent(0.2).cgColor
        parsableFieldsContainer.layer.cornerRadius = 10
        containerView.addSubview(parsableFieldsContainer)

        clientSessionIdLabel = Label()
        clientSessionIdLabel.text =
            NSLocalizedString(
                "ClientSessionIdentifier",
                tableName: AppConstants.kAppLocalizable,
                bundle: AppConstants.appBundle,
                value: "",
                comment: "Client session identifier"
            )
        clientSessionIdLabel.translatesAutoresizingMaskIntoConstraints = false
        clientSessionIdTextField = TextField()
        clientSessionIdTextField.translatesAutoresizingMaskIntoConstraints = false
        clientSessionIdTextField.autocapitalizationType = .none
        if let text = UserDefaults.standard.value(forKey: AppConstants.kClientSessionId) as? String {
            clientSessionIdTextField.text = text
        } else {
            clientSessionIdTextField.text = ""
        }
        clientSessionIdTextField.backgroundColor = UIColor.lightGray.withAlphaComponent(0.2)

        parsableFieldsContainer.addSubview(clientSessionIdLabel)
        parsableFieldsContainer.addSubview(clientSessionIdTextField)

        customerIdLabel = Label()
        customerIdLabel.text =
            NSLocalizedString(
                "CustomerIdentifier",
                tableName: AppConstants.kAppLocalizable,
                bundle: AppConstants.appBundle,
                value: "",
                comment: "Customer identifier"
            )
        customerIdLabel.translatesAutoresizingMaskIntoConstraints = false
        customerIdTextField = TextField()
        customerIdTextField.translatesAutoresizingMaskIntoConstraints = false
        customerIdTextField.autocapitalizationType = .none
        if let text = UserDefaults.standard.value(forKey: AppConstants.kCustomerId) as? String {
            customerIdTextField.text = text
        } else {
            customerIdTextField.text = ""
        }
        customerIdTextField.backgroundColor = UIColor.lightGray.withAlphaComponent(0.2)
        parsableFieldsContainer.addSubview(customerIdLabel)
        parsableFieldsContainer.addSubview(customerIdTextField)

        jsonButton = Button(type: .secondary)
        jsonButton.translatesAutoresizingMaskIntoConstraints = false
        jsonButton.backgroundColor = UIColor.lightGray
        jsonButton.setTitleColor(UIColor.white, for: .normal)
        jsonButton.setTitle(
            NSLocalizedString(
                "Paste",
                tableName: AppConstants.kAppLocalizable,
                bundle: AppConstants.appBundle,
                value: "",
                comment: "Paste JSON button"
            ),
            for: .normal
        )
        jsonButton.addTarget(self, action: #selector(StartViewController.presentJsonDialog), for: .touchUpInside)
        parsableFieldsContainer.addSubview(jsonButton)

        merchantIdLabel = Label()
        merchantIdLabel.text =
            NSLocalizedString(
                "MerchantIdentifier",
                tableName: AppConstants.kAppLocalizable,
                bundle: AppConstants.appBundle,
                value: "",
                comment: "Merchant identifier"
            )
        merchantIdLabel.translatesAutoresizingMaskIntoConstraints = false
        merchantIdTextField = TextField()
        merchantIdTextField.translatesAutoresizingMaskIntoConstraints = false
        merchantIdTextField.autocapitalizationType = .none
        if let text = UserDefaults.standard.value(forKey: AppConstants.kMerchantId) as? String {
            merchantIdTextField.text = text
        } else {
            merchantIdTextField.text = ""
        }
        containerView.addSubview(merchantIdLabel)
        containerView.addSubview(merchantIdTextField)

        baseURLLabel = Label()
        baseURLLabel.text =
            NSLocalizedString(
                "BaseURL",
                tableName: AppConstants.kAppLocalizable,
                bundle: AppConstants.appBundle,
                value: "",
                comment: "Region"
            )
        baseURLLabel.translatesAutoresizingMaskIntoConstraints = false
        baseURLTextField = TextField()
        baseURLTextField.translatesAutoresizingMaskIntoConstraints = false
        baseURLTextField.autocapitalizationType = .none
        baseURLTextField.autocorrectionType = .no
        baseURLTextField.keyboardType = .URL
        if let text = UserDefaults.standard.value(forKey: AppConstants.kBaseURL) as? String {
            baseURLTextField.text = text
        } else {
            baseURLTextField.text = ""
        }
        baseURLTextField.backgroundColor = UIColor.lightGray.withAlphaComponent(0.2)
        parsableFieldsContainer.addSubview(baseURLLabel)
        parsableFieldsContainer.addSubview(baseURLTextField)

        assetsBaseURLLabel = Label()
        assetsBaseURLLabel.text =
            NSLocalizedString(
                "AssetsBaseURL",
                tableName: AppConstants.kAppLocalizable,
                bundle: AppConstants.appBundle,
                value: "",
                comment: "Region"
            )
        assetsBaseURLLabel.translatesAutoresizingMaskIntoConstraints = false
        assetsBaseURLTextField = TextField()
        assetsBaseURLTextField.translatesAutoresizingMaskIntoConstraints = false
        assetsBaseURLTextField.autocapitalizationType = .none
        assetsBaseURLTextField.autocorrectionType = .no
        assetsBaseURLTextField.keyboardType = .URL
        if let text = UserDefaults.standard.value(forKey: AppConstants.kAssetsBaseURL) as? String {
            assetsBaseURLTextField.text = text
        } else {
            assetsBaseURLTextField.text = ""
        }
        assetsBaseURLTextField.backgroundColor = UIColor.lightGray.withAlphaComponent(0.2)
        parsableFieldsContainer.addSubview(assetsBaseURLLabel)
        parsableFieldsContainer.addSubview(assetsBaseURLTextField)

        amountLabel = Label()
        amountLabel.text =
            NSLocalizedString(
                "AmountInCents",
                tableName: AppConstants.kAppLocalizable,
                bundle: AppConstants.appBundle,
                value: "",
                comment: "Amount in cents"
            )
        amountLabel.translatesAutoresizingMaskIntoConstraints = false
        amountTextField = TextField()
        amountTextField.translatesAutoresizingMaskIntoConstraints = false
        if let amount = UserDefaults.standard.value(forKey: AppConstants.kPrice) as? Int {
            amountTextField.text = String(amount)
        } else {
            amountTextField.text = "100"
        }
        containerView.addSubview(amountLabel)
        containerView.addSubview(amountTextField)

        countryCodeLabel = Label()
        countryCodeLabel.text =
            NSLocalizedString(
                "CountryCode",
                tableName: AppConstants.kAppLocalizable,
                bundle: AppConstants.appBundle,
                value: "",
                comment: "Country code"
            )
        countryCodeLabel.translatesAutoresizingMaskIntoConstraints = false

        countryCodeTextField = TextField()
        countryCodeTextField.translatesAutoresizingMaskIntoConstraints = false
        countryCodeTextField.autocapitalizationType = .none
        if let text = UserDefaults.standard.value(forKey: AppConstants.kCountryCode) as? String {
            countryCodeTextField.text = text
        } else {
            countryCodeTextField.text = ""
        }
        containerView.addSubview(countryCodeLabel)
        containerView.addSubview(countryCodeTextField)

        currencyCodeLabel = Label()
        currencyCodeLabel.text =
            NSLocalizedString(
                "CurrencyCode",
                tableName: AppConstants.kAppLocalizable,
                bundle: AppConstants.appBundle,
                value: "",
                comment: "Currency code"
            )
        currencyCodeLabel.translatesAutoresizingMaskIntoConstraints = false

        currencyCodeTextField = TextField()
        currencyCodeTextField.translatesAutoresizingMaskIntoConstraints = false
        currencyCodeTextField.autocapitalizationType = .none
        if let text = UserDefaults.standard.value(forKey: AppConstants.kCurrency) as? String {
            currencyCodeTextField.text = text
        } else {
            currencyCodeTextField.text = ""
        }
        containerView.addSubview(currencyCodeLabel)
        containerView.addSubview(currencyCodeTextField)

        isRecurringLabel = Label()
        isRecurringLabel.text =
            NSLocalizedString(
                "RecurringPayment",
                tableName: AppConstants.kAppLocalizable,
                bundle: AppConstants.appBundle,
                value: "",
                comment: "Payment is recurring"
            )
        isRecurringLabel.translatesAutoresizingMaskIntoConstraints = false
        isRecurringSwitch = Switch()
        isRecurringSwitch.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(isRecurringLabel)
        containerView.addSubview(isRecurringSwitch)

        let shouldGroupProductsSwitchLabel = Label()
        shouldGroupProductsSwitchLabel.text =
            NSLocalizedString(
                "ShouldGroupProductsSwitch",
                tableName: AppConstants.kAppLocalizable,
                bundle: AppConstants.appBundle,
                value: "Group payment products",
                comment: "Label for switch to enable product grouping"
            )
        shouldGroupProductsSwitchLabel.translatesAutoresizingMaskIntoConstraints = false
        shouldGroupProductsSwitch = Switch()
        shouldGroupProductsSwitch.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(shouldGroupProductsSwitchLabel)
        containerView.addSubview(shouldGroupProductsSwitch)

        payButton = Button(type: .primary)
        payButton.setTitle(
            NSLocalizedString(
                "PayNow",
                tableName: AppConstants.kAppLocalizable,
                bundle: AppConstants.appBundle,
                value: "",
                comment: "Pay securely now"
            ),
            for: .normal
        )
        payButton.translatesAutoresizingMaskIntoConstraints = false
        payButton.addTarget(self, action: #selector(StartViewController.buyButtonTapped), for: .touchUpInside)
        containerView.addSubview(payButton)

        let views: [String: AnyObject] = [
            "explanation": explanation,
            "clientSessionIdLabel": clientSessionIdLabel,
            "clientSessionIdTextField": clientSessionIdTextField,
            "customerIdLabel": customerIdLabel,
            "customerIdTextField": customerIdTextField,
            "jsonButton": jsonButton,
            "merchantIdLabel": merchantIdLabel,
            "merchantIdTextField": merchantIdTextField,
            "baseURLLabel": baseURLLabel,
            "baseURLTextField": baseURLTextField,
            "assetsBaseURLLabel": assetsBaseURLLabel,
            "assetsBaseURLTextField": assetsBaseURLTextField,
            "amountLabel": amountLabel,
            "amountTextField": amountTextField,
            "countryCodeLabel": countryCodeLabel,
            "countryCodeTextField": countryCodeTextField,
            "currencyCodeLabel": currencyCodeLabel,
            "currencyCodeTextField": currencyCodeTextField,
            "isRecurringLabel": isRecurringLabel,
            "isRecurringSwitch": isRecurringSwitch,
            "payButton": payButton,
            "shouldGroupProductsSwitchLabel": shouldGroupProductsSwitchLabel,
            "shouldGroupProductsSwitch": shouldGroupProductsSwitch,
            "superContainerView": superContainerView,
            "containerView": containerView,
            "parsableFields": parsableFieldsContainer,
            "scrollView": scrollView
        ]
        let metrics = ["fieldSeparator": "24", "groupSeparator": "72"]

        parsableFieldsContainer.addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "|-[clientSessionIdLabel]-|",
                options: [],
                metrics: nil,
                views: views
            )
        )
        parsableFieldsContainer.addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "|-[clientSessionIdTextField]-|",
                options: [],
                metrics: nil,
                views: views
            )
        )
        parsableFieldsContainer.addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "|-[customerIdLabel]-|",
                options: [],
                metrics: nil,
                views: views
            )
        )
        parsableFieldsContainer.addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "|-[customerIdTextField]-|",
                options: [],
                metrics: nil,
                views: views
            )
        )
        parsableFieldsContainer.addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "[jsonButton(>=120)]-|",
                options: [],
                metrics: nil,
                views: views
            )
        )
        parsableFieldsContainer.addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "|-[baseURLLabel]-|",
                options: [],
                metrics: nil,
                views: views
            )
        )
        parsableFieldsContainer.addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "|-[baseURLTextField]-|",
                options: [],
                metrics: nil,
                views: views
            )
        )
        parsableFieldsContainer.addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "|-[assetsBaseURLLabel]-|",
                options: [],
                metrics: nil,
                views: views
            )
        )
        parsableFieldsContainer.addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "|-[assetsBaseURLTextField]-|",
                options: [],
                metrics: nil,
                views: views
            )
        )
        parsableFieldsContainer.addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat:
                    // swiftlint:disable line_length
                    "V:|-[clientSessionIdLabel]-[clientSessionIdTextField]-(fieldSeparator)-[customerIdLabel]-[customerIdTextField]-(fieldSeparator)-[baseURLLabel]-[baseURLTextField]-(fieldSeparator)-[assetsBaseURLLabel]-[assetsBaseURLTextField]-(fieldSeparator)-[jsonButton]-|",
                    // swiftlint:enable line_length
                options: [],
                metrics: metrics,
                views: views
            )
        )

        containerView.addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "|-[explanation]-|",
                options: [],
                metrics: nil,
                views: views
            )
        )
        containerView.addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "|-[merchantIdLabel]-|",
                options: [],
                metrics: nil,
                views: views
            )
        )
        containerView.addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "|-[parsableFields]-|",
                options: [],
                metrics: nil,
                views: views
            )
        )
        containerView.addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "|-[merchantIdTextField]-|",
                options: [],
                metrics: nil,
                views: views
            )
        )
        containerView.addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "|-[merchantIdLabel]-|",
                options: [],
                metrics: nil,
                views: views
            )
        )
        containerView.addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "|-[merchantIdTextField]-|",
                options: [],
                metrics: nil,
                views: views
            )
        )
        containerView.addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "|-[amountLabel]-|",
                options: [],
                metrics: nil,
                views: views
            )
        )
        containerView.addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "|-[amountTextField]-|",
                options: [],
                metrics: nil,
                views: views
            )
        )
        containerView.addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "|-[countryCodeLabel]-|",
                options: [],
                metrics: nil,
                views: views
            )
        )
        containerView.addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "|-[countryCodeTextField]-|",
                options: [],
                metrics: nil,
                views: views
            )
        )
        containerView.addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "|-[currencyCodeLabel]-|",
                options: [],
                metrics: nil,
                views: views
            )
        )
        containerView.addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "|-[currencyCodeTextField]-|",
                options: [],
                metrics: nil,
                views: views
            )
        )
        containerView.addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "|-[isRecurringLabel]-[isRecurringSwitch]-|",
                options: [.alignAllCenterY],
                metrics: nil,
                views: views
            )
        )
        containerView.addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "|-[shouldGroupProductsSwitchLabel]-[shouldGroupProductsSwitch]-|",
                options: [.alignAllCenterY],
                metrics: nil,
                views: views
            )
        )
        containerView.addConstraints(
            NSLayoutConstraint.constraints(withVisualFormat: "|-[payButton]-|", options: [], metrics: nil, views: views)
        )

        containerView.addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat:
                    // swiftlint:disable line_length
                    "V:|-(fieldSeparator)-[explanation]-(fieldSeparator)-[parsableFields]-(fieldSeparator)-[merchantIdLabel]-[merchantIdTextField]-(groupSeparator)-[amountLabel]-[amountTextField]-(fieldSeparator)-[countryCodeLabel]-[countryCodeTextField]-(fieldSeparator)-[currencyCodeLabel]-[currencyCodeTextField]-(fieldSeparator)-[isRecurringSwitch]-(fieldSeparator)-[shouldGroupProductsSwitch]-(fieldSeparator)-[payButton]-|",
                    // swiftlint:enable line_length
                options: [],
                metrics: metrics,
                views: views
            )
        )

        self.view.addConstraints(
            [
                NSLayoutConstraint(
                    item: superContainerView,
                    attribute: .leading,
                    relatedBy: .equal,
                    toItem: self.view,
                    attribute: .leading,
                    multiplier: 1,
                    constant: 0
                ),
                NSLayoutConstraint(
                    item: superContainerView,
                    attribute: .trailing,
                    relatedBy: .equal,
                    toItem: self.view,
                    attribute: .trailing,
                    multiplier: 1,
                    constant: 0
                )
            ]
        )

        self.scrollView.addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "H:|[superContainerView]|",
                options: NSLayoutConstraint.FormatOptions(rawValue: 0),
                metrics: nil,
                views: views
            )
        )
        self.scrollView.addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "V:|[superContainerView]|",
                options: NSLayoutConstraint.FormatOptions(rawValue: 0),
                metrics: nil,
                views: views
            )
        )
        self.view.addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "H:|[scrollView]|",
                options: NSLayoutConstraint.FormatOptions(rawValue: 0),
                metrics: nil,
                views: views
            )
        )
        self.view.addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "V:|[scrollView]|",
                options: NSLayoutConstraint.FormatOptions(rawValue: 0),
                metrics: nil,
                views: views
            )
        )

        superContainerView.addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "V:|[containerView]|",
                options: NSLayoutConstraint.FormatOptions(rawValue: 0),
                metrics: nil,
                views: views
            )
        )
        superContainerView.addConstraint(
            NSLayoutConstraint(
                item: containerView!,
                attribute: .width,
                relatedBy: .equal,
                toItem: nil,
                attribute: .notAnAttribute,
                multiplier: 1,
                constant: 320
            )
        )
        self.view.addConstraint(
            NSLayoutConstraint(
                item: self.containerView,
                attribute: .centerX,
                relatedBy: .equal,
                toItem: self.view,
                attribute: .centerX,
                multiplier: 1,
                constant: 0
            )
        )

    }

    func initializeTapRecognizer() {
        let tapScrollView = UITapGestureRecognizer(target: self, action: #selector(tableViewTapped))
        tapScrollView.cancelsTouchesInView = false
        view.addGestureRecognizer(tapScrollView)
    }

    @objc func tableViewTapped() {
        for view: UIView in containerView!.subviews {
            if let textField = view as? TextField, textField.isFirstResponder {
                textField.resignFirstResponder()
            }
        }
    }
    private func checkURL(url: String) -> Bool {
        if let finalComponents = URLComponents(string: url) {
            let components = finalComponents.path.split(separator: "/").map { String($0)}
            let versionComponents = (SDKConstants.kApiVersion as NSString).pathComponents

            switch components.count {
            case 0:
                break
            case 1:
                if components[0] != versionComponents[0] {
                    return false
                }
            case 2:
                if components[0] != versionComponents[0] {
                    return false
                }
                if components[1] != versionComponents[1] {
                    return false
                }
            default:
                return false
            }
            return true
        }
        return false

    }
    // MARK: Button actions

    @objc func presentJsonDialog() {
        jsonDialogViewController.callback = self
        self.present(jsonDialogViewController, animated: true)
    }

    @objc func buyButtonTapped(_ sender: UIButton) {
        self.initializeConnectSDK()

        if payButton != sender {
            NSException(
                name: NSExceptionName(rawValue: "Invalid sender"),
                reason: "Sender is invalid", userInfo: nil
            ).raise()
        }

        SVProgressHUD.setDefaultMaskType(.clear)
        let status =
            NSLocalizedString(
                "gc.app.general.loading.body",
                tableName: SDKConstants.kSDKLocalizable,
                bundle: AppConstants.sdkBundle,
                value: "",
                comment: ""
            )
        SVProgressHUD.show(withStatus: status)

        ConnectSDK.clientApi.paymentItems(
            success: {(_ paymentItems: PaymentItems) -> Void in
                SVProgressHUD.dismiss()
                self.showPaymentProductSelection(paymentItems)
            },
            failure: { error in
                Macros.DLog(message: error.localizedDescription)
                self.showError(titleKey: "ConnectionErrorTitle", messageKey: "PaymentProductsErrorExplanation")
            },
            apiFailure: { errorResponse in
                Macros.DLog(message: errorResponse.errors[0].message)
                self.showError(titleKey: "ConnectionErrorTitle", messageKey: "PaymentProductsErrorExplanation")
            }
        )
    }

    private func initializeConnectSDK() {
        // ***************************************************************************
        //
        // The GlobalCollect SDK supports processing payments with the static insance of
        // ConnectSDK.clientApi. The code below shows how to initialize the ConnectSDK object correctly.
        //
        // The ConnectSDK uses a number of supporting objects. There is an
        // initializer for this class that takes these supporting objects as
        // arguments.
        //
        // ***************************************************************************

        guard let clientSessionId = clientSessionIdTextField.text,
              let customerId = customerIdTextField.text else {
            self.showError(titleKey: "FieldErrorTitle", messageKey: "FieldErrorClientSessionIdCustomerIdExplanation")
            return
        }

        UserDefaults.standard[AppConstants.kClientSessionId] = clientSessionId
        UserDefaults.standard[AppConstants.kCustomerId] = customerId
        if let merchantId = merchantIdTextField.text {
            UserDefaults.standard.set(merchantId, forKey: AppConstants.kMerchantId)
        }
        let baseURL = baseURLTextField.text
        guard checkURL(url: baseURL ?? "") else {
            self.showError(titleKey: "ConnectionErrorTitle", messageKey: "PaymentProductsErrorExplanation")
            return
        }
        UserDefaults.standard[AppConstants.kBaseURL] = baseURL

        let assetBaseURL = assetsBaseURLTextField.text
        UserDefaults.standard[AppConstants.kAssetsBaseURL] = assetBaseURL

        let sessionConfiguration = SessionConfiguration(
            clientSessionId: clientSessionId,
            customerId: customerId,
            clientApiUrl: baseURL ?? "",
            assetUrl: assetBaseURL ?? ""
        )

        // ***************************************************************************
        //
        // You can log of requests made to the server and responses received from the server
        // by passing the `enableNetworkLogs` parameter to the ConnectSDKConfiguration constructor.
        // In the constructor below, the logging is disabled.
        // Logging should be disabled in production.
        // To use logging in debug, but not in production, you can initialize the ConnectSDKConfiguration object
        // within a DEBUG flag.
        // If you use the DEBUG flag, you can take a look at this app's build settings
        // to see the setup you should apply to your own app.
        //
        // ***************************************************************************

        var connectSDKConfiguration: ConnectSDKConfiguration?

        #if DEBUG
        connectSDKConfiguration = ConnectSDKConfiguration(
            sessionConfiguration: sessionConfiguration,
            enableNetworkLogs: true,
            applicationId: AppConstants.kApplicationIdentifier,
            ipAddress: nil
        )
        #else
        connectSDKConfiguration = ConnectSDKConfiguration(
            sessionConfiguration: sessionConfiguration,
            enableNetworkLogs: false,
            applicationId: AppConstants.kApplicationIdentifier,
            ipAddress: nil
        )
        #endif

        guard let newValue = Int(amountTextField.text!) else {
            NSException(
                name: NSExceptionName(rawValue: "Invalid sender"),
                reason: "Sender is invalid", userInfo: nil
            ).raise()
            return
        }

        amountValue = newValue
        UserDefaults.standard.set(newValue, forKey: AppConstants.kPrice)

        guard let countryCode = countryCodeTextField.text,
              let currencyCode = currencyCodeTextField.text else {
            self.showError(titleKey: "FieldErrorTitle", messageKey: "FieldErrorCountryCodeCurrencyExplanation")
            return
        }

        UserDefaults.standard[AppConstants.kCountryCode] = countryCode
        UserDefaults.standard[AppConstants.kCurrency] = currencyCode
        let isRecurring = isRecurringSwitch.isOn

        // ***************************************************************************
        //
        // To retrieve the available payment products, the information stored in the
        // following PaymentContext object is needed.
        //
        // After the ConnectSDK has retrieved the payment products that match
        // the information stored in the PaymentContext object, a
        // selection screen is shown. This screen itself is not part of the SDK and
        // only illustrates a possible payment product selection screen.
        //
        // ***************************************************************************

        let amountOfMoney = PaymentAmountOfMoney(totalAmount: amountValue, currencyCode: currencyCode)
        context = PaymentContext(
            amountOfMoney: amountOfMoney,
            isRecurring: isRecurring,
            countryCode: countryCode
        )

        guard let context,
              let connectSDKConfiguration else {
            self.showError(titleKey: "ConnectionErrorTitle", messageKey: "PaymentProductsErrorExplanation")
            return
        }

        let paymentConfiguration = PaymentConfiguration(
            paymentContext: context,
            groupPaymentProducts: self.shouldGroupProductsSwitch.isOn
        )

        ConnectSDK.initialize(
            connectSDKConfiguration: connectSDKConfiguration,
            paymentConfiguration: paymentConfiguration
        )
    }

    private func showError(titleKey: String, messageKey: String) {
        SVProgressHUD.dismiss()
        let alert =
            UIAlertController(
                title: NSLocalizedString(
                    titleKey,
                    tableName: AppConstants.kAppLocalizable,
                    bundle: AppConstants.appBundle,
                    value: "",
                    comment: ""
                ),
                message: NSLocalizedString(
                    messageKey,
                    tableName: AppConstants.kAppLocalizable,
                    bundle: AppConstants.appBundle,
                    value: "",
                    comment: ""
                ),
                preferredStyle: .alert
            )
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    func showPaymentProductSelection(_ paymentItems: PaymentItems) {
        if let context {
            paymentProductsViewControllerTarget =
                PaymentProductsViewControllerTarget(
                    navigationController: navigationController!
                )
            paymentProductsViewControllerTarget!.paymentFinishedTarget = self
            let paymentProductSelection =
                PaymentProductsViewController(style: .grouped, paymentItems: paymentItems)
            paymentProductSelection.target = paymentProductsViewControllerTarget
            paymentProductSelection.amount = amountValue
            paymentProductSelection.currencyCode = context.amountOfMoney.currencyCodeString
            navigationController!.pushViewController(paymentProductSelection, animated: true)
            SVProgressHUD.dismiss()
        }
    }

    // MARK: Parsed Session JSON to object target
    func success(sessionData data: StartPaymentParsedJsonData) {
        // Do something
        baseURLTextField.text = data.baseUrl
        assetsBaseURLTextField.text = data.assetUrl
        clientSessionIdTextField.text = data.clientId
        customerIdTextField.text = data.customerId
    }

    // MARK: Continue shopping target

    func didSelectContinueShopping() {
        navigationController!.popToRootViewController(animated: true)
    }

    // MARK: Payment finished target

    func didFinishPayment(_ preparedPaymentRequest: PreparedPaymentRequest) {
        let end = EndViewController()
        end.target = self
        end.preparedPaymentRequest = preparedPaymentRequest
        navigationController!.pushViewController(end, animated: true)
    }

}
