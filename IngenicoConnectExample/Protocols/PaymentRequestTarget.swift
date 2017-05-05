//
//  PaymentRequestTarget.swift
//  IngenicoConnectExample
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2016 Global Collect Services. All rights reserved.
//

import Foundation
import IngenicoConnectKit

protocol PaymentRequestTarget {
    func didSubmitPaymentRequest(paymentRequest: PaymentRequest)
    func didCancelPaymentRequest()
}
