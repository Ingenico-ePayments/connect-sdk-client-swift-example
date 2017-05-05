//
//  FormRowSwitch.swift
//  IngenicoConnectExample
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2016 Global Collect Services. All rights reserved.
//

import Foundation

class FormRowSwitch: FormRowWithInfoButton {
    var isOn: Bool
    var title: String
    var target: Any
    var action: Selector
    
    init(title: String, isOn: Bool, target: Any, action: Selector) {
        self.title = title
        self.isOn = isOn
        self.target = target
        self.action = action
    }
}
