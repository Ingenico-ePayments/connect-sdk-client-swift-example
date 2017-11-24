//
//  FormRowImage.swift
//  IngenicoConnectExample
//
//  Created for Ingenico ePayments on 15/06/2017.
//  Copyright © 2017 Ingenico. All rights reserved.
//

import UIKit

class FormRowImage: FormRow {
    var image: UIImage
    init(image: UIImage) {
        self.image = image
        super.init()
    }
}
