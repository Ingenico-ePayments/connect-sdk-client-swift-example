//
//  FormRowLabel.swift
//  IngenicoConnectExample
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2016 Global Collect Services. All rights reserved.
//

import Foundation
import UIKit

class FormRowLabel: FormRowWithInfoButton {
    var text: String
    var isBold: Bool
    init(text: String) {
        self.text = text
        self.isBold = false
    }
}
