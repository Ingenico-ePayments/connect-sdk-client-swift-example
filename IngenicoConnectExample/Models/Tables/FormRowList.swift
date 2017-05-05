//
//  FormRowList.swift
//  IngenicoConnectExample
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2016 Global Collect Services. All rights reserved.
//

import Foundation
import IngenicoConnectKit

class FormRowList: FormRow {
    var items = [ValueMappingItem]()
    var selectedRow = 0
    var paymentProductField: PaymentProductField
    
    init(paymentProductField: PaymentProductField) {
        self.paymentProductField = paymentProductField
    }
}
