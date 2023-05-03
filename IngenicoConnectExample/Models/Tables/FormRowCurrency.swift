//
//  FormRowCurrency.swift
//  IngenicoConnectExample
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2016 Global Collect Services. All rights reserved.
//

import Foundation
import IngenicoConnectKit

class FormRowCurrency: FormRowWithInfoButtonProductField {
    var integerField: FormRowField
    var fractionalField: FormRowField

    init(paymentProductField: PaymentProductField, integerField: FormRowField, fractionalField: FormRowField) {
        self.integerField = integerField
        self.fractionalField = fractionalField

        super.init(paymentProductField: paymentProductField)
    }
}
