//
//  CoBrandsSelectionTableViewCell.swift
//  IngenicoConnectExample
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2016 Global Collect Services. All rights reserved.
//

import Foundation
import UIKit
import IngenicoConnectKit

class CoBrandsSelectionTableViewCell: TableViewCell {
    static let reuseIdentifier = "co-brand-selection-cell"
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        let font = UIFont.systemFont(ofSize: 13)
        let underlineAttributes = [NSUnderlineStyleAttributeName: NSUnderlineStyle.styleSingle.rawValue, NSFontAttributeName: font] as [String : Any]
        
        let cobrandsString = NSLocalizedString("gc.general.cobrands.toggleCobrands", tableName: SDKConstants.kSDKLocalizable, bundle: AppConstants.sdkBundle, value: "", comment: "")
        
        textLabel?.attributedText = NSAttributedString(string: cobrandsString, attributes: underlineAttributes)
        textLabel?.textAlignment = .right
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}
