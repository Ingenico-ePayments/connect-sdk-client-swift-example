//
//  FormRowsConverter.swift
//  IngenicoConnectExample
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2016 Global Collect Services. All rights reserved.
//

import Foundation
import IngenicoConnectKit

class FormRowsConverter {
    
    func formRows(from inputData: PaymentProductInputData, viewFactory: ViewFactory, confirmedPaymentProducts: Set<String>) -> [FormRow] {
        var rows: [FormRow] = []
        let paymentProductFields = inputData.paymentItem.fields.paymentProductFields

        for field in paymentProductFields {
            let isPartOfAccountOnFile = inputData.fieldIsPartOfAccountOnFile(paymentProductFieldId: field.identifier)
            let value: String
            let isEnabled: Bool

            if isPartOfAccountOnFile {
                let mask = field.displayHints.mask
                value = inputData.accountOnFile.maskedValue(forField: field.identifier, mask: mask)
                isEnabled = !inputData.fieldIsReadOnly(paymentProductFieldId: field.identifier)
            }
            else {
                value = inputData.maskedValue(forField: field.identifier)
                isEnabled = true
            }
            
            var row: FormRow = labelFormRow(from: field, paymentProduct: inputData.paymentItem.identifier, viewFactory: viewFactory)
            rows.append(row)
            
            switch field.displayHints.formElement.type {
                case .listType:
                    row = listFormRow(from: field, value: value , isEnabled: isEnabled, viewFactory: viewFactory)
                case .textType:
                    row = textFieldFormRow(from: field, paymentItem: inputData.paymentItem, value: value , isEnabled: isEnabled, confirmedPaymentProducts: confirmedPaymentProducts, viewFactory: viewFactory)
                case .currencyType:
                    row = currencyFormRow(from: field, paymentItem: inputData.paymentItem, value: value , isEnabled: isEnabled, viewFactory: viewFactory)
                case .dateType:
                    row = dateFormRow(from: field, paymentItem: inputData.paymentItem, value: value, isEnabled: isEnabled, viewFactory: viewFactory)
                    break
                case .boolType:
                    rows.removeLast()
                    row = switchFormRow(from: field, paymentItem: inputData.paymentItem, value: value, isEnabled: isEnabled, viewFactory: viewFactory)
                    break

            }

            rows.append(row)
        }

        return rows
    }
    
    func error(withIINDetails iinDetailsResponse: IINDetailsResponse) -> ValidationError? {
        if iinDetailsResponse.status == IINStatus.existingButNotAllowed {
            return ValidationErrorAllowed()
        }
        else if iinDetailsResponse.status == IINStatus.unknown {
            return ValidationErrorLuhn()
        }
        return nil
    }
    
    static func errorMessage(for error: ValidationError, withCurrency: Bool) -> String {
        let errorClass = error.self
        let errorMessageFormat = "gc.general.paymentProductFields.validationErrors.%@.label"
        var errorMessageKey: String
        var errorMessageValue: String
        var errorMessage: String
        if let lengthError = errorClass as? ValidationErrorLength {
            if (lengthError.minLength == lengthError.maxLength) {
                errorMessageKey = String(format: errorMessageFormat, "length.exact");
            } else if (lengthError.minLength == 0 && lengthError.maxLength > 0) {
                errorMessageKey = String(format: errorMessageFormat, "length.max");
            } else if (lengthError.minLength > 0 && lengthError.maxLength > 0) {
                errorMessageKey = String(format: errorMessageFormat, "length.between");
            } else {
                // this case never happens
                errorMessageKey = ""
            }
            
            let errorMessageValueWithPlaceholders = NSLocalizedString(errorMessageKey, tableName: SDKConstants.kSDKLocalizable, bundle: AppConstants.sdkBundle, value: "", comment: "")
            let errorMessageValueWithPlaceholder = errorMessageValueWithPlaceholders.replacingOccurrences(of: "{maxLength}", with: String(lengthError.maxLength))
            errorMessage = errorMessageValueWithPlaceholder.replacingOccurrences(of: "{minLength}", with: String(lengthError.minLength))
        } else if let rangeError = errorClass as? ValidationErrorRange {
            errorMessageKey = String(format: errorMessageFormat, "length.between")
            let errorMessageValueWithPlaceholders = NSLocalizedString(errorMessageKey, tableName: SDKConstants.kSDKLocalizable, bundle: AppConstants.sdkBundle, value: "", comment: "")
            var minString = ""
            var maxString = ""
            if withCurrency {
                minString = String(format: "%.2f", Double(rangeError.minValue) / 100)
                maxString = String(format: "%.2f", Double(rangeError.maxValue) / 100)
            }
            else {
                minString = "\(Int(rangeError.minValue))"
                maxString = "\(Int(rangeError.maxValue))"
            }
            let errorMessageValueWithPlaceholder = errorMessageValueWithPlaceholders.replacingOccurrences(of: "{maxValue}", with: String(maxString))
            errorMessage = errorMessageValueWithPlaceholder.replacingOccurrences(of: "{minValue}", with: String(minString))
        } else if errorClass is ValidationErrorExpirationDate {
            errorMessageKey = String(format: errorMessageFormat, "expirationDate")
            errorMessageValue = NSLocalizedString(errorMessageKey, tableName: SDKConstants.kSDKLocalizable, bundle: AppConstants.sdkBundle, value: "", comment: "")
            errorMessage = errorMessageValue
        }
        else if errorClass is ValidationErrorFixedList {
            errorMessageKey = String(format: errorMessageFormat, "fixedList")
            errorMessageValue = NSLocalizedString(errorMessageKey, tableName: SDKConstants.kSDKLocalizable, bundle: AppConstants.sdkBundle, value: "", comment: "")
            errorMessage = errorMessageValue
        }
        else if errorClass is ValidationErrorLuhn {
            errorMessageKey = String(format: errorMessageFormat, "luhn")
            errorMessageValue = NSLocalizedString(errorMessageKey, tableName: SDKConstants.kSDKLocalizable, bundle: AppConstants.sdkBundle, value: "", comment: "")
            errorMessage = errorMessageValue
        }
        else if errorClass is ValidationErrorAllowed {
            errorMessageKey = String(format: errorMessageFormat, "allowedInContext")
            errorMessageValue = NSLocalizedString(errorMessageKey, tableName: SDKConstants.kSDKLocalizable, bundle: AppConstants.sdkBundle, value: "", comment: "")
            errorMessage = errorMessageValue
        }
        else if errorClass is ValidationErrorRegularExpression {
            errorMessageKey = String(format: errorMessageFormat, "regularExpression")
            errorMessageValue = NSLocalizedString(errorMessageKey, tableName: SDKConstants.kSDKLocalizable, bundle: AppConstants.sdkBundle, value: "", comment: "")
            errorMessage = errorMessageValue
        }
        else if errorClass is ValidationErrorTermsAndConditions {
            errorMessageKey = String(format: errorMessageFormat, "termsAndConditions")
            errorMessageValue = NSLocalizedString(errorMessageKey, tableName: SDKConstants.kSDKLocalizable, bundle: AppConstants.sdkBundle, value: "", comment: "")
            errorMessage = errorMessageValue
        }
        else if errorClass is ValidationErrorIsRequired {
            errorMessageKey = String(format: errorMessageFormat, "required")
            errorMessageValue = NSLocalizedString(errorMessageKey, tableName: SDKConstants.kSDKLocalizable, bundle: AppConstants.sdkBundle, value: "", comment: "")
            errorMessage = errorMessageValue
        }
        else if errorClass is ValidationErrorIBAN {
            errorMessageKey = String(format: errorMessageFormat, "regularExpression")
            errorMessageValue = NSLocalizedString(errorMessageKey, tableName: SDKConstants.kSDKLocalizable, bundle: AppConstants.sdkBundle, value: "", comment: "")
            errorMessage = errorMessageValue
        }
        else if errorClass is ValidationErrorEmailAddress {
            errorMessageKey = String(format: errorMessageFormat, "emailAddress")
            errorMessageValue = NSLocalizedString(errorMessageKey, tableName: SDKConstants.kSDKLocalizable, bundle: AppConstants.sdkBundle, value: "", comment: "")
            errorMessage = errorMessageValue
        }
        else {
            errorMessage = ""
            NSException(name: NSExceptionName(rawValue: "Invalid validation error"), reason: "Validation error \(error) is invalid", userInfo: nil).raise()
        }
        
        return errorMessage
    }
    
    func textFieldFormRow(from field: PaymentProductField, paymentItem: PaymentItem, value: String, isEnabled: Bool, confirmedPaymentProducts: Set<String>?, viewFactory: ViewFactory) -> FormRowTextField {
        
        var placeholderKey = "gc.general.paymentProducts.\(paymentItem.identifier).paymentProductFields.\(field.identifier).placeholder"
        var placeholderValue = NSLocalizedString(placeholderKey, tableName: SDKConstants.kSDKLocalizable, bundle: AppConstants.sdkBundle, value: "", comment: "")
        if placeholderKey == placeholderValue {
            placeholderKey = "gc.general.paymentProductFields.\(field.identifier).placeholder"
            placeholderValue = NSLocalizedString(placeholderKey, tableName: SDKConstants.kSDKLocalizable, bundle: AppConstants.sdkBundle, value: "", comment: "")
        }

        let keyboardType: UIKeyboardType
        switch field.displayHints.preferredInputType {
        case .integerKeyboard:
            keyboardType = .numberPad

        case .emailAddressKeyboard:
            keyboardType = .emailAddress

        case .phoneNumberKeyboard:
            keyboardType = .phonePad
            
        case .stringKeyboard, .noKeyboard, .dateKeyboard:
            keyboardType = .default
        }
        
        let formField = FormRowField(text: value, placeholder: placeholderValue, keyboardType: keyboardType, isSecure: field.displayHints.obfuscate)
        let row = FormRowTextField(paymentProductField: field, field: formField)
        row.isEnabled = isEnabled
        
        if field.identifier == "cardNumber" {
            if let confirmedPaymentProducts = confirmedPaymentProducts, confirmedPaymentProducts.contains(paymentItem.identifier) {
                row.logo = paymentItem.displayHints.logoImage
            } else {
                row.logo = nil
            }
        }
        
        setTooltipForFormRow(row, with: field, paymentItem: paymentItem)
        
        return row
    }
    
    func currencyFormRow(from field: PaymentProductField, paymentItem: PaymentItem, value: String, isEnabled: Bool, viewFactory: ViewFactory) -> FormRowCurrency {

        var placeholderKey = "gc.general.paymentProducts.\(paymentItem.identifier).paymentProductFields.\(field.identifier).placeholder"
        var placeholderValue = NSLocalizedString(placeholderKey, tableName: SDKConstants.kSDKLocalizable, bundle: AppConstants.sdkBundle, value: "", comment: "")
        if placeholderKey == placeholderValue {
            placeholderKey = "gc.general.paymentProductFields.\(field.identifier).placeholder"
            placeholderValue = NSLocalizedString(placeholderKey, tableName: SDKConstants.kSDKLocalizable, bundle: AppConstants.sdkBundle, value: "", comment: "")
        }

        let keyboardType: UIKeyboardType
        switch field.displayHints.preferredInputType {
            case .integerKeyboard:
                keyboardType = .numberPad

            case .emailAddressKeyboard:
                keyboardType = .emailAddress

            case .phoneNumberKeyboard:
                keyboardType = .phonePad
            
            case .stringKeyboard, .noKeyboard, .dateKeyboard:
                keyboardType = .default
        }

        let integerPart = Int((Double(value) ?? 0) / 100)
        let fractionalPart = Int(llabs((Int64(value) ?? 0) % 100))

        let integerField =  FormRowField(text: "\(integerPart)", placeholder: placeholderValue, keyboardType: keyboardType, isSecure: field.displayHints.obfuscate)
        let fractionalField =  FormRowField(text: String(format: "%02d", fractionalPart), placeholder: "", keyboardType: keyboardType, isSecure: field.displayHints.obfuscate)
        
        let row = FormRowCurrency(paymentProductField: field, integerField: integerField, fractionalField: fractionalField)

        row.integerField = integerField
        row.fractionalField = fractionalField
        row.isEnabled = isEnabled

        setTooltipForFormRow(row, with: field, paymentItem: paymentItem)
        
        return row
    }
    
    func switchFormRow(from field: PaymentProductField, paymentItem: PaymentItem, value: String, isEnabled: Bool, viewFactory: ViewFactory) -> FormRowSwitch {
        
        let descriptionKey = String(format: "gc.general.paymentProducts.%@.paymentProductFields.%@.label", paymentItem.identifier, field.identifier)
        let descriptionValue = NSLocalizedString(descriptionKey, tableName: SDKConstants.kSDKLocalizable, bundle: AppConstants.sdkBundle, value: "", comment: "Accept {link}")
        let labelKey = String(format: "gc.general.paymentProducts.%@.paymentProductFields.%@.link.label", paymentItem.identifier, field.identifier)
        let labelValue = NSLocalizedString(labelKey, tableName: SDKConstants.kSDKLocalizable, bundle: AppConstants.sdkBundle, value: "", comment: "AfterPay")
        let nsDescriptionValue = descriptionValue as NSString
        let range = nsDescriptionValue.range(of: "{link}")
        let attrString = NSMutableAttributedString(string: descriptionValue)
        let linkString = NSAttributedString(string: labelValue, attributes: [NSLinkAttributeName: (field.displayHints.link?.absoluteString ?? "")])
        if range.length > 0 {
            attrString.replaceCharacters(in: range , with: linkString)
        }
        
        let row = FormRowSwitch(title: attrString, isOn: value == "true", target: nil, action: nil, paymentProductField: field)
        row.isEnabled = isEnabled;
        
        return row;
    }
    
    func dateFormRow(from field: PaymentProductField, paymentItem:PaymentItem, value:String, isEnabled: Bool, viewFactory: ViewFactory) -> FormRowDate {
        let row = FormRowDate(paymentProductField: field, value: value)
        row.isEnabled = isEnabled;
        return row;
    }

    
    
    func setTooltipForFormRow(_ row: FormRowWithInfoButton, with field: PaymentProductField, paymentItem: PaymentItem) {
        if field.displayHints.tooltip?.imagePath != nil {
            let tooltip = FormRowTooltip()
            var tooltipTextKey = "gc.general.paymentProducts.\(paymentItem.identifier).paymentProductFields.\(field.identifier).tooltipText"
            var tooltipTextValue = NSLocalizedString(tooltipTextKey, tableName: SDKConstants.kSDKLocalizable, bundle: AppConstants.sdkBundle, value: "", comment: "")
            if tooltipTextKey == tooltipTextValue {
                tooltipTextKey = "gc.general.paymentProductFields.\(field.identifier).tooltipText"
                tooltipTextValue = NSLocalizedString(tooltipTextKey, tableName: SDKConstants.kSDKLocalizable, bundle: AppConstants.sdkBundle, value: "", comment: "")
            }
            tooltip.text = tooltipTextValue
            tooltip.image = field.displayHints.tooltip?.image
            row.tooltip = tooltip
        }
    }
    
    func listFormRow(from field: PaymentProductField, value: String, isEnabled: Bool, viewFactory: ViewFactory) -> FormRowList {
        let row = FormRowList(paymentProductField: field)
        
        var identifierToRowMapping = Dictionary<String, String>()
        let valueMapping = field.displayHints.formElement.valueMapping
        for item: ValueMappingItem in valueMapping where (item.displayName != nil || item.displayElements.contains { $0.value != nil})  && item.value != nil {
            row.items.append(item)
        }
        
        row.selectedRow = row.items.map({ $0.value }).index(of: value) ?? 0
        row.isEnabled = isEnabled
        return row
    }
    
    func labelFormRow(from field: PaymentProductField, paymentProduct paymentProductId: String, viewFactory: ViewFactory) -> FormRowLabel {
        var labelKey = "gc.general.paymentProducts.\(paymentProductId).paymentProductFields.\(field.identifier).label"
        var labelValue = NSLocalizedString(labelKey, tableName: SDKConstants.kSDKLocalizable, bundle: AppConstants.sdkBundle, value: "", comment: "")

        if labelKey == labelValue {
            labelKey = "gc.general.paymentProductFields.\(field.identifier).label"
            labelValue = NSLocalizedString(labelKey, tableName: SDKConstants.kSDKLocalizable, bundle: AppConstants.sdkBundle, value: "", comment: "")
        }

        return FormRowLabel(text: labelValue)
    }
    
}

