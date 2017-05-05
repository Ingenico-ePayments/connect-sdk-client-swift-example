//
//  LabelTableViewCell.swift
//  IngenicoConnectExample
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2016 Global Collect Services. All rights reserved.
//

import Foundation
import UIKit

class LabelTableViewCell: TableViewCell {
    var labelView: Label = Label()

    class var reuseIdentifier: String { return "label-cell" }

    var label: String? {
        get {
            return labelView.text
        }
        set {
            labelView.text = newValue
        }
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubview(labelView)
        clipsToBounds = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        let width = contentView.frame.size.width
        labelView.frame = CGRect(x: 10, y: 4, width: width - 20, height: 36)
    }

    override func prepareForReuse() {
        label = nil
    }
}
