//
//  ButtonTableViewCell.swift
//  IngenicoConnectExample
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2016 Global Collect Services. All rights reserved.
//

import Foundation
import UIKit

class ButtonTableViewCell: TableViewCell {
    private var button: Button = Button()
    
    static let reuseIdentifier: String = "button-cell"
    
    var buttonType: ButtonType {
        get {
            return button.type
        }
        set {
            button.type = newValue
        }
    }
    
    var title: String? {
        get {
            return button.title(for: .normal)
        }
        set {
            button.setTitle(newValue, for: .normal)
        }
    }
    
    var isEnabled: Bool {
        get {
            return button.isEnabled
        }
        set {
            button.isEnabled = newValue
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        sharedInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        sharedInit()
    }
    
    func sharedInit() {
        addSubview(button)
        buttonType = .primary
    }
    
    func setClickTarget(_ target: Any, action: Selector) {
        button.removeTarget(nil, action: nil, for: .allEvents)
        button.addTarget(target, action: action, for: .touchUpInside)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let height = contentView.frame.size.height
        let width = contentView.frame.size.width
        button.frame = CGRect(x: 10, y: buttonType == .primary ? 12 : 6, width: width - 20, height: height - 12)
    }
    
    override func prepareForReuse() {
        button.removeTarget(nil, action: nil, for: .allEvents)
    }
    
}
