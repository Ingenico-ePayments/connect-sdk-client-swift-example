//
//  PaymentProductsViewController.swift
//  IngenicoConnectExample
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2016 Global Collect Services. All rights reserved.
//

import UIKit
import IngenicoConnectKit

class PaymentProductsViewController: UITableViewController {
    
    var viewFactory: ViewFactory!
    var paymentItems: PaymentItems!
    
    var target: PaymentProductSelectionTarget?
    var amount = 0
    var currencyCode = ""
    
    var sections = [PaymentProductsTableSection]()
    var header : SummaryTableHeaderView!
    
    init(style: UITableViewStyle, viewFactory: ViewFactory, paymentItems:PaymentItems) {
        super.init(style: style)
        
        self.viewFactory = viewFactory
        self.paymentItems = paymentItems
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {        
        view.backgroundColor = UIColor.white
        navigationItem.titleView = MerchantLogoImageView()
        initializeHeader()
        
        //TODO: Accounts on file
        if paymentItems.hasAccountsOnFile {
            let accountsSection = TableSectionConverter.paymentProductsTableSectionFromAccounts(onFile: paymentItems.accountsOnFile, paymentItems: paymentItems)
            accountsSection.title = NSLocalizedString("gc.app.paymentProductSelection.accountsOnFileTitle", tableName: SDKConstants.kSDKLocalizable, bundle: AppConstants.sdkBundle, value: "", comment: "Title of the section that displays stored payment products.")
            sections.append(accountsSection)
        }
        
        let productsSection = TableSectionConverter.paymentProductsTableSection(from: paymentItems)
        productsSection.title = NSLocalizedString("gc.app.paymentProductSelection.pageTitle", tableName: SDKConstants.kSDKLocalizable, bundle: AppConstants.sdkBundle, value: "", comment: "Title of the section that shows all available payment products.")
        sections.append(productsSection)
        
        // Register reusable views
        tableView.register(PaymentProductTableViewCell.self, forCellReuseIdentifier: PaymentProductTableViewCell.reuseIdentifier)
    }
    
    func initializeHeader() {
        header = viewFactory.tableHeaderViewWithType(type: .gcSummaryTableHeaderViewType, frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 70))
        let totalLabel = NSLocalizedString("gc.app.general.shoppingCart.total", tableName: SDKConstants.kSDKLocalizable, bundle: AppConstants.sdkBundle, value: "", comment: "Description of the amount header.")
        header.setSummary(summary: "\(totalLabel):")
        let amountAsNumber = (amount / 100) as NSNumber
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        numberFormatter.currencyCode = currencyCode
        let amountAsString = numberFormatter.string(from: amountAsNumber)!
        header.setAmount(amount: amountAsString)
        header.setSecurePayment(securePayment: NSLocalizedString("gc.app.general.securePaymentText", tableName: SDKConstants.kSDKLocalizable, bundle: AppConstants.sdkBundle, value: "", comment: "Text indicating that a secure payment method is used."))
        tableView.tableHeaderView = header
    }
    
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let tableSection = sections[section]
        return tableSection.rows.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String {
        let tableSection = sections[section]
        return tableSection.title
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PaymentProductTableViewCell.reuseIdentifier)! as! PaymentProductTableViewCell
        
        let section = sections[indexPath.section]
        let row = section.rows[indexPath.row]
        cell.name = row.name
        cell.logo = row.logo
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = sections[indexPath.section]
        let row = section.rows[indexPath.row]
        let paymentItem = paymentItems.paymentItem(withIdentifier: row.paymentProductIdentifier)
        
        if section.type == .gcAccountOnFileType,
            let product = paymentItem as? BasicPaymentProduct,
            let accountOnFile = product.accountOnFile(withIdentifier: row.accountOnFileIdentifier)
        {
            target?.didSelect(paymentItem: product, accountOnFile: accountOnFile)
        } else if let paymentItem = paymentItem {
            target?.didSelect(paymentItem: paymentItem, accountOnFile: nil)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
