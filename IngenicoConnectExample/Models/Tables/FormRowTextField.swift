//
//  FormRowTextField.swift
//  IngenicoConnectExample
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2016 Global Collect Services. All rights reserved.
//

import Foundation
import UIKit
import IngenicoConnectKit

struct FormRowField {
    var text: String
    var placeholder: String
    var keyboardType: UIKeyboardType
    var isSecure: Bool

    init(text: String, placeholder: String, keyboardType: UIKeyboardType, isSecure: Bool){
        self.text = text
        self.placeholder = placeholder
        self.keyboardType = keyboardType
        self.isSecure = isSecure
    }
}

class FormRowTextField: FormRowWithInfoButton {
    var paymentProductField: PaymentProductField
    var logo: UIImage?
    var field: FormRowField
    
    init(paymentProductField: PaymentProductField, field: FormRowField) {
        self.paymentProductField = paymentProductField
        self.field = field
    }
}
