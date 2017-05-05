//
//  ErrorMessageTableViewCell.swift
//  IngenicoConnectExample
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2016 Global Collect Services. All rights reserved.
//

import Foundation
import UIKit

class ErrorMessageTableViewCell: LabelTableViewCell {

    override class var reuseIdentifier: String { return "error-cell" }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        labelView.font = UIFont.systemFont(ofSize: 12.0)
        labelView.numberOfLines = 0
        labelView.textColor = UIColor.red

        addSubview(labelView)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
