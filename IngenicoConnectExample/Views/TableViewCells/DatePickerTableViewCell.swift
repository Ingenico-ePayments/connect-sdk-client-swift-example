//
//  DatePickerTableViewCell.swift
//  IngenicoConnectExample
//
//  Created for Ingenico ePayments on 18/10/2017.
//  Copyright © 2017 Ingenico. All rights reserved.
//

import UIKit

protocol DatePickerTableViewCellDelegate {
    func datePicker(_ datePicker: UIDatePicker, selectedNewDate date:Date)
}

class DatePickerTableViewCell : TableViewCell {
    class var pickerHeight: CGFloat { get { return 216 } }
    override class var reuseIdentifier: String { return "date-picker-cell" }
    
    var delegate: DatePickerTableViewCellDelegate?
    let datePicker: UIDatePicker = UIDatePicker()
    
    var date: Date {
        didSet{
            datePicker.date = date
        }
    }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        date = Date()
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        datePicker.datePickerMode = .date
        datePicker.addTarget(self, action: #selector(didPickNewDate(_:)), for: .valueChanged)
        datePicker.date = date
        addSubview(datePicker)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func didPickNewDate(_ sender: UIDatePicker) {
        delegate?.datePicker(sender, selectedNewDate: sender.date)
    }
    var readonly: Bool {
        get {
            return !self.datePicker.isEnabled
        }
        set {
            self.datePicker.isEnabled = !newValue
        }
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let width = contentView.frame.width
        var frame = CGRect(x: 10, y: 0, width: width - 20, height: DatePickerTableViewCell.pickerHeight)
        frame.size = datePicker.sizeThatFits(frame.size)
        frame.origin.x = width/2 - frame.width/2
        datePicker.frame = frame
    }
    
    override func prepareForReuse() {
        delegate = nil
    }
    
}
