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
}

class FormRowTextField: FormRowWithInfoButtonProductField {
    var logo: UIImage?
    var field: FormRowField

    init(paymentProductField: PaymentProductField, field: FormRowField) {
        self.field = field

        super.init(paymentProductField: paymentProductField)
    }
}
