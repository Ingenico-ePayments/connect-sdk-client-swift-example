//
//  FormRowWithInfoButton.swift
//  IngenicoConnectExample
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2016 Global Collect Services. All rights reserved.
//

import Foundation
import UIKit

class FormRowWithInfoButton: FormRow {
    var showInfoButton: Bool {
        return tooltip != nil
    }
    var tooltip: FormRowTooltip?

}
