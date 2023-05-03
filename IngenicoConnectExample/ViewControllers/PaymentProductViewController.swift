//
//  PaymentProductViewController.swift
//  IngenicoConnectExample
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2016 Global Collect Services. All rights reserved.
//

import Foundation
import UIKit
import IngenicoConnectKit

class PaymentProductViewController: UITableViewController, UITextFieldDelegate,
                                    UIPickerViewDelegate, UIPickerViewDataSource,
                                    SwitchTableViewCellDelegate, DatePickerTableViewCellDelegate {

    var paymentItem: PaymentItem!
    var context: PaymentContext!
    var session: Session!
    var amount: Int = 0

    var header: SummaryTableHeaderView!
    var inputData: PaymentProductInputData!
    var confirmedPaymentProducts: Set<String> = []
    var formRows: [FormRow] = []
    var initialPaymentProduct: PaymentProduct?

    var validation = false
    var rememberPaymentDetails = false
    var switching = false

    var paymentRequestTarget: PaymentRequestTarget?
    var accountOnFile: AccountOnFile?

    // MARK: -
    // MARK: ViewController
    init(
        paymentItem: PaymentItem,
        session: Session,
        context: PaymentContext,
        accountOnFile: AccountOnFile?
    ) {
        super.init(style: .plain)
        self.paymentItem = paymentItem
        context.forceBasicFlow = true
        self.session = session
        self.context = context
        self.amount = context.amountOfMoney.totalAmount
        self.accountOnFile = accountOnFile
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.separatorStyle = .none
        tableView.separatorInset = UIEdgeInsets.zero

        view.backgroundColor = UIColor.white
        navigationItem.titleView = MerchantLogoImageView()

        rememberPaymentDetails = false

        initializeHeader()
        initializeTapRecognizer()

        inputData = PaymentProductInputData()
        inputData.accountOnFile = self.accountOnFile
        inputData.paymentItem = paymentItem
        if let product = paymentItem as? PaymentProduct {
            confirmedPaymentProducts.insert(product.identifier)
            initialPaymentProduct = product
        }

        initializeFormRows()
        addExtraRows()
        registerReuseIdentifiers()
    }

    func registerReuseIdentifiers() {
        tableView.register(TextFieldTableViewCell.self, forCellReuseIdentifier: TextFieldTableViewCell.reuseIdentifier)
        tableView.register(ButtonTableViewCell.self, forCellReuseIdentifier: ButtonTableViewCell.reuseIdentifier)
        tableView.register(CurrencyTableViewCell.self, forCellReuseIdentifier: CurrencyTableViewCell.reuseIdentifier)
        tableView.register(SwitchTableViewCell.self, forCellReuseIdentifier: SwitchTableViewCell.reuseIdentifier)
        tableView.register(LabelTableViewCell.self, forCellReuseIdentifier: LabelTableViewCell.reuseIdentifier)
        tableView.register(
            PickerViewTableViewCell.self,
            forCellReuseIdentifier: PickerViewTableViewCell.reuseIdentifier
        )
        tableView.register(
            ErrorMessageTableViewCell.self,
            forCellReuseIdentifier: ErrorMessageTableViewCell.reuseIdentifier
        )
        tableView.register(TooltipTableViewCell.self, forCellReuseIdentifier: TooltipTableViewCell.reuseIdentifier)
        tableView.register(
            DatePickerTableViewCell.self,
            forCellReuseIdentifier: DatePickerTableViewCell.reuseIdentifier
        )
    }

    func initializeTapRecognizer() {
        let tapScrollView = UITapGestureRecognizer(target: self, action: #selector(tableViewTapped))
        tapScrollView.cancelsTouchesInView = false
        tableView.addGestureRecognizer(tapScrollView)
    }

    @objc func tableViewTapped() {
        UIApplication.shared.keyWindow?.endEditing(false)
    }

    func initializeHeader() {
        header = SummaryTableHeaderView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 80))
        header.setSummary(
            summary:
                """
                \(NSLocalizedString(
                    "gc.app.general.shoppingCart.total",
                    tableName: SDKConstants.kSDKLocalizable,
                    bundle: AppConstants.sdkBundle,
                    value: "",
                    comment: "Description of the amount header."
                )):
                """
        )

        let amountAsNumber = (Double(amount) / Double(100)) as NSNumber
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        numberFormatter.currencyCode = context.amountOfMoney.currencyCodeString
        let amountAsString = numberFormatter.string(from: amountAsNumber) ?? "NaN"
        header.setAmount(amount: amountAsString)
        header.setSecurePayment(
            securePayment:
                NSLocalizedString(
                    "gc.app.general.securePaymentText",
                    tableName: SDKConstants.kSDKLocalizable,
                    bundle: AppConstants.sdkBundle,
                    value: "",
                    comment: "Text indicating that a secure payment method is used."
                )
        )
        tableView.tableHeaderView = header
    }
    func addExtraRows() {
        // Add remember me switch
        let switchFormRow =
            FormRowSwitch(
                title:
                    NSLocalizedString(
                        "gc.app.paymentProductDetails.rememberMe",
                        tableName: SDKConstants.kSDKLocalizable,
                        bundle: AppConstants.sdkBundle,
                        value: "",
                        comment: "Explanation of the switch for remembering payment information."
                    ),
                isOn: rememberPaymentDetails,
                target: self,
                action: #selector(switchChanged),
                paymentProductField: nil
            )
        switchFormRow.isEnabled = false
        self.formRows.append(switchFormRow)

        let switchFormRowTooltip = FormRowTooltip()
        switchFormRowTooltip.text =
            NSLocalizedString(
                "gc.app.paymentProductDetails.rememberMe.tooltip",
                tableName: SDKConstants.kSDKLocalizable,
                bundle: AppConstants.sdkBundle,
                value: "",
                comment: ""
            )
        switchFormRow.tooltip = switchFormRowTooltip
        self.formRows.append(switchFormRowTooltip)

        // Add pay and cancel button
        let payButtonTitle =
            NSLocalizedString(
                "gc.app.paymentProductDetails.payButton",
                tableName: SDKConstants.kSDKLocalizable,
                bundle: AppConstants.sdkBundle,
                value: "",
                comment: "Title of the pay button on the payment product screen."
            )
        let payButtonFormRow = FormRowButton(title: payButtonTitle, target: self, action: #selector(payButtonTapped))
        payButtonFormRow.isEnabled = paymentItem is PaymentProduct
        self.formRows.append(payButtonFormRow)

        let cancelButtonTitle =
            NSLocalizedString(
                "gc.app.paymentProductDetails.cancelButton",
                tableName: SDKConstants.kSDKLocalizable,
                bundle: AppConstants.sdkBundle,
                value: "",
                comment: "Title of the cancel button on the payment product screen."
            )
        let cancelButtonFormRow =
            FormRowButton(title: cancelButtonTitle, target: self, action: #selector(cancelButtonTapped))
        cancelButtonFormRow.buttonType = .secondary
        cancelButtonFormRow.isEnabled = true
        self.formRows.append(cancelButtonFormRow)
    }

    func initializeFormRows() {
        let mapper = FormRowsConverter()
        let formRows = mapper.formRows(from: inputData, confirmedPaymentProducts: confirmedPaymentProducts)

        var formRowsWithTooltip = [FormRow]()
        for row in formRows {
            formRowsWithTooltip.append(row)
            if let infoButtonRow = row as? FormRowWithInfoButton, let tooltipRow = infoButtonRow.tooltip {
                formRowsWithTooltip.append(tooltipRow)
            }
        }

        self.formRows = formRowsWithTooltip
    }

    func updateFormRows() {
        tableView.beginUpdates()
        for (index, row) in formRows.enumerated() {
            if let row = row as? FormRowTextField,
               let cell = tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? TextFieldTableViewCell {
                updateTextFieldCell(cell: cell, row: row)
            } else if let row = row as? FormRowSwitch {
                if row.action == #selector(switchChanged) {
                    if let product = paymentItem as? BasicPaymentProduct,
                       product.allowsTokenization &&
                       !product.autoTokenized &&
                       accountOnFile == nil {
                        row.isEnabled = true
                    } else {
                        row.isEnabled = false
                    }
                }
                if let cell = tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? SwitchTableViewCell {
                    updateSwitchCell(cell, row: row)
                }

            } else if let row = row as? FormRowList {
                if let cell = tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? PickerViewTableViewCell {
                    updatePickerCell(cell, row: row)
                }
            } else if let row = row as? FormRowButton,
                      row.action == #selector(payButtonTapped),
                      let cell = tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? ButtonTableViewCell {
                if paymentItem is PaymentProduct {
                    row.isEnabled = true
                } else {
                    row.isEnabled = false
                }
                updateButtonCell(cell: cell, row: row)
            }
        }
        tableView.endUpdates()
    }

    func updateButtonCell(cell: ButtonTableViewCell, row: FormRowButton) {
        cell.isEnabled = row.isEnabled
    }

    func switchToPaymentProduct(paymentProductId: String?) {
        if let paymentProductId = paymentProductId {
            confirmedPaymentProducts.insert(paymentProductId)
        } else {
            confirmedPaymentProducts.remove(paymentItem.identifier)
            updateFormRows()
        }
        if let paymentProductId = paymentProductId, paymentProductId == paymentItem.identifier {
            updateFormRows()
        } else if let paymentProductId = paymentProductId, !switching {
            switching = true
            session.paymentProduct(
                withId: paymentProductId,
                context: context,
                success: {(_ paymentProduct: PaymentProduct) -> Void in
                    self.paymentItem = paymentProduct
                    self.inputData.paymentItem = paymentProduct
                    self.updateFormRows()
                    self.switching = false
                },
                failure: { _ in }
            )
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return formRows.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let row = formRows[indexPath.row]
        let cell = formRowCell(for: row, indexPath: indexPath)
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        return cell
    }

    func formRowCell(for row: FormRow, indexPath: IndexPath) -> UITableViewCell {
        var cell: TableViewCell?
        if let formRow = row as? FormRowTextField {
            cell = self.cell(for: formRow, tableView: tableView)
        } else if let formRow = row as? FormRowCurrency {
            cell = self.cell(for: formRow, tableView: tableView)
        } else if let formRow = row as? FormRowSwitch {
            cell = self.cell(for: formRow, tableView: tableView)
        } else if let formRow = row as? FormRowList {
            cell = self.cell(for: formRow, tableView: tableView)
        } else if let formRow = row as? FormRowButton {
            cell = self.cell(for: formRow, tableView: tableView)
        }
            // Should be before FormRowLabel due to inheritance
        else if let formRow = row as? FormRowErrorMessage {
            cell = self.cell(for: formRow, tableView: tableView)
        } else if let formRow = row as? FormRowLabel {
            cell = self.cell(for: formRow, tableView: tableView)
        } else if let formRow = row as? FormRowTooltip {
            cell = self.cell(for: formRow, tableView: tableView)
        } else if let formRow = row as? FormRowDate {
            cell = self.cell(for: formRow, tableView: tableView)
        } else {
            NSException(
                name: NSExceptionName(rawValue: "Invalid form row class"),
                reason: "Form row class is invalid", userInfo: nil
            ).raise()
        }

        guard let cell = cell else {
            let emptyCell = TableViewCell()
            return emptyCell
        }

        cell.clipsToBounds = true
        return cell
    }
    func updateTextFieldCell(cell: TextFieldTableViewCell, row: FormRowTextField) {
        // Add error messages for cells
        cell.delegate = self
        cell.accessoryType = row.showInfoButton ? .detailButton : .none
        cell.readonly = !row.isEnabled
        cell.field = row.field
        if let error = row.paymentProductField.errors.first {
            cell.error =
                FormRowsConverter.errorMessage(
                    for: error,
                    withCurrency: row.paymentProductField.displayHints.formElement.type == .currencyType
                )
        } else {
            cell.error = nil
        }
    }

    func cell(for row: FormRowTextField, tableView: UITableView) -> TextFieldTableViewCell {
        guard let cell =
            tableView.dequeueReusableCell(
                withIdentifier: TextFieldTableViewCell.reuseIdentifier
            ) as? TextFieldTableViewCell else {
             fatalError("Could not cast cell to DatePickerTableViewCell")
        }

        self.updateTextFieldCell(cell: cell, row: row)

        return cell
    }

    func cell(for row: FormRowDate, tableView: UITableView) -> DatePickerTableViewCell {
        guard let cell =
            tableView.dequeueReusableCell(
                withIdentifier: DatePickerTableViewCell.reuseIdentifier
            ) as? DatePickerTableViewCell else {
             fatalError("Could not cast cell to DatePickerTableViewCell")
        }

        cell.readonly = !row.isEnabled
        cell.date = row.date

        cell.delegate = self

        return cell
    }

    func cell(for row: FormRowCurrency, tableView: UITableView) -> CurrencyTableViewCell {
        guard let cell =
            tableView.dequeueReusableCell(
                withIdentifier: CurrencyTableViewCell.reuseIdentifier
            ) as? CurrencyTableViewCell else {
             fatalError("Could not cast cell to CurrencyTableViewCell")
        }

        cell.delegate = self
        cell.integerField = row.integerField
        cell.fractionalField = row.fractionalField
        cell.readonly = !row.isEnabled
        cell.accessoryType = row.showInfoButton ? .detailButton : .none

        return cell
    }

    func cell(for row: FormRowSwitch, tableView: UITableView) -> SwitchTableViewCell {
        guard let cell =
            tableView.dequeueReusableCell(
                withIdentifier: SwitchTableViewCell.reuseIdentifier
            ) as? SwitchTableViewCell else {
             fatalError("Could not cast cell to SwitchTableViewCell")
        }

        cell.setSwitchTarget(row.target, action: row.action)
        cell.delegate = self
        cell.isOn = row.isOn
        cell.attributedTitle = row.title
        cell.readonly = !row.isEnabled
        cell.accessoryType = row.showInfoButton ? .detailButton : .none
        if let error = row.field?.errors.first, validation {
            cell.errorMessage = FormRowsConverter.errorMessage(for: error, withCurrency: false)
        }

        return cell
    }

    func cell(for row: FormRowList, tableView: UITableView) -> PickerViewTableViewCell {
        guard let cell =
            tableView.dequeueReusableCell(
                withIdentifier: PickerViewTableViewCell.reuseIdentifier
            ) as? PickerViewTableViewCell else {
             fatalError("Could not cast cell to PickerViewTableViewCell")
        }

        cell.delegate = self
        cell.dataSource = self
        cell.items = row.items
        cell.selectedRow = row.selectedRow
        cell.readonly = !row.isEnabled

        return cell
    }

    func cell(for row: FormRowButton, tableView: UITableView) -> ButtonTableViewCell {
        guard let cell =
            tableView.dequeueReusableCell(
                withIdentifier: ButtonTableViewCell.reuseIdentifier
            ) as? ButtonTableViewCell else {
             fatalError("Could not cast cell to ButtonTableViewCell")
        }

        cell.setClickTarget(row.target, action: row.action)
        cell.title = row.title
        cell.buttonType = row.buttonType
        cell.isEnabled = row.isEnabled
        return cell
    }

    func cell(for row: FormRowLabel, tableView: UITableView) -> LabelTableViewCell {
        guard let cell =
            tableView.dequeueReusableCell(
                withIdentifier: LabelTableViewCell.reuseIdentifier
            ) as? LabelTableViewCell else {
             fatalError("Could not cast cell to ErrorMessageTableViewCell")
        }

        cell.label = row.text
        cell.isBold = row.isBold
        cell.accessoryType = row.showInfoButton ? .detailButton : .none

        return cell
    }

    func cell(for row: FormRowErrorMessage, tableView: UITableView) -> ErrorMessageTableViewCell {
        guard let cell =
            tableView.dequeueReusableCell(
                withIdentifier: ErrorMessageTableViewCell.reuseIdentifier
            ) as? ErrorMessageTableViewCell else {
             fatalError("Could not cast cell to ErrorMessageTableViewCell")
        }

        cell.label = row.text

        return cell
    }

    func cell(for row: FormRowTooltip, tableView: UITableView) -> TooltipTableViewCell {
        guard let cell =
            tableView.dequeueReusableCell(
                withIdentifier: TooltipTableViewCell.reuseIdentifier
            ) as? TooltipTableViewCell else {
             fatalError("Could not cast cell to TooltipTableViewCell")
        }

        cell.tooltipImage = row.image
        cell.label = row.text

        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let row = formRows[indexPath.row]

        if row is FormRowList || row is FormRowDate {
            return DatePickerTableViewCell.pickerHeight
        }

        // Rows that you can toggle
        else if row is FormRowTooltip, !row.isEnabled {
            return 0
        } else if let row = row as? FormRowSwitch, row.action == #selector(switchChanged), !row.isEnabled {
            return 0
        } else if let row = row as? FormRowTooltip, row.image != nil {
            return 145
        } else if let row = row as? FormRowTooltip {
            return TooltipTableViewCell.cellSize(width: min(320, tableView.frame.width), formRow: row).height
        } else if let row = row as? FormRowLabel {
            let height = LabelTableViewCell.cellSize(width: min(320, tableView.frame.width), formRow: row).height
            return height
        } else if row is FormRowButton {
            return 52
        } else if let row = row as? FormRowTextField,
                    let error = row.paymentProductField.errors.first {
            return self.getTextFieldErrorRowHeight(tableView: tableView, row: row, error: error)
        } else if let row = row as? FormRowSwitch {
            return self.getSwitchRowHeight(tableView: tableView, row: row)
        }

        return 44
    }

    private func getTextFieldErrorRowHeight(
        tableView: UITableView,
        row: FormRowTextField,
        error: ValidationError
    ) -> CGFloat {
        var width = tableView.bounds.width - 20
        if row.showInfoButton {
            width -= 48
        }
        let str =
            NSAttributedString(string: FormRowsConverter.errorMessage(
                for: error,
                withCurrency: row.paymentProductField.displayHints.formElement.type == .currencyType)
            )

        return
            44 + str.boundingRect(
                with: CGSize(width: width, height: CGFloat.greatestFiniteMagnitude),
                options: .usesLineFragmentOrigin,
                context: nil
            ).height
    }

    private func getSwitchRowHeight(tableView: UITableView, row: FormRowSwitch) -> CGFloat {
        var width = tableView.bounds.width - 20
        if row.showInfoButton {
            width -= 48
        }
        var errorHeight: CGFloat = 0
        if let firstError = row.field?.errors.first, validation {
            let str =
                NSAttributedString(string: FormRowsConverter.errorMessage(for: firstError, withCurrency: false))
            errorHeight =
                str.boundingRect(
                    with: CGSize.init(width: width, height: CGFloat.infinity),
                    options: .usesLineFragmentOrigin, context: nil
                ).height + 10
        }

        return 10 + 44 + 10 + errorHeight
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Subclasses need to be able to call this method to prevent unrecognized selector exception so don't delete it!
    }

    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        if let formRow = formRows[indexPath.row + 1] as? FormRowTooltip {
            formRow.isEnabled = !formRow.isEnabled

            tableView.beginUpdates()
            tableView.endUpdates()
        }
    }

    // MARK: TextField delegate

    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        var returnValue = false
        if let castedTextField = textField as? IntegerTextField {
            returnValue = integerTextField(castedTextField, shouldChangeCharactersIn: range, replacementString: string)
        } else if let castedTextField = textField as? FractionalTextField {
            returnValue =
                fractionalTextField(castedTextField, shouldChangeCharactersIn: range, replacementString: string)
        } else if let castedTextField = textField as? TextField {
            returnValue = standardTextField(castedTextField, shouldChangeCharactersIn: range, replacementString: string)
        }
        if validation {
            validateData()
        }

        return returnValue
    }

    func standardTextField(
        _ textField: TextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        guard let cell = textField.superview as? UITableViewCell,
              let indexPath = tableView.indexPath(for: cell),
              let row = formRows[indexPath.row] as? FormRowTextField,
              let text = textField.text else {
            return false
        }

        let newString = (text as NSString).replacingCharacters(in: range, with: string)
        inputData.setValue(value: newString, forField: row.paymentProductField.identifier)
        var field = row.field
        field.text = inputData.maskedValue(forField: row.paymentProductField.identifier)
        row.field = field
        formRows[indexPath.row] = row

        var cursorPosition = range.location + string.count
        formatAndUpdateCharacters(textField: textField, cursorPosition: &cursorPosition, indexPath: indexPath)

        return false
    }

    func formatAndUpdateCharacters(
        textField: UITextField,
        cursorPosition: inout Int,
        indexPath: IndexPath,
        trimSet: CharacterSet = CharacterSet(charactersIn: " /-_")
    ) {
        guard let row = formRows[indexPath.row] as? FormRowTextField else {
            return
        }

        let formattedString =
            inputData.maskedValue(
                forField: row.paymentProductField.identifier,
                cursorPosition: &cursorPosition
            ).trimmingCharacters(in: trimSet)
        row.field.text = formattedString
        textField.text = formattedString
        cursorPosition = min(cursorPosition, formattedString.count)

        guard let cursorPositionInTextField =
                textField.position(from: textField.beginningOfDocument, offset: cursorPosition) else {
            return
        }
        textField.selectedTextRange =
            textField.textRange(from: cursorPositionInTextField, to: cursorPositionInTextField)

    }

    func integerTextField(
        _ textField: IntegerTextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        guard let cell = textField.superview as? CurrencyTableViewCell,
            let indexPath = tableView.indexPath(for: cell),
            let row = formRows[indexPath.row] as? FormRowCurrency,
            let text = textField.text else {
            return false
        }

        let integerString = (text as NSString).replacingCharacters(in: range, with: string)

        if integerString.count > 16 {
            return false
        }

        if string.count == 0 {
            return true
        }

        guard let fractionalString = cell.fractionalTextField.text else {
            return false
        }

        let newValue =
            updateCurrencyValue(
                withIntegerString: integerString,
                fractionalString: fractionalString,
                paymentProductFieldIdentifier: row.paymentProductField.identifier
            )
        updateRow(withCurrencyValue: newValue, forCell: cell)

        return false
    }

    func fractionalTextField(
        _ textField: FractionalTextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        guard let cell = textField.superview as? CurrencyTableViewCell,
            let indexPath = tableView.indexPath(for: cell),
            let row = formRows[indexPath.row] as? FormRowCurrency,
            let text = textField.text else {
            return false
        }
        var fractionalString = (text as NSString).replacingCharacters(in: range, with: string)

        if fractionalString.count > 2 {
            let end = fractionalString.endIndex
            let start = fractionalString.index(end, offsetBy: -2)
            fractionalString = fractionalString.substring(with: start..<end)
        }

        if string.count == 0 {
            return true
        }

        guard let integerString = cell.integerTextField.text else {
            return false
        }

        let newValue =
            updateCurrencyValue(
                withIntegerString: integerString,
                fractionalString: fractionalString,
                paymentProductFieldIdentifier: row.paymentProductField.identifier
            )
        updateRow(withCurrencyValue: newValue, forCell: cell)

        return false
    }

    func updateCurrencyValue(
        withIntegerString integerString: String,
        fractionalString: String,
        paymentProductFieldIdentifier identifier: String
    ) -> String {
        let integerPart = Int(integerString) ?? 0
        let fractionalPart = Int(fractionalString) ?? 0
        let newValue = integerPart * 100 + fractionalPart
        let newString = String(format: "%03lld", newValue)
        inputData.setValue(value: newString, forField: identifier)

        return newString
    }

    func updateRow(withCurrencyValue currencyValue: String, forCell cell: CurrencyTableViewCell) {
        cell.integerTextField.text =
            currencyValue.substring(
                to: currencyValue.index(currencyValue.startIndex, offsetBy: currencyValue.count - 2)
            )
        cell.fractionalTextField.text =
            currencyValue.substring(
                from: currencyValue.index(currencyValue.startIndex, offsetBy: currencyValue.count - 2)
            )
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return false
    }

    // MARK: Picker view delegate

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        guard let picker = pickerView as? PickerView else {
            fatalError("Could not cast picker to PickerView")
        }
        return picker.content.count
    }

    func pickerView(
        _ pickerView: UIPickerView,
        attributedTitleForRow row: Int,
        forComponent component: Int
    ) -> NSAttributedString? {
        guard let picker = pickerView as? PickerView else {
            fatalError("Could not cast picker to PickerView")
        }
        let item = picker.content[row]
        let string = NSAttributedString(string: item)
        return string
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        guard let cell = pickerView.superview as? PickerViewTableViewCell,
              let indexPath = tableView.indexPath(for: cell),
              let formRow = formRows[indexPath.row] as? FormRowList else {
            return
        }

        if let picker = pickerView as? PickerView,
           let selectedItem = cell.items?.first(where: { $0.displayName == picker.content[row] }) {
            formRow.selectedRow = row
            inputData.setValue(value: selectedItem.value, forField: formRow.paymentProductField.identifier)
        }
    }

    func validateData() {
        inputData.validate()
        updateFormRows()
    }

    // MARK: Button target methods

    @objc func payButtonTapped() {
        var valid = false
        inputData.validate()
        if inputData.errors.count == 0 {
            let paymentRequest = inputData.paymentRequest()
            paymentRequest.validate()
            if paymentRequest.errors.count == 0 {
                valid = true
                paymentRequestTarget?.didSubmitPaymentRequest(paymentRequest: paymentRequest)
            }
        }
        if !valid {
            validation = true
            updateFormRows()
        }
    }

    @objc func cancelButtonTapped() {
        paymentRequestTarget?.didCancelPaymentRequest()
    }

    func updateSwitchCell(_ cell: SwitchTableViewCell, row: FormRowSwitch) {
        guard let field = row.field else {
            return
        }

        if let error = field.errors.first {
            cell.errorMessage = FormRowsConverter.errorMessage(for: error, withCurrency: false)
        } else {
            cell.errorMessage = nil
        }

    }
    func updatePickerCell(_ cell: PickerViewTableViewCell, row: FormRowList) {
        return
    }

    func datePicker(_ datePicker: UIDatePicker, selectedNewDate date: Date) {
        guard let cell = datePicker.superview as? DatePickerTableViewCell else {
            return
        }
        guard let indexPath = tableView.indexPath(for: cell) else {
            return
        }
        guard let row = formRows[indexPath.row] as? FormRowDate else {
            return
        }
        row.date = date
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        inputData.setValue(value: formatter.string(from: date), forField: row.paymentProductField.identifier)

    }

    @objc func switchChanged(_ sender: Switch) {

        guard let cell = sender.superview as? SwitchTableViewCell else {
            return
        }
        guard let indexPath = tableView.indexPath(for: cell) else {
            return
        }
        guard let row = formRows[indexPath.row] as? FormRowSwitch else {
            return
        }
        let field = row.field

        if let field = field {
            inputData.setValue(value: sender.isOn ? "true" : "false", forField: field.identifier)
            row.isOn = sender.isOn
            if validation {
                validateData()
            }
            updateSwitchCell(cell, row: row)
        } else {
            inputData.tokenize = sender.isOn
        }
    }

}
