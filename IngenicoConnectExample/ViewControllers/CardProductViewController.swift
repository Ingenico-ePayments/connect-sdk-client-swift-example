//
//  CardProductViewController.swift
//  IngenicoConnectExample
//
//  Created for Ingenico ePayments on 18/04/2017.
//  Copyright © 2017 Ingenico. All rights reserved.
//

import UIKit
import IngenicoConnectKit

class CardProductViewController: PaymentProductViewController {

    
    var cursorPositionInCreditCardNumberTextField: UITextPosition?
    var iinDetailsResponse: IINDetailsResponse?
    var cobrands: [IINDetail] = []
    override func registerReuseIdentifiers() {
        super.registerReuseIdentifiers()
        tableView.register(CoBrandsSelectionTableViewCell.self, forCellReuseIdentifier: CoBrandsSelectionTableViewCell.reuseIdentifier)
        tableView.register(COBrandsExplanationTableViewCell.self, forCellReuseIdentifier: COBrandsExplanationTableViewCell.reuseIdentifier)
        tableView.register(PaymentProductTableViewCell.self, forCellReuseIdentifier: PaymentProductTableViewCell.reuseIdentifier)
    }
    
    override func updateTextFieldCell(cell: TextFieldTableViewCell, row: FormRowTextField) {
        super.updateTextFieldCell(cell: cell, row: row)
        
        // Add card logo for cardNumber field
        if row.paymentProductField.identifier == "cardNumber" {
            if confirmedPaymentProducts.contains(paymentItem.identifier) {
                let view = UIImageView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
                view.contentMode = .scaleAspectFit
                row.logo = paymentItem.displayHints.logoImage
                view.image = row.logo
                cell.rightView = view
            }
            else {
                row.logo = nil
                cell.rightView = UIView()
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let row = formRows[indexPath.row]
        
        if (row is FormRowCoBrandsExplanation || row is PaymentProductsTableRow), !row.isEnabled {
            return 0
        } else if row is FormRowCoBrandsExplanation {
            let cellString = COBrandsExplanationTableViewCell.cellString()
            let rect = cellString.boundingRect(with: CGSize(width: tableView.bounds.size.width, height: CGFloat.greatestFiniteMagnitude), options: .usesLineFragmentOrigin, context: nil)
            return rect.size.height + 20
        } else if row is FormRowCoBrandsSelection {
            return 30
        }
        
        return super.tableView(tableView, heightForRowAt: indexPath)
    }
    
    override func formRowCell(for row: FormRow, indexPath: IndexPath) -> UITableViewCell {
        if let formRow = row as? FormRowCoBrandsSelection {
            return self.cell(for: formRow, tableView: tableView)
        } else if let formRow = row as? FormRowCoBrandsExplanation {
            return self.cell(for: formRow, tableView: tableView)
        } else if let formRow = row as? PaymentProductsTableRow {
            return self.cell(forPaymentProduct: formRow, tableView: tableView)
        }
        
        return super.formRowCell(for: row, indexPath: indexPath)
    }
    
    func cell(for row: FormRowCoBrandsSelection, tableView: UITableView) -> CoBrandsSelectionTableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: CoBrandsSelectionTableViewCell.reuseIdentifier) as! CoBrandsSelectionTableViewCell
    }
    
    func cell(for row: FormRowCoBrandsExplanation, tableView: UITableView) -> COBrandsExplanationTableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: COBrandsExplanationTableViewCell.reuseIdentifier) as! COBrandsExplanationTableViewCell
    }
    
    func cell(forPaymentProduct row: PaymentProductsTableRow, tableView: UITableView) -> PaymentProductTableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PaymentProductTableViewCell.reuseIdentifier) as! PaymentProductTableViewCell
        
        cell.name = row.name
        cell.logo = row.logo
        
        cell.accessoryType = .none
        cell.shouldHaveMaximalWidth = true
        cell.color = UIColor(white: 0.9, alpha: 1)
        cell.setNeedsLayout()
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        super.tableView(tableView, didSelectRowAt: indexPath)
        
        if let row = formRows[indexPath.row] as? PaymentProductsTableRow, row.paymentProductIdentifier != self.paymentItem.identifier {
            switchToPaymentProduct(paymentProductId: row.paymentProductIdentifier)
            return
        }
        
        if formRows[indexPath.row] is FormRowCoBrandsSelection || formRows[indexPath.row] is PaymentProductsTableRow {
            formRows = formRows.map {
                if $0 is FormRowCoBrandsExplanation || $0 is PaymentProductsTableRow {
                    $0.isEnabled = !$0.isEnabled
                }
                return $0
            }
            updateFormRows()
        }
    }
    override func updateFormRows() {
        if self.switching {
            
            // We need to update the tableView to the new amount of rows. However, we cannot use tableView.reloadData(), because then
            // the current textfield losses focus. We also should not reload the cardNumber row with tableView.reloadRows([indexOfCardNumber, with: ...) 
            // because that also makes the textfield lose focus.
            
            // Because the cardNumber field might move, we cannot just insert/delete the difference in rows in general, because if we 
            // do, the index of the cardNumber field might change, and we cannot reload the new place.
            
            // So instead, we check the difference in rows before the cardNumber field between before the mutation and after the mutation, 
            // and the difference in rows after the cardNumber field between before and after the mutations
                        
            tableView.beginUpdates()
            let oldFormRows = self.formRows
            self.initializeFormRows()
            self.addExtraRows()
            let oldCardNumberIndex = oldFormRows.index(where: { (r) -> Bool in
                (r as? FormRowTextField)?.paymentProductField.identifier == "cardNumber"
            }) ?? 0
            let newCardNumberIndex = self.formRows.index(where: { (r) -> Bool in
                (r as? FormRowTextField)?.paymentProductField.identifier == "cardNumber"
            })  ?? 0
            
            let diffCardNumberIndex = newCardNumberIndex - oldCardNumberIndex

            if (diffCardNumberIndex >= 0) {
                let insertIndexes = (0 ..< diffCardNumberIndex).map{ (i) in IndexPath(row: oldCardNumberIndex - 1 + i, section: 0)}
                tableView.insertRows(at:  insertIndexes, with: UITableViewRowAnimation.automatic)
                let updateIndexes = (0 ..< oldCardNumberIndex).map { (i) in IndexPath(row: i, section: 0) }
                tableView.reloadRows(at: updateIndexes, with: UITableViewRowAnimation.automatic)

            }
            if (diffCardNumberIndex < 0) {
                let deleteIndexes = (0 ..< -diffCardNumberIndex).map{ (i) in IndexPath(row:  i, section: 0)}
                tableView.deleteRows(at:  deleteIndexes, with: UITableViewRowAnimation.automatic)
                let updateIndexes = (0 ..< oldCardNumberIndex + diffCardNumberIndex).map { (i) in IndexPath(row: oldCardNumberIndex - i, section: 0) }
                tableView.reloadRows(at: updateIndexes, with: UITableViewRowAnimation.automatic)
            }

            let oldAfterCardNumberCount = oldFormRows.count - oldCardNumberIndex - 1
            var newAfterCardNumberCount = formRows.count - newCardNumberIndex - 1
            
            let diffAfterCardNumberCount = newAfterCardNumberCount - oldAfterCardNumberCount
            if newAfterCardNumberCount < 0 {
                newAfterCardNumberCount = 0
            }
            if (diffAfterCardNumberCount >= 0) {
                let insertIndexes = (0 ..< diffAfterCardNumberCount).map{ (i) in IndexPath(row: oldFormRows.count + i, section: 0)}
                tableView.insertRows(at:  insertIndexes, with: UITableViewRowAnimation.automatic)
                let updateIndexes = (0 ..< oldAfterCardNumberCount).map { (i) in IndexPath(row: i + oldCardNumberIndex + 1, section: 0) }
                tableView.reloadRows(at: updateIndexes, with: UITableViewRowAnimation.automatic)

            }
            if (diffAfterCardNumberCount < 0) {
                let deleteIndexes = (0 ..< -diffAfterCardNumberCount).map{ (i) in IndexPath(row:  oldFormRows.count - i - 1, section: 0)}
                tableView.deleteRows(at:  deleteIndexes, with: UITableViewRowAnimation.automatic)
                let updateIndexes = (0 ..< newAfterCardNumberCount).map { (i) in IndexPath(row: self.formRows.count - i - 1 - diffCardNumberIndex, section: 0) }
                tableView.reloadRows(at: updateIndexes, with: UITableViewRowAnimation.automatic)

            }
            
            tableView.endUpdates()
        }
        super.updateFormRows()
    }
    override func formatAndUpdateCharacters(textField: UITextField, cursorPosition: inout Int, indexPath: IndexPath) {
        super.formatAndUpdateCharacters(textField: textField, cursorPosition: &cursorPosition, indexPath: indexPath)
        
        guard let row = formRows[indexPath.row] as? FormRowTextField else {
            return
        }
        
        if row.paymentProductField.identifier == "cardNumber" {
            var unmasked = inputData.unmaskedValue(forField: row.paymentProductField.identifier)
            if unmasked.characters.count >= 6, cursorPosition <= 7 {
                unmasked = unmasked.substring(to: unmasked.index(unmasked.startIndex, offsetBy: 6))
                session.iinDetails(forPartialCreditCardNumber: unmasked, context: context, success: {(_ response: IINDetailsResponse) -> Void in
                    guard self.inputData.unmaskedValue(forField: row.paymentProductField.identifier).characters.count >= 6 else {
                        return
                    }
                    
                    self.iinDetailsResponse = response
                    
                    self.cobrands = response.coBrands;
                    if response.status == .supported {
                        var coBrandSelected = false
                        let coBrands = response.coBrands
                        for coBrand: IINDetail in coBrands {
                            if coBrand.paymentProductId == self.paymentItem.identifier {
                                coBrandSelected = true
                            }
                        }
                        if !coBrandSelected {
                            self.switchToPaymentProduct(paymentProductId: response.paymentProductId)
                        }
                        else {
                            self.switchToPaymentProduct(paymentProductId: self.paymentItem.identifier)
                        }
                    }
                    else {
                        self.switchToPaymentProduct(paymentProductId: self.initialPaymentProduct?.identifier)
                    }
                    

                }, failure: { error in
                })
            } else if unmasked.characters.count < 6 {
                // Remove cobrands
                var deleteRows = [IndexPath]()
                for (index, row) in self.formRows.enumerated() {
                    if row is FormRowCoBrandsSelection || row is FormRowCoBrandsExplanation || row is PaymentProductsTableRow {
                        deleteRows.append(IndexPath(row: index, section: 0))
                    }
                    //if let row = row as? FormRowTextField, row.paymentProductField.identifier == "cardNumber" {
                    //    updateFormRows()
                    //}
                }
                for indexPath in deleteRows.reversed() {
                    self.formRows.remove(at: indexPath.row)
                }
                self.tableView.deleteRows(at: deleteRows, with: .none)
                
                // To toggle card logo
                //switchToPaymentProduct(paymentProductId: self.initialPaymentProduct?.identifier)
            }
        }
    }
    
    func coBrandForms(inputCoBrands: [IINDetail]) -> [FormRow] {
        var coBrands = [String]()
        for coBrand: IINDetail in inputCoBrands where coBrand.allowedInContext {
            coBrands.append(coBrand.paymentProductId)
        }
        var formRows = [FormRow]()
        
        if coBrands.count > 1 {
            //Add explanation row
            let explanationRow = FormRowCoBrandsExplanation()
            formRows.append(explanationRow)
            
            //Add row for selection coBrands
            for id in coBrands {
                let row = PaymentProductsTableRow()
                row.paymentProductIdentifier = id
                
                let paymentProductKey = "gc.general.paymentProducts.\(id).name"
                let paymentProductValue = NSLocalizedString(paymentProductKey, tableName: SDKConstants.kSDKLocalizable, bundle: AppConstants.sdkBundle, value: "", comment: "")
                row.name = paymentProductValue
                
                let assetManager = AssetManager()
                let logo = assetManager.logoImage(forItem: id)
                row.logo = logo
                
                formRows.append(row)
            }
            
            let toggleCoBrandRow = FormRowCoBrandsSelection()
            formRows.append(toggleCoBrandRow)
        }
        
        return formRows
    }
    override func initializeFormRows() {
        super.initializeFormRows()
        let newFormRows = coBrandForms(inputCoBrands: self.cobrands)
        self.formRows.insert(contentsOf: newFormRows, at: 2)
    }
}
