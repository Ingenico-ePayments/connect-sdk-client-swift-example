
//
//  ArvatoProductViewController.swift
//  IngenicoConnectExample
//
//  Created for Ingenico ePayments on 07/07/2017.
//  Copyright © 2017 Ingenico. All rights reserved.
//

import UIKit
import IngenicoConnectKit

class ArvatoProductViewController: PaymentProductViewController {
    var failCount: Int = 0
    var didFind: Bool = false
    var fullData: Bool = false
    var hasLookup = false
    var errorMessageText = ""
    var installmentPlanFields = 0
    func reload() {
        self.initializeFormRows()
        self.addExtraRows()
        CATransaction.begin()
        
        CATransaction.setCompletionBlock { 
            self.tableView.reloadData()
        }
        
        self.tableView.beginUpdates()
        self.tableView.endUpdates()
        
        CATransaction.commit()
    }
    override init(paymentItem: PaymentItem, session: Session, context: PaymentContext, viewFactory: ViewFactory, accountOnFile: AccountOnFile?) {
        super.init(paymentItem: paymentItem, session: session, context: context, viewFactory: viewFactory, accountOnFile: accountOnFile)
        self.hasLookup = paymentItem.fields.paymentProductFields.map { (field) -> Bool in
            return field.usedForLookup
            }.reduce(false) { (result, bool) -> Bool in
                return result || bool
        }
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let row = formRows[indexPath.row]
        
        if !row.isEnabled {
            return 0
        }

        if let row = row as? FormRowList {
            var max: CGFloat = 0;

            max = CGFloat(row.items[row.selectedRow].displayElements.filter{ $0.id != "displayName" }.count) * (UIFont.systemFontSize + 2)
            // Add distance between error message and description
            if max > 0 {
                 max += 10
            }
            let width = min(320, tableView.bounds.width - 20)
            var errorHeight: CGFloat = 0
            if let firstError = row.paymentProductField.errors.first, validation {
                let str = NSAttributedString(string: FormRowsConverter.errorMessage(for: firstError, withCurrency: false))
                errorHeight = str.boundingRect(with: CGSize.init(width: width, height: CGFloat.infinity), options: .usesLineFragmentOrigin, context: nil).height + 10
            }

            return max  + DetailedPickerViewTableViewCell.pickerHeight + errorHeight
        }

        if let fieldRow = row as? FormRowReadonlyReview {
            return ReadonlyReviewCell.cellHeight(for: fieldRow.data, in: tableView.frame.size.width)
        }

        
        return super.tableView(tableView, heightForRowAt: indexPath)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        super.pickerView(pickerView, didSelectRow: row, inComponent: component)
        
        if validation {
            validateData()
        }
        
        // Update row height for picker
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    @objc func searchButtonTapped() {
        //let enabledRows = self.formRows.filter { (fr) -> Bool in
        //    fr.isEnabled
        //}
        let values = self.inputData.paymentItem.fields.paymentProductFields.filter { (field) -> Bool in
            field.usedForLookup
        }.map { (field) -> (String,String) in
            (field.identifier, self.inputData.value(forField: field.identifier))
        }
        var params: [[String:String]] = []
        for (key, value) in values {
            var param: [String:String] = [:]
            param["key"] = key
            param["value"] = value
            params.append(param)
        }
        self.session.customerDetails(forProductId: self.initialPaymentProduct?.identifier ?? "", withLookupValues: params, countryCode: self.context.countryCode, success: { (cd: CustomerDetails) in
            self.didFind = true
            self.validation = true
            let installmentId = self.inputData.fieldValues["installmentId"]
            let termsAndConditions = self.inputData.fieldValues["termsAndConditions"]
            let lookupIdentifiers = self.initialPaymentProduct?.fields.paymentProductFields.first(where: {$0.usedForLookup}).map({$0.identifier})
            let lookupFields = self.inputData.fieldValues.filter{ lookupIdentifiers?.contains($0.key) ?? false }
            self.inputData.fieldValues.removeAll();
            for (id, val) in lookupFields {
                self.inputData.setValue(value: val, forField: id)
            }
            self.inputData.setValue(value: installmentId ?? "", forField: "installmentId")
            self.inputData.setValue(value: termsAndConditions ?? "", forField: "termsAndConditions")

            for (key, value) in cd.values {
                self.inputData.setValue(value: value, forField: key)
            }
            self.inputData.validateExcept(fieldNames: Set(["termsAndConditions", "installmentId"]))
            if self.inputData.errors.count == 0 {
                self.fullData = true
            }
            self.reload()
        }) { (err) in
            if let err = err as? CustomerDetailsError {
                let details = err.responseValues[0]
                let id = details["id"] as? String ?? ""
                
                if self.failCount >= 10 {
                    self.errorMessageText = NSLocalizedString("gc.app.paymentProductDetails.searchConsumer.result.failed.tooMuch", tableName: SDKConstants.kSDKLocalizable, bundle: AppConstants.sdkBundle, value: "No result found. You have reached the maximum amount of tries. Please enter your details manually.", comment: "Title of the search button on the payment product screen.")
                }
                else if id == "PARAMETER_NOT_FOUND_IN_REQUEST" {
                    self.errorMessageText = NSLocalizedString("gc.app.paymentProductDetails.searchConsumer.result.failed.errors.missingValue", tableName: SDKConstants.kSDKLocalizable, bundle: AppConstants.sdkBundle, value: "No result found. You have reached the maximum amount of tries. Please enter your details manually.", comment: "Title of the search button on the payment product screen.")
                    let propertyString = details["propertyName"] as? String ?? ""
                    var stringRange = propertyString.range(of: "'", options: .backwards)
                    guard let range1 = stringRange else {
                        self.failCount += 1
                        self.didFind = false
                        self.reload()
                        return
                    }
                    let restRange = propertyString.startIndex ..< (range1.lowerBound)
                    stringRange = propertyString.substring(with: restRange).range(of: "'", options: .backwards)
                    guard let range2 = stringRange else {
                        self.failCount += 1
                        self.didFind = false
                        self.reload()
                        return
                    }
                    let propertyRange = range2.upperBound ..< range1.lowerBound
                    let property = propertyString.substring(with: propertyRange)
                    var labelKey = "gc.general.paymentProducts.\(self.paymentItem.identifier).paymentProductFields.\(property).label"
                    var labelValue = NSLocalizedString(labelKey, tableName: SDKConstants.kSDKLocalizable, bundle: AppConstants.sdkBundle, value: labelKey, comment: "Title of the search button on the payment product screen.")
                    if labelKey == labelValue {
                        labelKey = "gc.general.paymentProductFields.\(property).label"
                        labelValue = NSLocalizedString(labelKey, tableName: SDKConstants.kSDKLocalizable, bundle: AppConstants.sdkBundle, value: "No result found. You have reached the maximum amount of tries. Please enter your details manually.", comment: "Title of the search button on the payment product screen.")
                    }
                    self.errorMessageText = self.errorMessageText.replacingOccurrences(of: "{propertyName}", with: labelValue)
                }
                else {
                    self.errorMessageText = NSLocalizedString("gc.app.paymentProductDetails.searchConsumer.result.failed.invalidData", tableName: SDKConstants.kSDKLocalizable, bundle: AppConstants.sdkBundle, value: "No result found. You have reached the maximum amount of tries. Please enter your details manually.", comment: "Title of the search button on the payment product screen.")
                    
                }

            }
            self.failCount += 1
            self.didFind = false
            self.reload()
            
            
        }
    }
    @objc func enterManuallyButtonTapped() {
        didFind = true
        reload()
    }
    @objc func editInformationButtonTapped() {
        fullData = false
        reload()
    }
    @objc func searchAgainButtonTapped() {
        didFind = false
        fullData = false
        failCount = 0
        self.reload()
    }

    override func updatePickerCell(_ cell: PickerViewTableViewCell, row: FormRowList) {
        guard let cell = cell as? DetailedPickerViewTableViewCell else {
            return
        }
        let field = row.paymentProductField
        if let error = field.errors.first {
            cell.errorMessage = FormRowsConverter.errorMessage(for: error, withCurrency: false)
        } else {
            cell.errorMessage = nil
        }
        
    }
    
    override func addExtraRows() {        
        // 'Edit information' and 'Search Again' button
        
        let labelText = NSLocalizedString("gc.app.paymentProductDetails.searchConsumer.label", tableName: SDKConstants.kSDKLocalizable, bundle: AppConstants.sdkBundle, value: "Your billing details", comment: "")
        let label = FormRowLabel(text: labelText)
        label.isEnabled = self.hasLookup
        label.isBold = true
        self.formRows.insert(label, at: self.installmentPlanFields)
        let labelFormRowTooltip = FormRowTooltip()
        labelFormRowTooltip.text = NSLocalizedString("gc.app.paymentProductDetails.searchConsumer.tooltipText", tableName: SDKConstants.kSDKLocalizable, bundle: AppConstants.sdkBundle, value: "", comment: "")
        label.tooltip = labelFormRowTooltip
        self.formRows.insert(labelFormRowTooltip, at: self.installmentPlanFields + 1)

        let separator = FormRowSeparator(text: nil)
        separator.isEnabled = self.installmentPlanFields > 0
        self.formRows.insert(separator, at: self.installmentPlanFields)

        let reviewRow = FormRowReadonlyReview()
        var filteredData: [String:String] = [:]
        for (key, value) in self.inputData.fieldValues where key != "installmentPlan" && paymentItem.fields.paymentProductFields.contains(where: {$0.identifier == key}) {
            filteredData[key] = value
        }
        
        reviewRow.data = filteredData
        reviewRow.isEnabled = fullData
        self.formRows.append(reviewRow)
        
        let searchAgainButtonTitle = NSLocalizedString("gc.app.paymentProductDetails.searchConsumer.buttons.searchAgain", tableName: SDKConstants.kSDKLocalizable, bundle: AppConstants.sdkBundle, value: "Enter manually", comment: "Title of the enter manually button on the payment product screen.")
        let searchAgainButtonFormRow = FormRowButton(title: searchAgainButtonTitle, target: self, action: #selector(searchAgainButtonTapped))
        searchAgainButtonFormRow.buttonType = .primary
        let _ = paymentItem.fields.paymentProductFields.map { (field) -> Bool in
            return field.usedForLookup
            }.reduce(false) { (result, bool) -> Bool in
                return result || bool
        }
        searchAgainButtonFormRow.isEnabled = hasLookup && fullData && failCount < 10
        self.formRows.append(searchAgainButtonFormRow)
        
        
        let editInformationButtonTitle = NSLocalizedString("gc.app.paymentProductDetails.searchConsumer.buttons.editInformation", tableName: SDKConstants.kSDKLocalizable, bundle: AppConstants.sdkBundle, value: "Search", comment: "Title of the search button on the payment product screen.")
        let editInformationButtonFormRow = FormRowButton(title: editInformationButtonTitle, target: self, action: #selector(editInformationButtonTapped))
        editInformationButtonFormRow.isEnabled =  fullData && (failCount < 10 || didFind)
        editInformationButtonFormRow.buttonType = .secondary
        self.formRows.append(editInformationButtonFormRow)

        var lastLookupIndex = 0
        var i = -1
        for fr in self.formRows {
            i += 1
            switch  fr {
            case let sr as FormRowSwitch:
                if sr.field?.usedForLookup ?? false {
                    lastLookupIndex = i
                }
                
            case let sr as FormRowList:
                if sr.paymentProductField.usedForLookup {
                    lastLookupIndex = i
                }
            case let sr as FormRowDate:
                if sr.paymentProductField.usedForLookup {
                    lastLookupIndex = i
                }
            case let sr as FormRowTextField:
                if sr.paymentProductField.usedForLookup {
                    lastLookupIndex = i
                }
            case let sr as FormRowCurrency:
                if sr.paymentProductField.usedForLookup {
                    lastLookupIndex = i
                }
            default: break
            }
            if fr is FormRowWithInfoButton {
                if self.formRows[i + 1] is FormRowTooltip {
                    lastLookupIndex += 1
                }
            }
            
        }
        
        let badMessageTitleEarly = self.errorMessageText
        
        let badMessageEarlyRow = FormRowLabel(text: badMessageTitleEarly)
            badMessageEarlyRow.isEnabled = hasLookup && !didFind && !fullData && failCount > 0 && failCount < 10
        self.formRows.insert(badMessageEarlyRow, at: lastLookupIndex + 1)
        // Add search and 'enter manually' button
        let searchButtonTitle = NSLocalizedString("gc.app.paymentProductDetails.searchConsumer.buttons.search", tableName: SDKConstants.kSDKLocalizable, bundle: AppConstants.sdkBundle, value: "Search", comment: "Title of the search button on the payment product screen.")
        let searchButtonFormRow = FormRowButton(title: searchButtonTitle, target: self, action: #selector(searchButtonTapped))
        searchButtonFormRow.isEnabled = self.hasLookup && self.failCount < 10 && !self.fullData
        self.formRows.insert(searchButtonFormRow, at: lastLookupIndex + 2)

        let enterManuallyButtonTitle = NSLocalizedString("gc.app.paymentProductDetails.searchConsumer.buttons.enterInformation", tableName: SDKConstants.kSDKLocalizable, bundle: AppConstants.sdkBundle, value: "Enter manually", comment: "Title of the enter manually button on the payment product screen.")
        let enterManuallyButtonFormRow = FormRowButton(title: enterManuallyButtonTitle, target: self, action: #selector(enterManuallyButtonTapped))
        enterManuallyButtonFormRow.buttonType = .secondary
        enterManuallyButtonFormRow.isEnabled = self.hasLookup && !self.didFind && !self.fullData
        self.formRows.insert(enterManuallyButtonFormRow, at: lastLookupIndex + 3)


        let paymentSeparator = FormRowSeparator(text: nil)
        paymentSeparator.isEnabled = true
        self.formRows.append(paymentSeparator)
        
        let termsAndConditionsIndex = self.formRows.index { (fr) -> Bool in
            if let switchRow = fr as? FormRowSwitch {
                return switchRow.field?.identifier == "termsAndConditions"
            }
            return false
        }
        if let termsAndConditionsIndex = termsAndConditionsIndex {
            let termsAndConditionsRow = self.formRows[termsAndConditionsIndex]
            termsAndConditionsRow.isEnabled = true
            self.formRows.remove(at: termsAndConditionsIndex)
            self.formRows.append(termsAndConditionsRow)
            
        }
        super.addExtraRows()
        let enumerator = (self.formRows as NSArray).reverseObjectEnumerator()
        enumerator.nextObject()
        //(enumerator.nextObject() as! FormRow).isEnabled = (!self.hasLookup  || self.didFind || self.fullData);

    }
    override func initializeFormRows() {
        super.initializeFormRows()
        var propertyNum = 0
        let enumerator = (self.formRows as NSArray).objectEnumerator()
        var row = enumerator.nextObject()
        var newFormRows: [FormRow] = []
        self.installmentPlanFields = 0;
        var labels: [FormRow] = []
        while (row != nil) {
            if (!(row is FormRowLabel || row is FormRowSwitch)) {
                row = enumerator.nextObject();
                continue;
            }
            var propertyRows: [FormRow] = []
            var label = row as! FormRow;
            labels.append(label)
            row = enumerator.nextObject()
            while row != nil && !(row is FormRowLabel || row is FormRowSwitch) {
                propertyRows.append(row as! FormRow)
                row = enumerator.nextObject()
            }
            var item = self.inputData.paymentItem.fields.paymentProductFields[propertyNum]
            if item.identifier == "installmentId" {
                
                installmentPlanFields = propertyRows.count + 1
                let separator = FormRowSeparator(text: nil)
                separator.isEnabled = true
                
                newFormRows.insert(contentsOf: propertyRows, at: 0)
                
                newFormRows.insert(label, at: 0)
                
            }
            else if (item.usedForLookup) {
                newFormRows.insert(contentsOf: propertyRows, at: installmentPlanFields)
                newFormRows.insert(label, at: installmentPlanFields)
            }
            else {
                newFormRows.append(label)
                newFormRows.append(contentsOf: propertyRows.lazy.reversed())
            }
            if hasLookup && !didFind {
                let isVisible = item.usedForLookup && !self.fullData || item.identifier == "installmentId"
                label.isEnabled = isVisible
                for nonLabelRow in propertyRows {
                    nonLabelRow.isEnabled = isVisible;
                }
            }
            else {
                let isVisible = !fullData || item.identifier == "installmentId"
                label.isEnabled = isVisible
                for nonLabelRow in propertyRows {
                    nonLabelRow.isEnabled = isVisible
                }
                if item.identifier == "termsAndConditions" {
                    if fullData {
                        label.isEnabled = true
                    }
                }
            }
            propertyNum += 1
        }
        for row in newFormRows {
            if let row = row as? FormRowList, row.items[0].value != "-1" && row.paymentProductField.identifier == "installmentId" {
                let placeHolderText = NSLocalizedString("gc.general.paymentProductFields.installmentId.placeholder", tableName: SDKConstants.kSDKLocalizable, bundle: AppConstants.sdkBundle, value: "Choose one", comment: "")
                let placeHolderItem = ValueMappingItem(json: ["displayName":placeHolderText, "value": "-1", "displayElements": []])!
                row.items.insert(placeHolderItem, at: 0)
                row.selectedRow = row.items.map({ $0.value }).index(of: inputData.value(forField: "installmentId")) ?? 0
                self.inputData.setValue(value: row.items[row.selectedRow].value, forField: "installmentId")
            }

        }
        if self.inputData.unmaskedValue(forField: "termsAndConditions").isEmpty {
            self.inputData.setValue(value: "false", forField: "termsAndConditions")
        }
        formRows = newFormRows
    }
    override func updateSwitchCell(_ cell: SwitchTableViewCell, row: FormRowSwitch) {
        guard let field = row.field else {
            return
        }
        
        if let error = field.errors.first {
            var customError: ValidationError = error
            if (field.identifier == "termsAndConditions") {
                for err in field.errors {
                    if err is ValidationErrorTermsAndConditions {
                        customError = err
                        break
                    }
                }
                //customError = field.errors.first(where: { (err) -> Bool in (err is ValidationErrorTermsAndConditions) }) ?? error
            }
            else {
                customError = error
            }
            cell.errorMessage = FormRowsConverter.errorMessage(for: customError, withCurrency: false)
        } else {
            cell.errorMessage = nil
        }
        
    }

    override func registerReuseIdentifiers() {
        super.registerReuseIdentifiers()
        tableView.register(DetailedPickerViewTableViewCell.self, forCellReuseIdentifier: DetailedPickerViewTableViewCell.reuseIdentifier)
        tableView.register(ReadonlyReviewCell.self, forCellReuseIdentifier: ReadonlyReviewCell.reuseIdentifier)
        tableView.register(SeparatorTableViewCell.self, forCellReuseIdentifier: SeparatorTableViewCell.reuseIdentifier)

    }
    override func cell(for row: FormRowList, tableView: UITableView) -> PickerViewTableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: DetailedPickerViewTableViewCell.reuseIdentifier) as! DetailedPickerViewTableViewCell
        
        cell.delegate = self
        cell.dataSource = self
        if let error = row.paymentProductField.errors.first, validation {
            cell.errorMessage = FormRowsConverter.errorMessage(for: error, withCurrency: false)
        }

        let currencyFormatter = NumberFormatter()
        currencyFormatter.numberStyle = .currency
        currencyFormatter.currencyCode = context.amountOfMoney.currencyCode.rawValue
        for m in row.items {
            guard let amount = m.displayElements.first(where: { $0.id == "installmentAmount" })?.value else {
                continue
            }
            guard let numberOfInstallments = m.displayElements.first(where: { $0.id == "numberOfInstallments" })?.value else {
                continue;
            }
            guard let amountAsDouble = Double(amount) else {
                continue
            }
            guard let amountAsString = currencyFormatter.string(from: NSNumber(value:amountAsDouble/100.0)) else {
                continue
            }
            let selectionTextWithPlaceholders = NSLocalizedString("gc.general.paymentProductFields.installmentPlan.selectionTextTemplate", tableName: SDKConstants.kSDKLocalizable, bundle: AppConstants.sdkBundle, value: "{installmentAmount} in {numberOfInstallments} installments", comment: "")
            let selectionTextWithPlaceholder = selectionTextWithPlaceholders.replacingOccurrences(of: "{installmentAmount}", with: "%@")
            let selectionTextValue = selectionTextWithPlaceholder.replacingOccurrences(of: "{numberOfInstallments}", with: "%@")
            let selectionMessage = String(format: selectionTextValue, amountAsString,numberOfInstallments)
            m.displayName = selectionMessage
            if let displayElementIndex = m.displayElements.index(where: { $0.id == "displayName" }) {
                m.displayElements[displayElementIndex].value = selectionMessage
            }
        }
        
        cell.items = row.items
        cell.fieldIdentifier = row.paymentProductField.identifier
        cell.currencyFormatter = currencyFormatter
        let percentFormatter = NumberFormatter()
        percentFormatter.numberStyle = .percent
        percentFormatter.locale = Locale(identifier: context.locale!)
        percentFormatter.minimumFractionDigits = 0
        percentFormatter.maximumFractionDigits = 3
        cell.percentFormatter = percentFormatter
        cell.selectedRow = row.selectedRow
        
        return cell
    }
    func cell(for row: FormRowReadonlyReview, tableView: UITableView) -> ReadonlyReviewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ReadonlyReviewCell.reuseIdentifier) as! ReadonlyReviewCell

        cell.data = row.data
        
        return cell
    }
    func cell(for row: FormRowSeparator, tableView: UITableView) -> SeparatorTableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SeparatorTableViewCell.reuseIdentifier) as! SeparatorTableViewCell
        
        cell.separatorText = row.text as NSString?
        return cell
    }

    override func formRowCell(for row: FormRow, indexPath: IndexPath) -> UITableViewCell {
        var cell: TableViewCell?
        if let formRow = row as? FormRowReadonlyReview {
            cell = self.cell(for: formRow, tableView: tableView) as TableViewCell
        }
        else if let formRow = row as? FormRowSeparator {
            cell = self.cell(for: formRow, tableView: tableView)
        }
        else {
            cell = super.formRowCell(for: row, indexPath: indexPath) as? TableViewCell
        }
        return cell!
    }
}
