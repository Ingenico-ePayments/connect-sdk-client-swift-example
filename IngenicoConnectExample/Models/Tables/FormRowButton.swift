//
//  FormRowButton.swift
//  IngenicoConnectExample
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2016 Global Collect Services. All rights reserved.
//

import Foundation
import UIKit

class FormRowButton: FormRow {
    var title: String
    var target: Any
    var action: Selector
    var buttonType: ButtonType = .primary

    init(title: String, target: Any, action: Selector) {
        self.title = title
        self.target = target
        self.action = action
    }
}
