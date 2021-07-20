//
//  BoletoProductViewController.swift
//  IngenicoConnectExample
//
//  Created for Ingenico ePayments on 26/04/2017.
//  Copyright © 2017 Ingenico. All rights reserved.
//

import UIKit
import IngenicoConnectKit

class BoletoProductViewController: PaymentProductViewController {

    private let switchLength = 14

    private enum FiscalNumberType {
        case personal
        case company
    }

    private var fiscalNumberType: FiscalNumberType = .personal

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        for row in formRows {
            if let fieldRow = row as? FormRowTextField, let validator = fieldRow.paymentProductField.dataRestrictions.validators.validators.first(where: { (validator) -> Bool in
                return validator is ValidatorBoletoBancarioRequiredness
            }) as? ValidatorBoletoBancarioRequiredness {
                if validator.fiscalNumberLength < switchLength {
                    row.isEnabled = fiscalNumberType == .personal
                } else {
                    row.isEnabled = fiscalNumberType == .company
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func formatAndUpdateCharacters(textField: UITextField, cursorPosition: inout Int, indexPath: IndexPath, trimSet: CharacterSet) {
        super.formatAndUpdateCharacters(textField: textField, cursorPosition: &cursorPosition, indexPath: indexPath)
        
        guard let row = formRows[indexPath.row] as? FormRowTextField else {
            return
        }

        if row.paymentProductField.identifier == "fiscalNumber" {
            switch fiscalNumberType {
            case .personal:
                if row.field.text.count >= switchLength {
                    fiscalNumberType = .company
                    updateFormRows()
                }
            case .company:
                if row.field.text.count < switchLength {
                    fiscalNumberType = .personal
                    updateFormRows()
                }
            }
        }
    }

    override func updateTextFieldCell(cell: TextFieldTableViewCell, row: FormRowTextField) {
        super.updateTextFieldCell(cell: cell, row: row)
        if let validator = row.paymentProductField.dataRestrictions.validators.validators.first(where: { (validator) -> Bool in
            return validator is ValidatorBoletoBancarioRequiredness
        }) as? ValidatorBoletoBancarioRequiredness {
            if validator.fiscalNumberLength < switchLength {
                row.isEnabled = fiscalNumberType == .personal
                cell.readonly = !row.isEnabled
            } else {
                row.isEnabled = fiscalNumberType == .company
                cell.readonly = !row.isEnabled
            }
        }
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let row = formRows[indexPath.row]
        
        if let fieldRow = row as? FormRowTextField, fieldRow.paymentProductField.dataRestrictions.validators.validators.contains(where: { (validator) -> Bool in
            return validator is ValidatorBoletoBancarioRequiredness
        }), !fieldRow.isEnabled {
            return 0
        } else if row is FormRowLabel, indexPath.row + 1 < formRows.count, let fieldRow = formRows[indexPath.row + 1] as? FormRowTextField, fieldRow.paymentProductField.dataRestrictions.validators.validators.contains(where: { (validator) -> Bool in
            return validator is ValidatorBoletoBancarioRequiredness
        }), !fieldRow.isEnabled {
            return 0
        }
        
        return super.tableView(tableView, heightForRowAt: indexPath)
    }
}
