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

    override class var reuseIdentifier: String { return "label-cell" }

    var label: String? {
        get {
            return labelView.text
        }
        set {
            labelView.text = newValue
        }
    }
    class func labelFont(bold: Bool) -> UIFont {
        if bold {
            return UIFont.boldSystemFont(ofSize: UIFont.systemFontSize)
        }
        return UIFont.systemFont(ofSize: UIFont.systemFontSize)

    }
    private var labelFont: UIFont {
        return LabelTableViewCell.labelFont(bold: self.isBold)
    }
    var isBold: Bool = false {
        didSet {
            labelView.font = self.labelFont

        }
    }
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.contentView.addSubview(labelView)
        labelView.numberOfLines = 0
        labelView.lineBreakMode = .byWordWrapping
        clipsToBounds = true
    }
    private class func labelSize(width: CGFloat, bold: Bool, text: String) -> CGSize {
        let style = NSMutableParagraphStyle()
        style.lineBreakMode = .byWordWrapping;
        let text = text as NSString
        let rect = text.boundingRect(with: CGSize(width: width, height: CGFloat.greatestFiniteMagnitude), options: NSStringDrawingOptions.usesFontLeading.union(NSStringDrawingOptions.usesLineFragmentOrigin), attributes: [NSFontAttributeName: labelFont(bold:bold), NSParagraphStyleAttributeName: style], context: nil)
        return rect.size
    }
    class func cellSize(width: CGFloat, formRow: FormRowLabel) -> CGSize {
        var rect = LabelTableViewCell.labelSize(width: width, bold: formRow.isBold, text: formRow.text)
        rect.height += 8
        return rect
    }
    private func labelSize(width: CGFloat) -> CGSize {
        return LabelTableViewCell.labelSize(width: width, bold: self.isBold, text: self.label!)
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        let width = self.accessoryAndMarginCompatibleWidth()
        let leftMargin = accessoryCompatibleLeftMargin()
        labelView.frame = CGRect(x: leftMargin, y: 4, width: width, height: self.labelSize(width: width).height)

    }

    override func prepareForReuse() {
        label = nil
    }
}
