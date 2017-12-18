//
//  Button.swift
//  IngenicoConnectExample
//
//  Created for Ingenico ePayments on 10/04/2017.
//  Copyright © 2017 Ingenico. All rights reserved.
//

import Foundation
import UIKit

enum ButtonType {
    case primary
    case secondary
    case destructive
}

class Button : UIButton {
    
    init() {
        self.type = .primary
        super.init(frame: .zero)
        layer.cornerRadius = 5
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var type: ButtonType {
        didSet {
            switch type {
            case .primary:
                setTitleColor(UIColor.white, for: .normal)
                setTitleColor(UIColor.white.withAlphaComponent(0.5), for: .highlighted)
                backgroundColor = AppConstants.kPrimaryColor
                titleLabel?.font = UIFont.boldSystemFont(ofSize: UIFont.buttonFontSize)
            case .secondary:
                setTitleColor(UIColor.gray, for: .normal)
                setTitleColor(UIColor.gray.withAlphaComponent(0.5), for: .highlighted)
                backgroundColor = UIColor.clear
                titleLabel?.font = UIFont.systemFont(ofSize: UIFont.buttonFontSize)
            case .destructive:
                setTitleColor(UIColor.white, for: .normal)
                setTitleColor(UIColor.white.withAlphaComponent(0.5), for: .highlighted)
                backgroundColor = AppConstants.kDestructiveColor
                titleLabel?.font = UIFont.boldSystemFont(ofSize: UIFont.buttonFontSize)
            }
        }
    }
    
    override var isEnabled: Bool {
        get {
            return super.isEnabled
        }
        set {
            super.isEnabled = newValue
            alpha = newValue ? 1 : 0.3
        }
    }
    
}
