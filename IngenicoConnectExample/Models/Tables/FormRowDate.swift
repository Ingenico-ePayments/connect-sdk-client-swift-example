//
//  FormRowDate.swift
//  IngenicoConnectExample
//
//  Created for Ingenico ePayments on 22/10/2017.
//  Copyright © 2017 Ingenico. All rights reserved.
//

import Foundation
import IngenicoConnectKit

class FormRowDate: FormRowWithProductField {

    var date: Date
    init(paymentProductField field: PaymentProductField, value: String) {
        if value != "" {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyyMMdd"

            date = formatter.date(from: value) ?? Date()

        } else {
            date = Date()
        }

        super.init(paymentProductField: field)
    }

}
