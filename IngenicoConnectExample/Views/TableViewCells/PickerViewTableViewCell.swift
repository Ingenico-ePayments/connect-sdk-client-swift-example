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
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubview(pickerView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let width = contentView.frame.size.width
        pickerView.frame = CGRect(x: 10, y: 0, width: width - 20, height: 162)
    }

    override func prepareForReuse() {
        items = []
        delegate = nil
        dataSource = nil
        selectedRow = nil
    }
}
