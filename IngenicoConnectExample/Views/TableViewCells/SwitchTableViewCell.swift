//
//  SwitchTableViewCell.swift
//  IngenicoConnectExample
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2016 Global Collect Services. All rights reserved.
//

import Foundation
import UIKit

protocol SwitchTableViewCellDelegate: AnyObject {
    func switchChanged(_ aSwitch: Switch)
}

class SwitchTableViewCell: TableViewCell {
    var switchControl = UISwitch()
    let textView = UITextView()
    let errorLabel = Label()

    override class var reuseIdentifier: String {return "switch-cell"}

    var isOn: Bool {
        get {
            return switchControl.isOn
        }
        set {
            switchControl.isOn = newValue
        }
    }
    var attributedTitle: NSAttributedString? {
        get {
            return textView.attributedText
        }
        set {
            textView.attributedText = newValue
        }
    }

    var errorMessage: String? {
        get {
            return errorLabel.text
        }
        set {
            errorLabel.text = newValue
            setNeedsLayout()
        }
    }
    var readonly: Bool {
        get {
            return !switchControl.isEnabled
        }
        set {
            switchControl.isEnabled = !newValue
        }
    }

    weak var delegate: SwitchTableViewCellDelegate?

    var kvoTextView: NSKeyValueObservation?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        clipsToBounds = true
        addSubview(switchControl)

        kvoTextView = textView.observe(\.contentSize, options: .new) { object, _ in
            self.observeValue(textView: object)
        }

        addSubview(textView)
        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.font = UIFont.systemFont(ofSize: 12.0)

        errorLabel.font = textView.font
        errorLabel.numberOfLines = 0
        errorLabel.textColor = .red
        addSubview(errorLabel)

        setSwitchTarget(nil, action: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    deinit {
        kvoTextView?.invalidate()
    }

    func setSwitchTarget(_ target: Any?, action: Selector?) {
        switchControl.removeTarget(nil, action: nil, for: .allEvents)
        switchControl.addTarget(target ?? self, action: action ?? #selector(didSwitch(_:)), for: .touchUpInside)
    }

    @objc func didSwitch(_ sender: Switch) {
        delegate?.switchChanged(sender)
    }

    private func observeValue(textView: UITextView) {
        var topCorrect = (textView.bounds.height - textView.contentSize.height * textView.zoomScale) / 2.0
        if topCorrect < 0 {
            topCorrect = 0
        }
        textView.contentOffset = CGPoint(x: 0, y: -topCorrect)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let height = contentView.frame.size.height
        let width = accessoryAndMarginCompatibleWidth()
        let leftMargin = accessoryCompatibleLeftMargin()
        let switchWidth = switchControl.frame.size.width

        textView.frame = CGRect(x: leftMargin + 16 + switchWidth, y: 10, width: width - switchWidth, height: 44)

        switchControl.frame = CGRect(x: leftMargin, y: 7, width: 0, height: 0)
        textLabel?.frame = CGRect(x: leftMargin + switchWidth + 16, y: -1, width: width - switchWidth, height: height)
        errorLabel.frame = CGRect(x: leftMargin, y: 64, width: width, height: 20)
        errorLabel.preferredMaxLayoutWidth = width - 20
        errorLabel.sizeToFit()
        errorLabel.frame =
            CGRect(
                x: leftMargin,
                y: self.textView.frame.origin.y + self.textView.frame.size.height + 5,
                width: width,
                height: self.errorLabel.frame.size.height
            )
    }

    override func prepareForReuse() {
        delegate = nil
        attributedTitle = nil
        errorMessage = nil
        setSwitchTarget(nil, action: nil)
    }
}
