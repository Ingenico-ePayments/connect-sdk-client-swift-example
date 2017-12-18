//
//  FormRowSwitch.swift
//  IngenicoConnectExample
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2016 Global Collect Services. All rights reserved.
//

import Foundation
import IngenicoConnectKit

class FormRowSwitch: FormRowWithInfoButton {
    var isOn: Bool
    var title: NSAttributedString
    var target: Any?
    var action: Selector?
    var field: PaymentProductField?
    
    init(title: NSAttributedString, isOn: Bool, target: Any?, action: Selector?, paymentProductField field: PaymentProductField?) {
        self.title = title
        self.isOn = isOn
        self.target = target
        self.action = action
        self.field = field
    }
    convenience init(title: String, isOn: Bool, target: Any?, action: Selector?, paymentProductField field: PaymentProductField?) {
        self.init(title: NSAttributedString(string: title), isOn: isOn, target: target, action: action, paymentProductField: field)
    }

}
