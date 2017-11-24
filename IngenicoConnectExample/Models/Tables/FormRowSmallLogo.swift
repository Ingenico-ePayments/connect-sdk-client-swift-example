//
//  FormRowSmallLogo.swift
//  IngenicoConnectExample
//
//  Created for Ingenico ePayments on 07/07/2017.
//  Copyright © 2017 Ingenico. All rights reserved.
//

import UIKit

class FormRowSmallLogo: FormRowImage {
    enum AnchorSide {
        case left
        case right
    }
    var anchorSide: AnchorSide
    override init(image: UIImage) {
        anchorSide = .left
        
        super.init(image: image)
    }
}
