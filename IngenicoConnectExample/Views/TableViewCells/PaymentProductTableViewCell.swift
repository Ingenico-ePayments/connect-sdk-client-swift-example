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


    static let reuseIdentifier = "payment-product-selection-cell"
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        accessoryType = .disclosureIndicator
        logoContainer = UIImageView(frame: CGRect.zero)
        logoContainer.contentMode = .scaleAspectFit
        contentView.addSubview(logoContainer)

        textLabel?.adjustsFontSizeToFitWidth = false
        textLabel?.lineBreakMode = NSLineBreakMode.byTruncatingTail

        clipsToBounds = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        let width = Int(contentView.frame.size.width)
        let height = Int(contentView.frame.size.height)
        let padding = 15
        let logoWidth = 35
        
        let textLabelX: Int
        if logo != nil {
            textLabelX = padding + logoWidth + padding
            logoContainer.frame = CGRect(x: padding, y: 5, width: logoWidth, height: height - 10)
        }
        else {
            textLabelX = padding
        }
        
        textLabel?.frame = CGRect(x: textLabelX, y: 0, width: width - textLabelX - padding, height: height)
    }
    
    override func prepareForReuse() {
        name = nil
        logo = nil
    }
    
}
