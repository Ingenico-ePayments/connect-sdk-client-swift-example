//
//  FormRowCurrency.swift
//  IngenicoConnectExample
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2016 Global Collect Services. All rights reserved.
//

import Foundation
import IngenicoConnectKit

enum CurrencyRowType {
    case integer
    case fractional
}

class FormRowCurrency: FormRowWithInfoButton {
    var integerField: FormRowField
    var fractionalField: FormRowField
    
    var paymentProductField: PaymentProductField
    
    init(paymentProductField: PaymentProductField, integerField: FormRowField, fractionalField: FormRowField) {
        self.paymentProductField = paymentProductField
        self.integerField = integerField
        self.fractionalField = fractionalField
    }
}
