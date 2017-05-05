//
//  ViewFactory.swift
//  IngenicoConnectExample
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2016 Global Collect Services. All rights reserved.
//

import Foundation
import UIKit

class ViewFactory {
    
    func buttonWithType(type: ButtonType) -> Button {
        let button = Button()
        button.type = type

        return button
    }
    
    func switchWithType(type: ViewType) -> Switch {
        var switchControl: Switch?
        switch type {
        case .gcSwitchType:
            switchControl = Switch()
        default:
            NSException(name: NSExceptionName(rawValue: "Invalid type of switch"), reason: "Switch type is invalid", userInfo: nil).raise()
        }
        
        return switchControl!
    }
    
    func getTextField() -> TextField {
        return TextField()
    }
    
    func getIntegerTextField() -> IntegerTextField {
        return IntegerTextField()
    }
    
    func getFractionalTextField() -> FractionalTextField {
        return FractionalTextField()
    }
    
    func pickerViewWithType(type: ViewType) -> PickerView {
        var pickerView: PickerView?
        switch type {
        case .gcPickerViewType:
            pickerView = PickerView()
        default:
            NSException(name: NSExceptionName(rawValue: "Invalid type of pickerView"), reason: "Pickerview type is invalid", userInfo: nil).raise()
        }
        
        return pickerView!
    }
    
    func labelWithType(type: ViewType) -> Label {
        var label: Label?
        switch type {
        case .gcLabelType:
            label = Label()
        default:
            NSException(name: NSExceptionName(rawValue: "Invalid type of label"), reason: "Label type is invalid", userInfo: nil).raise()
        }
        
        return label!
    }
    
    func tableHeaderViewWithType(type: ViewType, frame: CGRect) -> SummaryTableHeaderView {
        switch type {
        case .gcSummaryTableHeaderViewType:
            return SummaryTableHeaderView(frame: frame)
        default:
            NSException(name: NSExceptionName(rawValue: "Invalid type of tableHeaderView"), reason: "TableHeaderView type is invalid", userInfo: nil).raise()
            return SummaryTableHeaderView()
        }
    }
    
}

