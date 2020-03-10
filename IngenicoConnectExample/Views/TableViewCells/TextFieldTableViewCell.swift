//
//  TextFieldTableViewCell.swift
//  IngenicoConnectExample
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2016 Global Collect Services. All rights reserved.
//

import Foundation
import UIKit

class TextFieldTableViewCell: TableViewCell {
    
    var delegate: UITextFieldDelegate? {
        get {
            return textField.delegate
        }
        set {
            textField.delegate = newValue
        }
    }
    
    var field: FormRowField? {
        didSet {
            textField.text = field?.text
            textField.placeholder = field?.placeholder
            textField.keyboardType = field?.keyboardType ?? .default
            textField.isSecureTextEntry = field?.isSecure ?? false
        }
    }
    
    var rightView: UIView? {
        get {
            return textField.rightView
        }
        set {
            textField.rightViewMode = newValue != nil ? .always : .never
            textField.rightView = newValue
        }
    }
    var readonly: Bool {
        get {
            return !textField.isEnabled
        }
        set {
            textField.isEnabled = !newValue
        }
    }
    var error: String? {
        get {
            return errorLabel.text
        }
        set {
            errorLabel.text = newValue
        }
    }
    
    private var textField: TextField = TextField()
    
    private var errorLabel: Label = Label()
    
    override class var reuseIdentifier: String {return "text-field-cell"}
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        clipsToBounds = true
        addSubview(textField)
        
        errorLabel.font = UIFont.systemFont(ofSize: 12.0)
        errorLabel.numberOfLines = 0
        errorLabel.textColor = UIColor.red
        addSubview(errorLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        let width = accessoryAndMarginCompatibleWidth()
        let leftMargin = self.accessoryCompatibleLeftMargin()
        textField.frame = CGRect(x: leftMargin, y: 4, width: width, height: 36)
        errorLabel.frame = CGRect(x: leftMargin, y: 44, width: width, height: 20)
        errorLabel.preferredMaxLayoutWidth = width - 20
        errorLabel.sizeToFit()
        errorLabel.frame = CGRect(x: leftMargin, y: 44, width: width, height: errorLabel.frame.height)
    }
    
    override func prepareForReuse() {
        field = nil
        delegate = nil
        rightView = nil
        error = nil
    }
    
    deinit {
        textField.endEditing(true)
    }
    
}
