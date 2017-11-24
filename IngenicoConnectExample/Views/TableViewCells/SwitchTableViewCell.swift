//
//  SwitchTableViewCell.swift
//  IngenicoConnectExample
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2016 Global Collect Services. All rights reserved.
//

import Foundation
import UIKit

class SwitchTableViewCell: TableViewCell {
    var switchControl = UISwitch()
    override class var reuseIdentifier: String {return "switch-cell"}

    var title: String? {
        get {
            return textLabel?.text
        }
        set {
            textLabel?.text = newValue
        }
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        textLabel?.font = UIFont.systemFont(ofSize: 12.0)
        textLabel?.numberOfLines = 0
        clipsToBounds = true

        addSubview(switchControl)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func setSwitchTarget(_ target: Any, action: Selector) {
        switchControl.removeTarget(nil, action: nil, for: .allEvents)
        switchControl.addTarget(target, action: action, for: .touchUpInside)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        let height = contentView.frame.size.height
        let width = self.accessoryAndMarginCompatibleWidth()
        let leftMargin = self.accessoryCompatibleLeftMargin()
        let switchWidth = switchControl.frame.size.width
        switchControl.frame = CGRect(x: leftMargin, y: 7, width: 0, height: 0)
        textLabel?.frame = CGRect(x: leftMargin + switchWidth + 16, y: -1, width: width - switchWidth, height: height)
    }

    override func prepareForReuse() {
        title = nil
        switchControl.removeTarget(nil, action: nil, for: .allEvents)
    }
}
