//
//  ViewType.swift
//  IngenicoConnectExample
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2016 Global Collect Services. All rights reserved.
//

import Foundation

enum ViewType {
    // Switches
    case gcSwitchType
    
    // PickerViews
    case gcPickerViewType
    
    // TextFields
    case gcTextFieldType
    case gcIntegerTextFieldType
    case gcFractionalTextFieldType
    
    // Buttons
    case gcPrimaryButtonType
    case gcSecondaryButtonType
    
    // Labels
    case gcLabelType
    
    // TableViewCells
    case gcPaymentProductTableViewCellType
    case gcTextFieldTableViewCellType
    case gcCurrencyTableViewCellType
    case gcErrorMessageTableViewCellType
    case gcSwitchTableViewCellType
    case gcPickerViewTableViewCellType
    case gcButtonTableViewCellType
    case gcLabelTableViewCellType
    case gcTooltipTableViewCellType
    case gcCoBrandsSelectionTableViewCellType
    case gcCoBrandsExplanationTableViewCellType
    
    // TableHeaderView
    case gcSummaryTableHeaderViewType
    
    //TableFooterView
    case gcButtonsTableFooterViewType
}
