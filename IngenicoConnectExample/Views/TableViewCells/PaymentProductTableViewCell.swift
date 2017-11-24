//
//  PaymentProductTableViewCell.swift
//  IngenicoConnectExample
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2016 Global Collect Services. All rights reserved.
//

import Foundation
import UIKit

class PaymentProductTableViewCell: TableViewCell {
    private var logoContainer = UIImageView()
    var shouldHaveMaximalWidth = false
    private var _textLabel: UILabel = Label()
    override var textLabel: UILabel? {
        get {
            return _textLabel
        }
        set {
            _textLabel = newValue ?? Label()
        }
    }
    var name: String? {
        get {
            return textLabel?.text
        }
        set {
            textLabel?.text = newValue
        }
    }

    var logo: UIImage? {
        get {
            return logoContainer.image
        }
        set {
            logoContainer.image = newValue
        }
    }
    var color: UIColor? {
        get {
            if self.shouldHaveMaximalWidth {
                return limitedContainer.backgroundColor
            }
            return super.backgroundColor
        }
        set {
            if self.shouldHaveMaximalWidth {
                limitedContainer.backgroundColor = newValue
            }
            else {
                super.backgroundColor = newValue
            }
        }
    }

    override class var reuseIdentifier: String { return "payment-product-selection-cell" }
    
    var limitedContainer = UIView()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        accessoryType = .disclosureIndicator
        logoContainer = UIImageView(frame: CGRect.zero)
        logoContainer.contentMode = .scaleAspectFit
        contentView.addSubview(limitedContainer)

        textLabel?.adjustsFontSizeToFitWidth = false
        textLabel?.lineBreakMode = NSLineBreakMode.byTruncatingTail
        textLabel?.removeFromSuperview()
        limitedContainer.addSubview(logoContainer)
        limitedContainer.addSubview(textLabel!)
//        if #available(iOS 9.0, *) {
//            let constraint = self.textLabel?.leadingAnchor.constraint(equalTo:self.contentView.layoutMarginsGuide.leadingAnchor)
//            self.contentView.addConstraint(constraint!);
//        }

        clipsToBounds = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        let width: Int
        let leftPadding: Int
        let rightPadding = Int(contentView.layoutMargins.right)
        if self.shouldHaveMaximalWidth {
            width = Int(ceil(accessoryAndMarginCompatibleWidth()))
            leftPadding = Int(ceil(accessoryCompatibleLeftMargin()))
        }
        else {
            width = Int(contentView.frame.size.width) - rightPadding
            leftPadding = Int(contentView.layoutMargins.left)
        }

        let height = Int(contentView.frame.size.height)
        let logoWidth = 35
        
        let textLabelX: Int
        if logo != nil {
            textLabelX = logoWidth + rightPadding
            logoContainer.frame = CGRect(x: 0, y: 5, width: logoWidth, height: height - 10)
        }
        else {
            textLabelX = leftPadding
        }
        textLabel?.frame = CGRect(x: textLabelX, y: 0, width: width - textLabelX, height: height)
        limitedContainer.frame = CGRect(x: leftPadding, y: 0, width: width, height: height)
    }
    
    override func prepareForReuse() {
        name = nil
        logo = nil
    }
    
}
