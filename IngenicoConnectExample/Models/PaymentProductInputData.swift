//
//  PaymentProductInputData.swift
//  IngenicoConnectExample
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2016 Global Collect Services. All rights reserved.
//

import Foundation
import IngenicoConnectKit

class PaymentProductInputData {
    var paymentItem: PaymentItem!
    var accountOnFile: AccountOnFile!
    var tokenize = false
    var errors = NSMutableArray()
    var fieldValues = Dictionary<String, String>()
    var formatter = StringFormatter()
    
    func paymentRequest() -> PaymentRequest {
        guard let paymentItem = paymentItem as? PaymentProduct else {
            fatalError("Invalid paymentItem")
        }

        let paymentRequest = PaymentRequest(paymentProduct: paymentItem, accountOnFile: accountOnFile, tokenize: false)

        let keys = Array(fieldValues.keys)
        
        for key: String in keys {
            let value = fieldValues[key]
            paymentRequest.setValue(forField: key, value: value!)
        }
        
        return paymentRequest
    }
    
    func setValue(value: String, forField paymentProductFieldId: String) {
        fieldValues[paymentProductFieldId] = value
    }
    
    func value(forField paymentProductFieldId: String) -> String {
        var value = fieldValues[paymentProductFieldId]
        
        if value == nil {
            value = ""
            let field = paymentItem.paymentProductField(withId: paymentProductFieldId )!
            let validators = field.dataRestrictions.validators.validators
            for validator in validators {
                if let fixedListValidator = validator as? ValidatorFixedList {
                    value = fixedListValidator.allowedValues[0]
                    setValue(value: value!, forField: paymentProductFieldId)
                }
            }
        }
        
        return value!
    }
    
    func maskedValue(forField paymentProductFieldId: String) -> String {
        var cursorPosition = 0
        return maskedValue(forField: paymentProductFieldId, cursorPosition: &cursorPosition)
    }
    
    func maskedValue(forField paymentProductFieldId: String, cursorPosition: inout Int) -> String {
        let value = self.value(forField: paymentProductFieldId)
        let maskValue = mask(forField: paymentProductFieldId)
        if maskValue == nil {
            return value
        }
        else {
            return formatter.formatString(string: value, mask: maskValue!, cursorPosition: &cursorPosition)
        }
    }
    
    func unmaskedValue(forField paymentProductFieldId: String) -> String {
        let value = self.value(forField: paymentProductFieldId)
        let maskValue = mask(forField: paymentProductFieldId)
        if maskValue == nil {
            return value
        }
        else {
            let unformattedString = formatter.unformatString(string: value , mask: maskValue!)
            return unformattedString
        }
    }
    
    func fieldIsPartOfAccountOnFile(paymentProductFieldId: String) -> Bool {
        return accountOnFile?.hasValue(forField: paymentProductFieldId) ?? false
    }
    
    func fieldIsReadOnly(paymentProductFieldId: String) -> Bool {
        if !fieldIsPartOfAccountOnFile(paymentProductFieldId: paymentProductFieldId) {
            return false
        }
        else {
            return accountOnFile.isReadOnly(field: paymentProductFieldId)
        }
    }
    
    func setAccountOnFile(_ accountOnFile: AccountOnFile) {
        self.accountOnFile = accountOnFile
        let attributes = accountOnFile.attributes.attributes
        for attribute in attributes where attribute.key != nil {
            fieldValues[attribute.key] = attribute.value
        }
    }
    
    func mask(forField paymentProductFieldId: String) -> String? {
        let field = self.paymentItem.paymentProductField(withId: paymentProductFieldId )
        
        return field?.displayHints.mask
    }
    
    func unmaskedFieldValues() -> [AnyHashable: Any] {
        var unmaskedFieldValues: [AnyHashable: Any] = [:]
        let paymentProductFields = paymentItem.fields.paymentProductFields
        for field in paymentProductFields {
            let fieldId = field.identifier
            if !fieldIsReadOnly(paymentProductFieldId: fieldId) {
                let unmaskedValue = self.unmaskedValue(forField: fieldId)
                unmaskedFieldValues[fieldId] = unmaskedValue
            }
        }
        return unmaskedFieldValues
    }
    
    func validate() {
        errors.removeAllObjects()

        let request = self.paymentRequest();
        let paymentProductFields = paymentItem.fields.paymentProductFields
        for field in paymentProductFields {
            if !fieldIsPartOfAccountOnFile(paymentProductFieldId: field.identifier) {
                let fieldValue = self.unmaskedValue(forField: field.identifier )
                field.validateValue(value: fieldValue, for: request)
                errors.addObjects(from: field.errors)
            }
        }
    }
    
}













