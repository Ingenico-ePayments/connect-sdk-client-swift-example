//
//  FormRowDate.swift
//  IngenicoConnectExample
//
//  Created for Ingenico ePayments on 22/10/2017.
//  Copyright © 2017 Ingenico. All rights reserved.
//

import Foundation
import IngenicoConnectKit

class FormRowDate : FormRow {
    
    var paymentProductField: PaymentProductField
    
    init(paymentProductField field: PaymentProductField) {
        self.paymentProductField = field
    }
    
}
