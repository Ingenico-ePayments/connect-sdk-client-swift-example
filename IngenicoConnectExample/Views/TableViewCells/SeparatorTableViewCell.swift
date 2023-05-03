//
//  ImageTableViewCell.swift
//  IngenicoConnectExample
//
//  Created for Ingenico ePayments on 15/06/2017.
//  Copyright © 2017 Ingenico. All rights reserved.
//

import UIKit

class SeparatorTableViewCell: TableViewCell {

    var view = SeparatorView()

    override class var reuseIdentifier: String { return "separator-cell" }

    var separatorText: NSString? {
        get {
            return view.separatorString
        }
        set {
            view.separatorString = newValue
        }
    }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubview(view)
        view.isOpaque = false
        clipsToBounds = true
        view.contentMode = .center
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let width = self.accessoryAndMarginCompatibleWidth()
        let leftMargin = accessoryCompatibleLeftMargin()

        // let width = contentView.frame.size.width
        // let newWidth = width - 20
        let newHeight = contentView.frame.size.height
        view.frame = CGRect(x: leftMargin, y: 0, width: width, height: newHeight)
    }

    override func prepareForReuse() {
        separatorText = nil
    }
}
