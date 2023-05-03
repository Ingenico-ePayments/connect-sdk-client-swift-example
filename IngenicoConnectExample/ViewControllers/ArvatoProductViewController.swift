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

    override init(
        paymentItem: PaymentItem,
        session: Session,
        context: PaymentContext,
        accountOnFile: AccountOnFile?
    ) {
        super.init(
            paymentItem: paymentItem,
            session: session,
            context: context,
            accountOnFile: accountOnFile
        )
        self.hasLookup = paymentItem.fields.paymentProductFields.map { (field) -> Bool in
            return field.usedForLookup
            }.contains(true)
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let row = formRows[indexPath.row]

        if !row.isEnabled {
            return 0
        }

        if let row = row as? FormRowList {
            var max: CGFloat = 0

            max =
                CGFloat(row.items[row.selectedRow].displayElements.filter { $0.id != "displayName" }.count) *
                    (UIFont.systemFontSize + 2)
            // Add distance between error message and description
            if max > 0 {
                 max += 10
            }
            let width = min(320, tableView.bounds.width - 20)
            var errorHeight: CGFloat = 0
            if let firstError = row.paymentProductField.errors.first, validation {
                let str =
                    NSAttributedString(string: FormRowsConverter.errorMessage(for: firstError, withCurrency: false))
                errorHeight =
                    str.boundingRect(
                        with: CGSize.init(width: width, height: CGFloat.infinity),
                        options: .usesLineFragmentOrigin, context: nil
                    ).height + 10
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
        // let enabledRows = self.formRows.filter { (fr) -> Bool in
        //    fr.isEnabled
        // }
        let values = self.inputData.paymentItem.fields.paymentProductFields.filter { (field) -> Bool in
            field.usedForLookup
        }.map { (field) -> (String, String) in
            (field.identifier, self.inputData.value(forField: field.identifier))
        }
        var params: [[String: String]] = []
        for (key, value) in values {
            var param: [String: String] = [:]
            param["key"] = key
            param["value"] = value
            params.append(param)
        }
        self.session.customerDetails(
            forProductId: self.initialPaymentProduct?.identifier ?? "",
            withLookupValues: params,
            countryCode: self.context.countryCode,
            success: { (customerDetails: CustomerDetails) in
                self.didFind = true
                self.validation = true
                let installmentId = self.inputData.fieldValues["installmentId"]
                let termsAndConditions = self.inputData.fieldValues["termsAndConditions"]
                let lookupIdentifiers =
                    self.initialPaymentProduct?.fields.paymentProductFields.first(
                        where: {$0.usedForLookup}
                    ).map({$0.identifier})
                let lookupFields = self.inputData.fieldValues.filter { lookupIdentifiers?.contains($0.key) ?? false }
                self.inputData.fieldValues.removeAll()
                for (id, val) in lookupFields {
                    self.inputData.setValue(value: val, forField: id)
                }
                self.inputData.setValue(value: installmentId ?? "", forField: "installmentId")
                self.inputData.setValue(value: termsAndConditions ?? "", forField: "termsAndConditions")

                for (key, value) in customerDetails.values {
                    self.inputData.setValue(value: value, forField: key)
                }
                self.inputData.validateExcept(fieldNames: Set(["termsAndConditions", "installmentId"]))
                if self.inputData.errors.count == 0 {
                    self.fullData = true
                }
                self.reload()
            },
            failure: { (err) in
                if let err = err as? CustomerDetailsError {
                    let details = err.responseValues[0]
                    let id = details["id"] as? String ?? ""

                    if self.failCount >= 10 {
                        self.errorMessageText =
                            NSLocalizedString(
                                "gc.app.paymentProductDetails.searchConsumer.result.failed.tooMuch",
                                tableName: SDKConstants.kSDKLocalizable,
                                bundle: AppConstants.sdkBundle,
                                value:
                                    """
                                    No result found. You have reached the maximum amount of tries.
                                    Please enter your details manually.
                                    """,
                                comment: "Title of the search button on the payment product screen."
                            )
                    } else if id == "PARAMETER_NOT_FOUND_IN_REQUEST" {
                        self.errorMessageText =
                            NSLocalizedString(
                                "gc.app.paymentProductDetails.searchConsumer.result.failed.errors.missingValue",
                                tableName: SDKConstants.kSDKLocalizable,
                                bundle: AppConstants.sdkBundle,
                                value:
                                    """
                                    No result found. You have reached the maximum amount of tries.
                                    Please enter your details manually.
                                    """,
                                comment: "Title of the search button on the payment product screen."
                            )
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
                        // swiftlint:disable line_length
                        var labelKey = "gc.general.paymentProducts.\(self.paymentItem.identifier).paymentProductFields.\(property).label"
                        // swiftlint:enable line_length
                        var labelValue =
                            NSLocalizedString(
                                labelKey,
                                tableName: SDKConstants.kSDKLocalizable,
                                bundle: AppConstants.sdkBundle,
                                value: labelKey,
                                comment: "Title of the search button on the payment product screen."
                            )
                        if labelKey == labelValue {
                            labelKey = "gc.general.paymentProductFields.\(property).label"
                            labelValue =
                                NSLocalizedString(
                                    labelKey,
                                    tableName: SDKConstants.kSDKLocalizable,
                                    bundle: AppConstants.sdkBundle,
                                    value:
                                        """
                                        No result found. You have reached the maximum amount of tries.
                                        Please enter your details manually.
                                        """,
                                    comment: "Title of the search button on the payment product screen."
                                )
                        }
                        self.errorMessageText =
                            self.errorMessageText.replacingOccurrences(of: "{propertyName}", with: labelValue)
                    } else {
                        self.errorMessageText =
                            NSLocalizedString(
                                "gc.app.paymentProductDetails.searchConsumer.result.failed.invalidData",
                                tableName: SDKConstants.kSDKLocalizable,
                                bundle: AppConstants.sdkBundle,
                                value:
                                    """
                                    No result found. You have reached the maximum amount of tries.
                                    Please enter your details manually.
                                    """,
                                comment: "Title of the search button on the payment product screen."
                            )
                    }
                }
                self.failCount += 1
                self.didFind = false
                self.reload()
            }
        )
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
        let label = getLabel()
        self.formRows.insert(label, at: self.installmentPlanFields)

        let labelFormRowTooltip = getLabelTooltip()
        label.tooltip = labelFormRowTooltip
        self.formRows.insert(labelFormRowTooltip, at: self.installmentPlanFields + 1)

        self.formRows.insert(getSeparator(), at: self.installmentPlanFields)
        self.formRows.append(getReadonlyReview())

        // 'Edit information' and 'Search Again' button
        self.formRows.append(getSearchAgainButton())
        self.formRows.append(getEditInformationButton())

        let lastLookupIndex = getLastLookupIndex()

        self.formRows.insert(getBadMessageEarlyLabel(), at: lastLookupIndex + 1)

        // Add search and 'enter manually' button
        self.formRows.insert(getSearchButton(), at: lastLookupIndex + 2)
        self.formRows.insert(getEnterManuallyButton(), at: lastLookupIndex + 3)

        self.formRows.append(getPaymentSeparator())

        self.addTermsAndConditions()

        super.addExtraRows()
        let enumerator = (self.formRows as NSArray).reverseObjectEnumerator()
        enumerator.nextObject()
        // (enumerator.nextObject() as! FormRow).isEnabled = (!self.hasLookup  || self.didFind || self.fullData);
    }

    private func getLabel() -> FormRowLabel {
        let labelText =
            NSLocalizedString(
                "gc.app.paymentProductDetails.searchConsumer.label",
                tableName: SDKConstants.kSDKLocalizable,
                bundle: AppConstants.sdkBundle,
                value: "Your billing details",
                comment: ""
            )
        let label = FormRowLabel(text: labelText)
        label.isEnabled = self.hasLookup
        label.isBold = true

        return label
    }

    private func getLabelTooltip() -> FormRowTooltip {
        let labelFormRowTooltip = FormRowTooltip()
        labelFormRowTooltip.text =
            NSLocalizedString(
                "gc.app.paymentProductDetails.searchConsumer.tooltipText",
                tableName: SDKConstants.kSDKLocalizable,
                bundle: AppConstants.sdkBundle,
                value: "",
                comment: ""
            )

        return labelFormRowTooltip
    }

    private func getSeparator() -> FormRowSeparator {
        let separator = FormRowSeparator(text: nil)
        separator.isEnabled = self.installmentPlanFields > 0

        return separator
    }

    private func getReadonlyReview() -> FormRowReadonlyReview {
        let reviewRow = FormRowReadonlyReview()
        var filteredData: [String: String] = [:]
        for (key, value) in self.inputData.fieldValues where
             key != "installmentPlan" &&
             paymentItem.fields.paymentProductFields.contains(where: {$0.identifier == key}) {
                 filteredData[key] = value
        }

        reviewRow.data = filteredData
        reviewRow.isEnabled = fullData

        return reviewRow
    }

    private func getEditInformationButton() -> FormRowButton {
        let editInformationButtonTitle =
            NSLocalizedString(
                "gc.app.paymentProductDetails.searchConsumer.buttons.editInformation",
                tableName: SDKConstants.kSDKLocalizable,
                bundle: AppConstants.sdkBundle,
                value: "Search",
                comment: "Title of the search button on the payment product screen."
            )
        let editInformationButtonFormRow =
            FormRowButton(
                title: editInformationButtonTitle,
                target: self,
                action: #selector(editInformationButtonTapped)
            )
        editInformationButtonFormRow.isEnabled =  fullData && (failCount < 10 || didFind)
        editInformationButtonFormRow.buttonType = .secondary

        return editInformationButtonFormRow
    }

    private func getSearchAgainButton() -> FormRowButton {
        let searchAgainButtonTitle =
            NSLocalizedString(
                "gc.app.paymentProductDetails.searchConsumer.buttons.searchAgain",
                tableName: SDKConstants.kSDKLocalizable,
                bundle: AppConstants.sdkBundle,
                value: "Enter manually",
                comment: "Title of the enter manually button on the payment product screen."
            )
        let searchAgainButtonFormRow =
            FormRowButton(title: searchAgainButtonTitle, target: self, action: #selector(searchAgainButtonTapped))
        searchAgainButtonFormRow.buttonType = .primary
        _ = paymentItem.fields.paymentProductFields.map { (field) -> Bool in
            return field.usedForLookup
            }.contains(true)
        searchAgainButtonFormRow.isEnabled = hasLookup && fullData && failCount < 10

        return searchAgainButtonFormRow
    }

    private func getLastLookupIndex() -> Int {
        var lastLookupIndex = 0
        var index = -1
        for formRow in self.formRows {
            index += 1

            switch formRow {
            case let formRowSwitch as FormRowSwitch:
                if formRowSwitch.field?.usedForLookup ?? false {
                    lastLookupIndex = index
                }
            case let formRowWithProductField as FormRowWithProductField:
                if formRowWithProductField.paymentProductField.usedForLookup {
                    lastLookupIndex = index
                }
            case let formRowWithInfoButtonProductField as FormRowWithInfoButtonProductField:
                if formRowWithInfoButtonProductField.paymentProductField.usedForLookup {
                    lastLookupIndex = index
                }
            case _ as FormRowWithInfoButton:
                if self.formRows[index + 1] is FormRowTooltip {
                    lastLookupIndex += 1
                }
            default: break
            }
        }

        return lastLookupIndex
    }

    private func getBadMessageEarlyLabel() -> FormRowLabel {
        let badMessageTitleEarly = self.errorMessageText

        let badMessageEarlyRow = FormRowLabel(text: badMessageTitleEarly)
        badMessageEarlyRow.isEnabled = hasLookup && !didFind && !fullData && failCount > 0 && failCount < 10

        return badMessageEarlyRow
    }

    private func getSearchButton() -> FormRowButton {
        let searchButtonTitle =
            NSLocalizedString(
                "gc.app.paymentProductDetails.searchConsumer.buttons.search",
                tableName: SDKConstants.kSDKLocalizable,
                bundle: AppConstants.sdkBundle,
                value: "Search",
                comment: "Title of the search button on the payment product screen."
            )
        let searchButtonFormRow =
            FormRowButton(title: searchButtonTitle, target: self, action: #selector(searchButtonTapped))
        searchButtonFormRow.isEnabled = self.hasLookup && self.failCount < 10 && !self.fullData

        return searchButtonFormRow
    }

    private func getEnterManuallyButton() -> FormRowButton {
        let enterManuallyButtonTitle =
            NSLocalizedString(
                "gc.app.paymentProductDetails.searchConsumer.buttons.enterInformation",
                tableName: SDKConstants.kSDKLocalizable,
                bundle: AppConstants.sdkBundle,
                value: "Enter manually",
                comment: "Title of the enter manually button on the payment product screen."
            )
        let enterManuallyButtonFormRow =
            FormRowButton(title: enterManuallyButtonTitle, target: self, action: #selector(enterManuallyButtonTapped))
        enterManuallyButtonFormRow.buttonType = .secondary
        enterManuallyButtonFormRow.isEnabled = self.hasLookup && !self.didFind && !self.fullData

        return enterManuallyButtonFormRow
    }

    private func getPaymentSeparator() -> FormRowSeparator {
        let paymentSeparator = FormRowSeparator(text: nil)
        paymentSeparator.isEnabled = true

        return paymentSeparator
    }

    private func addTermsAndConditions() {
        let termsAndConditionsIndex = self.formRows.firstIndex { (formRow) -> Bool in
            if let switchRow = formRow as? FormRowSwitch {
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
    }

    override func initializeFormRows() {
        super.initializeFormRows()
        self.installmentPlanFields = 0

        var newFormRows = getNewFormRows()

        for row in newFormRows {
            if let row = row as? FormRowList,
               row.items[0].value != "-1" && row.paymentProductField.identifier == "installmentId" {
                let placeHolderText =
                    NSLocalizedString(
                        "gc.general.paymentProductFields.installmentId.placeholder",
                        tableName: SDKConstants.kSDKLocalizable,
                        bundle: AppConstants.sdkBundle,
                        value: "Choose one",
                        comment: ""
                    )
                let placeHolderItem =
                    ValueMappingItem(json: ["displayName": placeHolderText, "value": "-1", "displayElements": []])!
                row.items.insert(placeHolderItem, at: 0)
                row.selectedRow = row.items.map({ $0.value }).firstIndex(
                    of: inputData.value(forField: "installmentId")
                ) ?? 0
                self.inputData.setValue(value: row.items[row.selectedRow].value, forField: "installmentId")
            }

        }
        if self.inputData.unmaskedValue(forField: "termsAndConditions").isEmpty {
            self.inputData.setValue(value: "false", forField: "termsAndConditions")
        }
        formRows = newFormRows
    }

    private func getNewFormRows() -> [FormRow] {
        var propertyNum = 0
        let enumerator = (self.formRows as NSArray).objectEnumerator()
        var row = enumerator.nextObject()
        var newFormRows: [FormRow] = []
        var labels: [FormRow] = []

        while row != nil {
            if !(row is FormRowLabel || row is FormRowSwitch) {
                row = enumerator.nextObject()
                continue
            }
            var propertyRows: [FormRow] = []

            guard let label = row as? FormRow else {
                fatalError("Could not cast row to FormRow")
            }
            labels.append(label)
            row = enumerator.nextObject()
            while row != nil && !(row is FormRowLabel || row is FormRowSwitch) {
                guard let formRow = row as? FormRow else {
                    fatalError("Could not cast row to FormRow")
                }
                propertyRows.append(formRow)
                row = enumerator.nextObject()
            }
            let item = self.inputData.paymentItem.fields.paymentProductFields[propertyNum]
            if item.identifier == "installmentId" {

                installmentPlanFields = propertyRows.count + 1
                let separator = FormRowSeparator(text: nil)
                separator.isEnabled = true

                newFormRows.insert(contentsOf: propertyRows, at: 0)

                newFormRows.insert(label, at: 0)

            } else if item.usedForLookup {
                newFormRows.insert(contentsOf: propertyRows, at: installmentPlanFields)
                newFormRows.insert(label, at: installmentPlanFields)
            } else {
                newFormRows.append(label)
                newFormRows.append(contentsOf: propertyRows.lazy.reversed())
            }
            if hasLookup && !didFind {
                let isVisible = item.usedForLookup && !self.fullData || item.identifier == "installmentId"
                label.isEnabled = isVisible
                setRowEnabled(propertyRows: propertyRows, isVisible: isVisible)
            } else {
                let isVisible = !fullData || item.identifier == "installmentId"
                label.isEnabled = isVisible
                setRowEnabled(propertyRows: propertyRows, isVisible: isVisible)
                if item.identifier == "termsAndConditions" && fullData {
                    label.isEnabled = true
                }
            }
            propertyNum += 1
        }

        return newFormRows
    }

    private func setRowEnabled(propertyRows: [FormRow], isVisible: Bool) {
        for nonLabelRow in propertyRows {
            nonLabelRow.isEnabled = isVisible
        }
    }

    override func updateSwitchCell(_ cell: SwitchTableViewCell, row: FormRowSwitch) {
        guard let field = row.field else {
            return
        }

        if let error = field.errors.first {
            var customError: ValidationError = error
            if field.identifier == "termsAndConditions" {
                for err in field.errors where err is ValidationErrorTermsAndConditions {
                    customError = err
                    break
                }
            } else {
                customError = error
            }
            cell.errorMessage = FormRowsConverter.errorMessage(for: customError, withCurrency: false)
        } else {
            cell.errorMessage = nil
        }

    }

    override func registerReuseIdentifiers() {
        super.registerReuseIdentifiers()
        tableView.register(
            DetailedPickerViewTableViewCell.self,
            forCellReuseIdentifier: DetailedPickerViewTableViewCell.reuseIdentifier
        )
        tableView.register(ReadonlyReviewCell.self, forCellReuseIdentifier: ReadonlyReviewCell.reuseIdentifier)
        tableView.register(SeparatorTableViewCell.self, forCellReuseIdentifier: SeparatorTableViewCell.reuseIdentifier)
    }

    override func cell(for row: FormRowList, tableView: UITableView) -> PickerViewTableViewCell {
        guard let cell =
            tableView.dequeueReusableCell(
                withIdentifier: DetailedPickerViewTableViewCell.reuseIdentifier
            ) as? DetailedPickerViewTableViewCell else {
             fatalError("Could not cast cell to DetailedPickerViewTableViewCell")
        }

        cell.delegate = self
        cell.dataSource = self
        if let error = row.paymentProductField.errors.first, validation {
            cell.errorMessage = FormRowsConverter.errorMessage(for: error, withCurrency: false)
        }

        let currencyFormatter = NumberFormatter()
        currencyFormatter.numberStyle = .currency
        currencyFormatter.currencyCode = context.amountOfMoney.currencyCodeString
        for valueMappingItem in row.items {
            guard let amount =
                    valueMappingItem.displayElements.first(where: { $0.id == "installmentAmount" })?.value else {
                continue
            }
            guard let numberOfInstallments =
                    valueMappingItem.displayElements.first(where: { $0.id == "numberOfInstallments" })?.value else {
                continue
            }
            guard let amountAsDouble = Double(amount) else {
                continue
            }
            guard let amountAsString = currencyFormatter.string(from: NSNumber(value: amountAsDouble/100.0)) else {
                continue
            }
            let selectionTextWithPlaceholders =
                NSLocalizedString(
                    "gc.general.paymentProductFields.installmentPlan.selectionTextTemplate",
                    tableName: SDKConstants.kSDKLocalizable,
                    bundle: AppConstants.sdkBundle,
                    value: "{installmentAmount} in {numberOfInstallments} installments",
                    comment: ""
                )
            let selectionTextWithPlaceholder =
                selectionTextWithPlaceholders.replacingOccurrences(of: "{installmentAmount}", with: "%@")
            let selectionTextValue =
                selectionTextWithPlaceholder.replacingOccurrences(of: "{numberOfInstallments}", with: "%@")
            let selectionMessage = String(format: selectionTextValue, amountAsString, numberOfInstallments)
            valueMappingItem.displayName = selectionMessage
            if let displayElementIndex = valueMappingItem.displayElements.index(where: { $0.id == "displayName" }) {
                valueMappingItem.displayElements[displayElementIndex].value = selectionMessage
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
        guard let cell =
            tableView.dequeueReusableCell(
                withIdentifier: ReadonlyReviewCell.reuseIdentifier
            ) as? ReadonlyReviewCell else {
             fatalError("Could not cast cell to ReadonlyReviewCell")
        }

        cell.data = row.data

        return cell
    }

    func cell(for row: FormRowSeparator, tableView: UITableView) -> SeparatorTableViewCell {
        guard let cell =
            tableView.dequeueReusableCell(
                withIdentifier: SeparatorTableViewCell.reuseIdentifier
            ) as? SeparatorTableViewCell else {
             fatalError("Could not cast cell to SeparatorTableViewCell")
        }

        cell.separatorText = row.text as NSString?
        return cell
    }

    override func formRowCell(for row: FormRow, indexPath: IndexPath) -> UITableViewCell {
        var cell: TableViewCell?
        if let formRow = row as? FormRowReadonlyReview {
            cell = self.cell(for: formRow, tableView: tableView) as TableViewCell
        } else if let formRow = row as? FormRowSeparator {
            cell = self.cell(for: formRow, tableView: tableView)
        } else {
            cell = super.formRowCell(for: row, indexPath: indexPath) as? TableViewCell
        }
        return cell!
    }
}
