//
//  CurrencyTableViewCell.swift
//  IngenicoConnectExample
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2016 Global Collect Services. All rights reserved.
//

import Foundation
import UIKit

class CurrencyTableViewCell: TableViewCell {
    var integerTextField: IntegerTextField = IntegerTextField()
    var fractionalTextField: FractionalTextField = FractionalTextField()

    var separatorlabel = UILabel()
    var currencyCodeLabel = UILabel()

    static let reuseIdentifier = "currency-text-field-cell"
    
    var delegate: UITextFieldDelegate? {
        get {
            return integerTextField.delegate
        }
        set {
            integerTextField.delegate = newValue
            fractionalTextField.delegate = newValue
        }
    }

    var currencyCode: String? {
        didSet {
            self.currencyCodeLabel.text = currencyCode
        }
    }

    var integerField: FormRowField? {
        didSet {
            integerTextField.text = integerField?.text
            integerTextField.placeholder = integerField?.placeholder
            integerTextField.keyboardType = integerField?.keyboardType ?? .default
            integerTextField.isSecureTextEntry = integerField?.isSecure ?? false
        }
    }

    var fractionalField: FormRowField? {
        didSet {
            integerTextField.text = fractionalField?.text
            integerTextField.placeholder = fractionalField?.placeholder
            integerTextField.keyboardType = fractionalField?.keyboardType ?? .default
            integerTextField.isSecureTextEntry = fractionalField?.isSecure ?? false
        }
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        let formatter = NumberFormatter()
        formatter.locale = NSLocale.current
        separatorlabel.text = formatter.decimalSeparator!
        contentView.addSubview(separatorlabel)
        contentView.addSubview(currencyCodeLabel)

        addSubview(integerTextField)
        addSubview(fractionalTextField)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        let width = Int(contentView.frame.size.width)
        let padding = 10
        let currencyCodeWidth = 36
        let fractionalWidth = 50
        let separatorWidth = 8
        let currencyCodeX = padding
        let integerX = currencyCodeX + currencyCodeWidth + padding
        let separatorX = width - padding - fractionalWidth - padding - separatorWidth
        let fractionalX = width - padding - fractionalWidth
        let integerWidth = separatorX - padding - integerX

        separatorlabel.frame = CGRect(x: separatorX, y: 7, width: separatorWidth, height: 30)
        currencyCodeLabel.frame = CGRect(x: currencyCodeX, y: 7, width: currencyCodeWidth, height: 30)
        
        integerTextField.frame = CGRect(x: integerX, y: 4, width: integerWidth, height: 36)
        fractionalTextField.frame = CGRect(x: fractionalX, y: 4, width: fractionalWidth, height: 36)
    }

    override func prepareForReuse() {
        currencyCode = nil
        integerField = nil
        fractionalField = nil
        delegate = nil
    }
    
    deinit {
        integerTextField.endEditing(true)
        fractionalTextField.endEditing(true)
    }
}
