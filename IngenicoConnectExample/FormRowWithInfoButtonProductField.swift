//
//  FormRowWithInfoButtonProductField.swift
//  IngenicoConnectExample
//
//  Created for Ingenico ePayments on 15/02/2023.
//  Copyright © 2023 Ingenico. All rights reserved.
//

import Foundation
import IngenicoConnectKit

class FormRowWithInfoButtonProductField: FormRowWithInfoButton {
    var paymentProductField: PaymentProductField

    init(paymentProductField: PaymentProductField) {
        self.paymentProductField = paymentProductField

        super.init()
    }
}
