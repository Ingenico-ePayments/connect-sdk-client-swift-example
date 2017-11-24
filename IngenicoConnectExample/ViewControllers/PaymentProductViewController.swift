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

class PaymentProductViewController: UITableViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var viewFactory: ViewFactory!
    var paymentItem: PaymentItem!
    var context: PaymentContext!
    var session: Session!
    var amount: Int = 0
    
    var header: SummaryTableHeaderView!
    var inputData: PaymentProductInputData!
    var confirmedPaymentProducts: Set<String> = []
    var tooltipRows: [FormRowTooltip] = []
    var formRows: [FormRow] = []
    var initialPaymentProduct: PaymentProduct?
    
    var validation = false
    var rememberPaymentDetails = false
    var switching = false
    
    var paymentRequestTarget: PaymentRequestTarget?
    var accountOnFile: AccountOnFile?
    
    // MARK: -
    // MARK: ViewController
    init(paymentItem: PaymentItem, session: Session, context: PaymentContext, viewFactory: ViewFactory, accountOnFile: AccountOnFile?) {
        super.init(style: .plain)
        self.paymentItem = paymentItem
        context.forceBasicFlow = true
        self.session = session
        self.context = context
        self.amount = context.amountOfMoney.totalAmount
        self.viewFactory = viewFactory
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
        inputData.paymentItem = paymentItem
        if let product = paymentItem as? PaymentProduct {
            confirmedPaymentProducts.insert(product.identifier)
            initialPaymentProduct = product
        }
        
        initializeFormRows()
        registerReuseIdentifiers()
    }
    
    func registerReuseIdentifiers() {
        tableView.register(TextFieldTableViewCell.self, forCellReuseIdentifier: TextFieldTableViewCell.reuseIdentifier)
        tableView.register(ButtonTableViewCell.self, forCellReuseIdentifier: ButtonTableViewCell.reuseIdentifier)
        tableView.register(CurrencyTableViewCell.self, forCellReuseIdentifier: CurrencyTableViewCell.reuseIdentifier)
        tableView.register(SwitchTableViewCell.self, forCellReuseIdentifier: SwitchTableViewCell.reuseIdentifier)
        tableView.register(LabelTableViewCell.self, forCellReuseIdentifier: LabelTableViewCell.reuseIdentifier)
        tableView.register(PickerViewTableViewCell.self, forCellReuseIdentifier: PickerViewTableViewCell.reuseIdentifier)
        tableView.register(ErrorMessageTableViewCell.self, forCellReuseIdentifier: ErrorMessageTableViewCell.reuseIdentifier)
        tableView.register(TooltipTableViewCell.self, forCellReuseIdentifier: TooltipTableViewCell.reuseIdentifier)
    }

    func initializeTapRecognizer() {
        let tapScrollView = UITapGestureRecognizer(target: self, action: #selector(tableViewTapped))
        tapScrollView.cancelsTouchesInView = false
        tableView.addGestureRecognizer(tapScrollView)
    }
    
    func tableViewTapped() {
        UIApplication.shared.keyWindow?.endEditing(false)
    }
    
    func initializeHeader() {
        header = viewFactory.tableHeaderViewWithType(type: .gcSummaryTableHeaderViewType, frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 80))
        header.setSummary(summary: "\(NSLocalizedString("gc.app.general.shoppingCart.total", tableName: SDKConstants.kSDKLocalizable, bundle: AppConstants.sdkBundle, value: "", comment: "Description of the amount header.")):")
        
        let amountAsNumber = Double(amount) / 100.0
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        numberFormatter.currencyCode = context.amountOfMoney.currencyCode.rawValue
        let amountAsString = numberFormatter.string(from: NSNumber(value: amountAsNumber))
        header.setAmount(amount: amountAsString!)
        header.setSecurePayment(securePayment: NSLocalizedString("gc.app.general.securePaymentText", tableName: SDKConstants.kSDKLocalizable, bundle: AppConstants.sdkBundle, value: "", comment: "Text indicating that a secure payment method is used."))
        tableView.tableHeaderView = header
    }
    
    func initializeFormRows() {
        let mapper = FormRowsConverter()
        let formRows = mapper.formRows(from: inputData, viewFactory: viewFactory, confirmedPaymentProducts: confirmedPaymentProducts)

        var formRowsWithTooltip = [FormRow]()
        for row in formRows {
            formRowsWithTooltip.append(row)
            if let infoButtonRow = row as? FormRowWithInfoButton, let tooltipRow = infoButtonRow.tooltip {
                formRowsWithTooltip.append(tooltipRow)
            }
        }
        
        self.formRows = formRowsWithTooltip

        // Add remember me switch
        let switchFormRow = FormRowSwitch(title: NSLocalizedString("gc.app.paymentProductDetails.rememberMe", tableName: SDKConstants.kSDKLocalizable, bundle: AppConstants.sdkBundle, value: "", comment: "Explanation of the switch for remembering payment information."), isOn: rememberPaymentDetails, target: self, action: #selector(switchChanged))
        switchFormRow.isEnabled = false
        self.formRows.append(switchFormRow)

        let switchFormRowTooltip = FormRowTooltip()
        switchFormRowTooltip.text = NSLocalizedString("gc.app.paymentProductDetails.rememberMe.tooltip", tableName: SDKConstants.kSDKLocalizable, bundle: AppConstants.sdkBundle, value: "", comment: "")
        switchFormRow.tooltip = switchFormRowTooltip
        self.formRows.append(switchFormRowTooltip)

        // Add pay and cancel button
        let payButtonTitle = NSLocalizedString("gc.app.paymentProductDetails.payButton", tableName: SDKConstants.kSDKLocalizable, bundle: AppConstants.sdkBundle, value: "", comment: "Title of the pay button on the payment product screen.")
        let payButtonFormRow = FormRowButton(title: payButtonTitle, target: self, action: #selector(payButtonTapped))
        payButtonFormRow.isEnabled = paymentItem is PaymentProduct
        self.formRows.append(payButtonFormRow)

        let cancelButtonTitle = NSLocalizedString("gc.app.paymentProductDetails.cancelButton", tableName: SDKConstants.kSDKLocalizable, bundle: AppConstants.sdkBundle, value: "", comment: "Title of the cancel button on the payment product screen.")
        let cancelButtonFormRow = FormRowButton(title: cancelButtonTitle, target: self, action: #selector(cancelButtonTapped))
        cancelButtonFormRow.buttonType = .secondary
        cancelButtonFormRow.isEnabled = true
        self.formRows.append(cancelButtonFormRow)
        
    }
    
    
    func updateFormRows() {
        tableView.beginUpdates()
        for (index, row) in formRows.enumerated() {
            if let row = row as? FormRowTextField, let cell = tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? TextFieldTableViewCell {
                updateTextFieldCell(cell: cell, row: row)
            } else if let row = row as? FormRowSwitch, row.action == #selector(switchChanged) {
                if let product = paymentItem as? BasicPaymentProduct, product.allowsTokenization && !product.autoTokenized && accountOnFile == nil {
                    row.isEnabled = true
                } else {
                    row.isEnabled = false
                }
            } else if let row = row as? FormRowButton, row.action == #selector(payButtonTapped), let cell = tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? ButtonTableViewCell {
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
            session.paymentProduct(withId: paymentProductId, context: context, success: {(_ paymentProduct: PaymentProduct) -> Void in
                self.paymentItem = paymentProduct
                self.inputData.paymentItem = paymentProduct
                self.updateFormRows()
                self.switching = false
            }, failure: { error in
            })
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
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        return cell
    }
    
    func formRowCell(for row: FormRow, indexPath: IndexPath) -> UITableViewCell {
        var cell: TableViewCell?
        if let formRow = row as? FormRowTextField {
            cell = self.cell(for: formRow, tableView: tableView)
        }
        else if let formRow = row as? FormRowCurrency {
            cell = self.cell(for: formRow, tableView: tableView)
        }
        else if let formRow = row as? FormRowSwitch {
            cell = self.cell(for: formRow, tableView: tableView)
        }
        else if let formRow = row as? FormRowList {
            cell = self.cell(for: formRow, tableView: tableView)
        }
        else if let formRow = row as? FormRowButton {
            cell = self.cell(for: formRow, tableView: tableView)
        }
            // Should be before FormRowLabel due to inheritance
        else if let formRow = row as? FormRowErrorMessage {
            cell = self.cell(for: formRow, tableView: tableView)
        }
        else if let formRow = row as? FormRowLabel {
            cell = self.cell(for: formRow, tableView: tableView)
        }
        else if let formRow = row as? FormRowTooltip {
            cell = self.cell(for: formRow, tableView: tableView)
        }
        else {
            NSException(name: NSExceptionName(rawValue: "Invalid form row class"), reason: "Form row class is invalid", userInfo: nil).raise()
        }
        return cell!
    }
    func updateTextFieldCell(cell: TextFieldTableViewCell, row: FormRowTextField) {
        // Add error messages for cells
        cell.delegate = self
        cell.accessoryType = row.showInfoButton ? .detailButton : .none
        cell.field = row.field
        if let error = row.paymentProductField.errors.first {
            cell.error = FormRowsConverter.errorMessage(for: error, withCurrency: row.paymentProductField.displayHints.formElement.type == .currencyType)
        } else {
            cell.error = nil
        }
    }

    func cell(for row: FormRowTextField, tableView: UITableView) -> TextFieldTableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TextFieldTableViewCell.reuseIdentifier) as! TextFieldTableViewCell
        
        self.updateTextFieldCell(cell: cell, row: row)

        return cell
    }

    // TODO: not tested, not present in current API
    func cell(for row: FormRowCurrency, tableView: UITableView) -> CurrencyTableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CurrencyTableViewCell.reuseIdentifier) as! CurrencyTableViewCell

        cell.delegate = self
        cell.integerField = row.integerField
        cell.fractionalField = row.fractionalField
        cell.accessoryType = row.showInfoButton ? .detailButton : .none

        return cell
    }
    
    func cell(for row: FormRowSwitch, tableView: UITableView) -> SwitchTableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SwitchTableViewCell.reuseIdentifier) as! SwitchTableViewCell
        
        cell.setSwitchTarget(row.target, action: row.action)
        cell.title = row.title
        cell.accessoryType = row.showInfoButton ? .detailButton : .none

        return cell
    }
    
    func cell(for row: FormRowList, tableView: UITableView) -> PickerViewTableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PickerViewTableViewCell.reuseIdentifier) as! PickerViewTableViewCell

        cell.delegate = self
        cell.dataSource = self
        cell.items = row.items
        cell.selectedRow = row.selectedRow
        
        return cell
    }
    
    func cell(for row: FormRowButton, tableView: UITableView) -> ButtonTableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ButtonTableViewCell.reuseIdentifier) as! ButtonTableViewCell
        cell.setClickTarget(row.target, action: row.action)
        cell.title = row.title
        cell.buttonType = row.buttonType
        cell.isEnabled = row.isEnabled
        return cell
    }
    
    func cell(for row: FormRowLabel, tableView: UITableView) -> LabelTableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: LabelTableViewCell.reuseIdentifier) as! LabelTableViewCell
        
        cell.label = row.text
        cell.isBold = row.isBold
        
        return cell
    }
    
    func cell(for row: FormRowErrorMessage, tableView: UITableView) -> ErrorMessageTableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ErrorMessageTableViewCell.reuseIdentifier) as! ErrorMessageTableViewCell

        cell.label = row.text
        
        return cell
    }
    
    func cell(for row: FormRowTooltip, tableView: UITableView) -> TooltipTableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TooltipTableViewCell.reuseIdentifier) as! TooltipTableViewCell

        cell.tooltipImage = row.image
        cell.label = row.text
        
        return cell
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let row = formRows[indexPath.row]
        
        if row is FormRowList {
            return 162.5
        }
        // Rows that you can toggle
        else if row is FormRowTooltip, !row.isEnabled {
            return 0
        }
        else if let row = row as? FormRowSwitch, row.action == #selector(switchChanged), !row.isEnabled {
            return 0
        }
        else if let row = row as? FormRowTooltip, row.image != nil {
            return 145
        }
        else if let row = row as? FormRowLabel {
            let height = LabelTableViewCell.cellSize(width: min(320, tableView.frame.width), formRow: row).height
            return height
        } else if row is FormRowButton {
            return 52
        } else if let row = row as? FormRowTextField, row.paymentProductField.errors.count > 0 {
            var width = tableView.bounds.width - 20
            if row.showInfoButton {
                width -= 48
            }
            let str = NSAttributedString(string: FormRowsConverter.errorMessage(for: row.paymentProductField.errors.first!, withCurrency: row.paymentProductField.displayHints.formElement.type == .currencyType))
            
            return 44 + str.boundingRect(with: CGSize(width: width, height: CGFloat.greatestFiniteMagnitude), options: .usesLineFragmentOrigin, context: nil).height
        }
        
        return 44
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
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var returnValue = false
        if let castedTextField = textField as? IntegerTextField {
            returnValue = integerTextField(castedTextField, shouldChangeCharactersIn: range, replacementString: string)
        }
        else if let castedTextField = textField as? FractionalTextField {
            returnValue = fractionalTextField(castedTextField, shouldChangeCharactersIn: range, replacementString: string)
        }
        else if let castedTextField = textField as? TextField {
            returnValue = standardTextField(castedTextField, shouldChangeCharactersIn: range, replacementString: string)
        }
        if validation {
            validateData()
        }
        
        return returnValue
    }
    
    func standardTextField(_ textField: TextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let cell = textField.superview as? UITableViewCell,
              let indexPath = tableView.indexPath(for: cell),
              let row = formRows[indexPath.row] as? FormRowTextField else
        {
            return false
        }
        
        let newString = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        inputData.setValue(value: newString, forField: row.paymentProductField.identifier)
        var field = row.field
        field.text = inputData.maskedValue(forField: row.paymentProductField.identifier)
        row.field = field
        formRows[indexPath.row] = row

        var cursorPosition = range.location + string.characters.count
        formatAndUpdateCharacters(textField: textField, cursorPosition: &cursorPosition, indexPath: indexPath)
        
        return false;
    }
    
    func formatAndUpdateCharacters(textField: UITextField, cursorPosition: inout Int, indexPath: IndexPath) {
        guard let row = formRows[indexPath.row] as? FormRowTextField else {
            return
        }
        
        let trimSet = CharacterSet(charactersIn: " /-_")
        let formattedString = inputData.maskedValue(forField: row.paymentProductField.identifier, cursorPosition: &cursorPosition).trimmingCharacters(in: trimSet)
        row.field.text = formattedString
        textField.text = formattedString
        cursorPosition = min(cursorPosition, formattedString.characters.count)
        
        let cursorPositionInTextField = textField.position(from: textField.beginningOfDocument, offset: cursorPosition)!
        textField.selectedTextRange = textField.textRange(from: cursorPositionInTextField, to: cursorPositionInTextField)
        
    }
    
    func integerTextField(_ textField: IntegerTextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let cell = textField.superview as? CurrencyTableViewCell,
            let indexPath = tableView.indexPath(for: cell),
            let row = formRows[indexPath.row] as? FormRowCurrency else
        {
            return false
        }

        var integerString = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        
        if integerString.characters.count > 16 {
            return false
        }
        
        if string.characters.count == 0 {
            return true
        }

        guard let fractionalString = cell.fractionalTextField.text else {
            return false
        }
        
        let newValue = updateCurrencyValue(withIntegerString: integerString, fractionalString: fractionalString, paymentProductFieldIdentifier: row.paymentProductField.identifier)
        updateRow(withCurrencyValue: newValue, forCell: cell)

        return false
    }
    
    func fractionalTextField(_ textField: FractionalTextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let cell = textField.superview as? CurrencyTableViewCell,
            let indexPath = tableView.indexPath(for: cell),
            let row = formRows[indexPath.row] as? FormRowCurrency else
        {
            return false
        }

        var fractionalString = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        
        if fractionalString.characters.count > 2 {
            let end = fractionalString.endIndex
            let start = fractionalString.index(end, offsetBy: -2)
            fractionalString = fractionalString.substring(with: start..<end)
        }
        
        if string.characters.count == 0 {
            return true
        }

        guard let integerString = cell.integerTextField.text else {
            return false
        }

        let newValue = updateCurrencyValue(withIntegerString: integerString, fractionalString: fractionalString, paymentProductFieldIdentifier: row.paymentProductField.identifier)
        updateRow(withCurrencyValue: newValue, forCell: cell)

        return false
    }
    
    func updateCurrencyValue(withIntegerString integerString: String, fractionalString: String, paymentProductFieldIdentifier identifier: String) -> String {
        let integerPart = Int(integerString) ?? 0
        let fractionalPart = Int(fractionalString) ?? 0
        let newValue = integerPart * 100 + fractionalPart
        let newString = String(format: "%03lld", newValue)
        inputData.setValue(value: newString, forField: identifier)

        return newString
    }
    
    func updateRow(withCurrencyValue currencyValue: String, forCell cell: CurrencyTableViewCell) {
        cell.integerTextField.text = currencyValue.substring(to: currencyValue.index(currencyValue.startIndex, offsetBy: currencyValue.characters.count - 2))
        cell.fractionalTextField.text = currencyValue.substring(from: currencyValue.index(currencyValue.startIndex, offsetBy: currencyValue.characters.count - 2))
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return false
    }
    
    // MARK: Picker view delegate
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        let picker = pickerView as! PickerView
        return picker.content.count
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let picker = pickerView as! PickerView
        let item = picker.content[row]
        let string = NSAttributedString(string: item)
        return string
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        guard let cell = pickerView.superview as? PickerViewTableViewCell,
              let indexPath = tableView.indexPath(for: cell),
              let formRow = formRows[indexPath.row] as? FormRowList else
        {
            return
        }

        if let picker = pickerView as? PickerView,
           let selectedItem = cell.items?.first(where: { $0.displayName == picker.content[row] })
        {
            formRow.selectedRow = row
            inputData.setValue(value: selectedItem.value, forField: formRow.paymentProductField.identifier)
        }
    }
    
    func validateData() {
        inputData.validate()
        updateFormRows()
    }
    
    // MARK: Button target methods
    
    func payButtonTapped() {
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
    
    func cancelButtonTapped() {
        paymentRequestTarget?.didCancelPaymentRequest()
    }
    
    func switchChanged(_ sender: Switch) {
        inputData.tokenize = sender.isOn
    }

}
