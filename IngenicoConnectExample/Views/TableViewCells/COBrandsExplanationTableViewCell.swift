//
//  COBrandsExplanationTableViewCell.swift
//  IngenicoConnectExample
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2016 Global Collect Services. All rights reserved.
//

import Foundation
import UIKit
import IngenicoConnectKit

class COBrandsExplanationTableViewCell: TableViewCell {
    static let reuseIdentifier = "co-brand-explanation-cell"
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        textLabel?.attributedText = COBrandsExplanationTableViewCell.cellString()
        textLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
        textLabel?.numberOfLines = 0
        backgroundColor = UIColor(white: 0.9, alpha: 1)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    class func cellString() -> NSAttributedString {
        let font = UIFont.systemFont(ofSize: 12)
        let fontAttribute = [NSFontAttributeName: font]
        
        let cellKey = "gc.general.cobrands.introText"
        let cellString = NSLocalizedString(cellKey, tableName: SDKConstants.kSDKLocalizable, bundle: AppConstants.sdkBundle, value: "", comment: "")
        let cellStringWithFont = NSAttributedString(string: cellString, attributes: fontAttribute)
        
        return cellStringWithFont
    }
    
}
