//
//  PickerViewTableViewCell.swift
//  IngenicoConnectExample
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2016 Global Collect Services. All rights reserved.
//

import Foundation
import UIKit
import IngenicoConnectKit

class PickerViewTableViewCell: TableViewCell {
    class var pickerHeight: CGFloat { get { return 216 } }
    var pickerView = PickerView()
    override class var reuseIdentifier: String {return "picker-view-cell"}

    var items: [ValueMappingItem]? {
        didSet {
            pickerView.content = items?.map { $0.displayName! } ?? []
        }
    }

    var delegate: UIPickerViewDelegate? {
        get {
            return pickerView.delegate
        }
        set {
            pickerView.delegate = newValue
        }
    }

    var dataSource: UIPickerViewDataSource? {
        get {
            return pickerView.dataSource
        }
        set {
            pickerView.dataSource = newValue
        }
    }

    var selectedRow: Int? {
        get {
            return pickerView.selectedRow(inComponent: 0)
        }
        set {
            pickerView.selectRow(newValue ?? 0, inComponent: 0, animated: false)
        }
    }
    var readonly: Bool = false {
        didSet{
            pickerView.isUserInteractionEnabled = !self.readonly
            pickerView.alpha = (self.readonly) ? 0.6 : 1.0
        }
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubview(pickerView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    func pickerLeftMargin(for fitsize:CGSize) -> CGFloat {
        if (self.accessoryType != .none) {
            if (self.contentView.frame.size.width > self.frame.midX - fitsize.width/2 + fitsize.width)
            {
                return self.frame.midX - fitsize.width/2;
            }
            else {
                return 16;
            }
        }
        else {
            if(self.contentView.frame.size.width > self.frame.midX + fitsize.width/2 + 16 + 22 + 16) {
                return self.frame.midX - fitsize.width/2;
            }
            else {
                return 16;
            }
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        let width = contentView.frame.width
        var frame = CGRect(x: 10, y: 0, width: width - 20, height: PickerViewTableViewCell.pickerHeight)
        frame.size = pickerView.sizeThatFits(frame.size)
        frame.origin.x = width/2 - frame.width/2
        pickerView.frame = frame
    }

    override func prepareForReuse() {
        items = []
        delegate = nil
        dataSource = nil
        selectedRow = nil
    }
}
