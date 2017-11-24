//
//  StartViewController.swift
//  IngenicoConnectExample
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2016 Global Collect Services. All rights reserved.
//

import Foundation
import PassKit
import UIKit
import SVProgressHUD
import IngenicoConnectKit

// Enable subscripting userdefaults
extension UserDefaults {
    subscript(key: String) -> Any? {
        get {
            return object(forKey: key)
        }
        set {
            set(newValue, forKey: key)
        }
    }
}

public class StartViewController: UIViewController, ContinueShoppingTarget, PaymentFinishedTarget {
    
    var containerView: UIView!
    var scrollView: UIScrollView!
    
    var explanation: UITextView!
    var clientSessionIdLabel: Label!
    var clientSessionIdTextField: TextField!
    var customerIdLabel: Label!
    var customerIdTextField: TextField!
    var merchantIdLabel: Label!
    var merchantIdTextField: TextField!
    var regionLabel: Label!
    var regionControl: UISegmentedControl!
    var environmentLabel: Label!
    var environmentPicker: PickerView!
    var amountLabel: Label!
    var amountTextField: TextField!
    var countryCodeLabel: Label!
    var countryCodePicker: PickerView!
    var currencyCodeLabel: Label!
    var currencyCodePicker: PickerView!
    var isRecurringLabel: Label!
    var isRecurringSwitch: Switch!
    var payButton: UIButton!
    var shouldGroupProductsSwitch: UISwitch!

    var paymentProductsViewControllerTarget: PaymentProductsViewControllerTarget?
    
    var amountValue: Int = 0
    
    var viewFactory: ViewFactory!
    var session: Session?
    var context: PaymentContext?
    
    var countryCodes = [CountryCode]()
    var currencyCodes = [CurrencyCode]()
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        initializeTapRecognizer()
        
        if responds(to: #selector(getter: edgesForExtendedLayout)) {
            edgesForExtendedLayout = []
        }
        
        viewFactory = ViewFactory()
        
        countryCodes = CountryCode.allValues.sorted { $0.rawValue.localizedCaseInsensitiveCompare($1.rawValue) == .orderedAscending }
        currencyCodes = CurrencyCode.allValues.sorted { $0.rawValue.localizedCaseInsensitiveCompare($1.rawValue) == .orderedAscending }
        
        let viewHeight: CGFloat = 1530
        
        scrollView = UIScrollView(frame: view.bounds)
        scrollView.delaysContentTouches = false
        scrollView.contentSize = CGSize(width: CGFloat(view.bounds.size.width), height: CGFloat(viewHeight))
        scrollView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        view.addSubview(scrollView)
        
        let superContainerView = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.size.width, height: viewHeight))
        superContainerView.autoresizingMask = .flexibleWidth
        scrollView.addSubview(superContainerView)
        
        containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        superContainerView.addSubview(containerView!)
        
        var constraint = NSLayoutConstraint(item: containerView!, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: viewHeight)
        containerView.addConstraint(constraint)
        constraint = NSLayoutConstraint(item: containerView!, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 320)
        containerView.addConstraint(constraint)
        constraint = NSLayoutConstraint(item: containerView!, attribute: .centerX, relatedBy: .equal, toItem: superContainerView, attribute: .centerX, multiplier: 1, constant: 0)
        superContainerView.addConstraint(constraint)
        constraint = NSLayoutConstraint(item: containerView!, attribute: .top, relatedBy: .equal, toItem: superContainerView, attribute: .top, multiplier: 1, constant: 0)
        superContainerView.addConstraint(constraint)
        
        explanation = UITextView()
        explanation.translatesAutoresizingMaskIntoConstraints = false
        explanation.text = NSLocalizedString("SetupExplanation", tableName: AppConstants.kAppLocalizable, bundle: AppConstants.appBundle, value: "", comment: "To process a payment using the services provided by the Ingenico ePayments platform, the following information must be provided by a merchant.\n\nAfter providing the information requested below, this example app can process a payment.")
        explanation.isEditable = false
        explanation.backgroundColor = UIColor(red: CGFloat(0.85), green: CGFloat(0.94), blue: CGFloat(0.97), alpha: CGFloat(1))
        explanation.textColor = UIColor(red: CGFloat(0), green: CGFloat(0.58), blue: CGFloat(0.82), alpha: CGFloat(1))
        explanation.layer.cornerRadius = 5.0
        containerView.addSubview(explanation)
        
        clientSessionIdLabel = viewFactory.labelWithType(type: .gcLabelType)
        clientSessionIdLabel.text = NSLocalizedString("ClientSessionIdentifier", tableName: AppConstants.kAppLocalizable, bundle: AppConstants.appBundle, value: "", comment: "Client session identifier")
        clientSessionIdLabel.translatesAutoresizingMaskIntoConstraints = false
        clientSessionIdTextField = viewFactory.getTextField()
        clientSessionIdTextField.translatesAutoresizingMaskIntoConstraints = false
        clientSessionIdTextField.autocapitalizationType = .none
        if let text = UserDefaults.standard.value(forKey: AppConstants.kClientSessionId) as? String {
            clientSessionIdTextField.text = text
        } else {
            clientSessionIdTextField.text = ""
        }
        
        containerView.addSubview(clientSessionIdLabel)
        containerView.addSubview(clientSessionIdTextField)
        
        customerIdLabel = viewFactory.labelWithType(type: .gcLabelType)
        customerIdLabel.text = NSLocalizedString("CustomerIdentifier", tableName: AppConstants.kAppLocalizable, bundle: AppConstants.appBundle, value: "", comment: "Customer identifier")
        customerIdLabel.translatesAutoresizingMaskIntoConstraints = false
        customerIdTextField = viewFactory.getTextField()
        customerIdTextField.translatesAutoresizingMaskIntoConstraints = false
        customerIdTextField.autocapitalizationType = .none
        if let text = UserDefaults.standard.value(forKey: AppConstants.kCustomerId) as? String {
            customerIdTextField.text = text
        } else {
            customerIdTextField.text = ""
        }
        containerView.addSubview(customerIdLabel)
        containerView.addSubview(customerIdTextField)
        
        merchantIdLabel = viewFactory.labelWithType(type: .gcLabelType)
        merchantIdLabel.text = NSLocalizedString("MerchantIdentifier", tableName: AppConstants.kAppLocalizable, bundle: AppConstants.appBundle, value: "", comment: "Merchant identifier")
        merchantIdLabel.translatesAutoresizingMaskIntoConstraints = false
        merchantIdTextField = viewFactory.getTextField()
        merchantIdTextField.translatesAutoresizingMaskIntoConstraints = false
        merchantIdTextField.autocapitalizationType = .none
        if let text = UserDefaults.standard.value(forKey: AppConstants.kMerchantId) as? String {
            merchantIdTextField.text = text
        } else {
            merchantIdTextField.text = ""
        }
        containerView.addSubview(merchantIdLabel)
        containerView.addSubview(merchantIdTextField)
        
        regionLabel = viewFactory.labelWithType(type: .gcLabelType)
        regionLabel.text = NSLocalizedString("Region", tableName: AppConstants.kAppLocalizable, bundle: AppConstants.appBundle, value: "", comment: "Region")
        regionLabel.translatesAutoresizingMaskIntoConstraints = false
        regionControl = UISegmentedControl(items: ["EU", "US", "AMS", "PAR"])
        regionControl.selectedSegmentIndex = 0
        regionControl.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(regionLabel)
        containerView.addSubview(regionControl)
        
        environmentLabel = viewFactory.labelWithType(type: .gcLabelType)
        environmentLabel.text = NSLocalizedString("Environment", tableName: AppConstants.kAppLocalizable, bundle: AppConstants.appBundle, value: "", comment: "Environment")
        environmentLabel.translatesAutoresizingMaskIntoConstraints = false
        environmentPicker = viewFactory.pickerViewWithType(type: .gcPickerViewType)
        environmentPicker.translatesAutoresizingMaskIntoConstraints = false
        environmentPicker.content = ["Production", "Pre-production", "Sandbox"]
        environmentPicker.dataSource = self
        environmentPicker.delegate = self
        environmentPicker.selectRow(2, inComponent: 0, animated: false)
        containerView.addSubview(environmentLabel)
        containerView.addSubview(environmentPicker)
        
        amountLabel = viewFactory.labelWithType(type: .gcLabelType)
        amountLabel.text = NSLocalizedString("AmountInCents", tableName: AppConstants.kAppLocalizable, bundle: AppConstants.appBundle, value: "", comment: "Amount in cents")
        amountLabel.translatesAutoresizingMaskIntoConstraints = false
        amountTextField = viewFactory.getTextField()
        amountTextField.translatesAutoresizingMaskIntoConstraints = false
        amountTextField.text = "100"
        containerView.addSubview(amountLabel)
        containerView.addSubview(amountTextField)
        
        countryCodeLabel = viewFactory.labelWithType(type: .gcLabelType)
        countryCodeLabel.text = NSLocalizedString("CountryCode", tableName: AppConstants.kAppLocalizable, bundle: AppConstants.appBundle, value: "", comment: "Country code")
        countryCodeLabel.translatesAutoresizingMaskIntoConstraints = false
        countryCodePicker = viewFactory.pickerViewWithType(type: .gcPickerViewType)
        countryCodePicker.translatesAutoresizingMaskIntoConstraints = false
        countryCodePicker.content = countryCodes.map { $0.rawValue }
        countryCodePicker.dataSource = self
        countryCodePicker.delegate = self
        countryCodePicker.selectRow(165, inComponent: 0, animated: false)
        containerView.addSubview(countryCodeLabel)
        containerView.addSubview(countryCodePicker)
        
        currencyCodeLabel = viewFactory.labelWithType(type: .gcLabelType)
        currencyCodeLabel.text = NSLocalizedString("CurrencyCode", tableName: AppConstants.kAppLocalizable, bundle: AppConstants.appBundle, value: "", comment: "Currency code")
        currencyCodeLabel.translatesAutoresizingMaskIntoConstraints = false
        currencyCodePicker = viewFactory.pickerViewWithType(type: .gcPickerViewType)
        currencyCodePicker.translatesAutoresizingMaskIntoConstraints = false
        currencyCodePicker.content = currencyCodes.map { $0.rawValue }
        currencyCodePicker.dataSource = self
        currencyCodePicker.delegate = self
        currencyCodePicker.selectRow(42, inComponent: 0, animated: false)
        containerView.addSubview(currencyCodeLabel)
        containerView.addSubview(currencyCodePicker)
        
        isRecurringLabel = viewFactory.labelWithType(type: .gcLabelType)
        isRecurringLabel.text = NSLocalizedString("RecurringPayment", tableName: AppConstants.kAppLocalizable, bundle: AppConstants.appBundle, value: "", comment: "Payment is recurring")
        isRecurringLabel.translatesAutoresizingMaskIntoConstraints = false
        isRecurringSwitch = viewFactory.switchWithType(type: .gcSwitchType)
        isRecurringSwitch.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(isRecurringLabel)
        containerView.addSubview(isRecurringSwitch)
        
        let shouldGroupProductsSwitchLabel = viewFactory.labelWithType(type: .gcLabelType)
        shouldGroupProductsSwitchLabel.text = NSLocalizedString("ShouldGroupProductsSwitch", tableName: AppConstants.kAppLocalizable, bundle: AppConstants.appBundle, value: "Group payment products", comment: "Label for switch to enable product grouping")
        shouldGroupProductsSwitchLabel.translatesAutoresizingMaskIntoConstraints = false
        shouldGroupProductsSwitch = viewFactory.switchWithType(type: .gcSwitchType)
        shouldGroupProductsSwitch.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(shouldGroupProductsSwitchLabel)
        containerView.addSubview(shouldGroupProductsSwitch)

        payButton = viewFactory.buttonWithType(type: .primary)
        payButton.setTitle(NSLocalizedString("PayNow", tableName: AppConstants.kAppLocalizable, bundle: AppConstants.appBundle, value: "", comment: "Pay securely now"), for: .normal)
        payButton.translatesAutoresizingMaskIntoConstraints = false
        payButton.addTarget(self, action: #selector(StartViewController.buyButtonTapped), for: .touchUpInside)
        containerView.addSubview(payButton)
        
        let views: [String:AnyObject] = [
            "explanation": explanation,
            "clientSessionIdLabel": clientSessionIdLabel,
            "clientSessionIdTextField": clientSessionIdTextField,
            "customerIdLabel": customerIdLabel,
            "customerIdTextField": customerIdTextField,
            "merchantIdLabel": merchantIdLabel,
            "merchantIdTextField": merchantIdTextField,
            "regionLabel": regionLabel,
            "regionControl": regionControl,
            "environmentLabel": environmentLabel,
            "environmentPicker": environmentPicker,
            "amountLabel": amountLabel,
            "amountTextField": amountTextField,
            "countryCodeLabel": countryCodeLabel,
            "countryCodePicker": countryCodePicker,
            "currencyCodeLabel": currencyCodeLabel,
            "currencyCodePicker": currencyCodePicker,
            "isRecurringLabel": isRecurringLabel,
            "isRecurringSwitch": isRecurringSwitch,
            "payButton": payButton,
            "shouldGroupProductsSwitchLabel": shouldGroupProductsSwitchLabel,
            "shouldGroupProductsSwitch": shouldGroupProductsSwitch
        ]
        let metrics = ["largeSpace": "24"]
        
        containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|-[explanation]-|", options: [], metrics: nil, views: views))
        containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|-[clientSessionIdLabel]-|", options: [], metrics: nil, views: views))
        containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|-[clientSessionIdTextField]-|", options: [], metrics: nil, views: views))
        containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|-[customerIdLabel]-|", options: [], metrics: nil, views: views))
        containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|-[customerIdTextField]-|", options: [], metrics: nil, views: views))
        containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|-[merchantIdLabel]-|", options: [], metrics: nil, views: views))
        containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|-[merchantIdTextField]-|", options: [], metrics: nil, views: views))
        containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|-[regionLabel]-|", options: [], metrics: nil, views: views))
        containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|-[regionControl]-|", options: [], metrics: nil, views: views))
        containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|-[environmentLabel]-|", options: [], metrics: nil, views: views))
        containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|-[environmentPicker]-|", options: [], metrics: nil, views: views))
        containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|-[amountLabel]-|", options: [], metrics: nil, views: views))
        containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|-[amountTextField]-|", options: [], metrics: nil, views: views))
        containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|-[countryCodeLabel]-|", options: [], metrics: nil, views: views))
        containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|-[countryCodePicker]-|", options: [], metrics: nil, views: views))
        containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|-[currencyCodeLabel]-|", options: [], metrics: nil, views: views))
        containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|-[currencyCodePicker]-|", options: [], metrics: nil, views: views))
        //containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|-|", options: [], metrics: nil, views: views))
        containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|-[isRecurringLabel]-[isRecurringSwitch]-|", options: [.alignAllCenterY], metrics: nil, views: views))
        //containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|--|", options: [], metrics: nil, views: views))
        containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|-[shouldGroupProductsSwitchLabel]-[shouldGroupProductsSwitch]-|", options: [.alignAllCenterY], metrics: nil, views: views))
        containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|-[payButton]-|", options: [], metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-(largeSpace)-[explanation(==100)]-(largeSpace)-[clientSessionIdLabel]-[clientSessionIdTextField]-(largeSpace)-[customerIdLabel]-[customerIdTextField]-(largeSpace)-[merchantIdLabel]-[merchantIdTextField]-(largeSpace)-[regionLabel]-[regionControl]-(largeSpace)-[environmentLabel]-[environmentPicker]-(largeSpace)-[amountLabel]-[amountTextField]-(largeSpace)-[countryCodeLabel]-[countryCodePicker]-(largeSpace)-[currencyCodeLabel]-[currencyCodePicker]-(largeSpace)-[isRecurringSwitch]-(largeSpace)-[shouldGroupProductsSwitch]-(largeSpace)-[payButton]-|", options: [], metrics: metrics, views: views))
    }
    
    func initializeTapRecognizer() {
        let tapScrollView = UITapGestureRecognizer(target: self, action: #selector(tableViewTapped))
        tapScrollView.cancelsTouchesInView = false
        view.addGestureRecognizer(tapScrollView)
    }
    
    func tableViewTapped() {
        for view: UIView in containerView!.subviews {
            if let textField = view as? TextField, textField.isFirstResponder {
                textField.resignFirstResponder()
            }
        }
    }
    
    // MARK: Button actions
    
    func buyButtonTapped(_ sender: UIButton) {
        if payButton == sender, let newValue = Int(amountTextField.text!) {
            amountValue = newValue
        } else {
            NSException(name: NSExceptionName(rawValue: "Invalid sender"), reason: "Sender is invalid", userInfo: nil).raise()
        }
        
        SVProgressHUD.setDefaultMaskType(.clear)
        let status = NSLocalizedString("gc.app.general.loading.body", tableName: SDKConstants.kSDKLocalizable, bundle: AppConstants.sdkBundle, value: "",comment: "")
        SVProgressHUD.show(withStatus: status)
        
        let clientSessionId = clientSessionIdTextField.text
        UserDefaults.standard[AppConstants.kClientSessionId] = clientSessionId
        let customerId = customerIdTextField.text
        UserDefaults.standard[AppConstants.kCustomerId] = customerId
        if merchantIdTextField.text != nil {
            let merchantId = merchantIdTextField.text
            UserDefaults.standard.set(merchantId, forKey: AppConstants.kMerchantId)
        }
        
        let region: Region
        
        if regionControl.selectedSegmentIndex == 0 {
            region = .EU
        } else if regionControl.selectedSegmentIndex == 1 {
            region = .US
        } else if regionControl.selectedSegmentIndex == 2 {
            region = .AMS
        } else {
            region = .PAR
        }
        
        var environment = Environment.sandbox
        if environmentPicker.selectedRow(inComponent: 0) == 0 {
            environment = Environment.production
        } else if environmentPicker.selectedRow(inComponent: 0) == 1 {
            environment = Environment.preProduction
        }
        
        // ***************************************************************************
        //
        // The GlobalCollect SDK supports processing payments with instances of the
        // Session class. The code below shows how such an instance chould be
        // instantiated.
        //
        // The Session class uses a number of supporting objects. There is an
        // initializer for this class that takes these supporting objects as
        // arguments. This should make it easy to replace these additional objects
        // without changing the implementation of the SDK. Use this initializer
        // instead of the factory method used below if you want to replace any of the
        // supporting objects.
        //
        // ***************************************************************************
        
        session = Session(clientSessionId: clientSessionId!, customerId: customerId!, region: region, environment: environment, appIdentifier: AppConstants.kApplicationIdentifier)

        let countryCode = countryCodes[countryCodePicker.selectedRow(inComponent: 0)]
        let currencyCode = currencyCodes[currencyCodePicker.selectedRow(inComponent: 0)]
        let isRecurring = isRecurringSwitch.isOn
        
        // ***************************************************************************
        //
        // To retrieve the available payment products, the information stored in the
        // following PaymentContext object is needed.
        //
        // After the Session object has retrieved the payment products that match
        // the information stored in the PaymentContext object, a
        // selection screen is shown. This screen itself is not part of the SDK and
        // only illustrates a possible payment product selection screen.
        //
        // ***************************************************************************
        do {
            let amountOfMoney = try PaymentAmountOfMoney(totalAmount: amountValue, currencyCode: currencyCode)
            context = try PaymentContext(amountOfMoney: amountOfMoney, isRecurring: isRecurring, countryCode: countryCode)
            session!.paymentItems(for: context!, groupPaymentProducts: self.shouldGroupProductsSwitch.isOn, success: {(_ paymentItems: PaymentItems) -> Void in
                SVProgressHUD.dismiss()
                self.showPaymentProductSelection(paymentItems)
            }, failure: { error in
                SVProgressHUD.dismiss()
                let alert = UIAlertController(title: NSLocalizedString("ConnectionErrorTitle", tableName: AppConstants.kAppLocalizable, bundle: AppConstants.appBundle, value: "", comment: ""),
                                              message: NSLocalizedString("PaymentProductsErrorExplanation", tableName: AppConstants.kAppLocalizable, bundle: AppConstants.appBundle, value: "", comment: ""),
                                              preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            })
        }
        catch {
            
        }
    }
    
    func showPaymentProductSelection(_ paymentItems: PaymentItems) {
        if let session = session, let context = context {
            paymentProductsViewControllerTarget = PaymentProductsViewControllerTarget(navigationController: navigationController!, session: session, context: context, viewFactory: viewFactory)
            paymentProductsViewControllerTarget!.paymentFinishedTarget = self
            let paymentProductSelection = PaymentProductsViewController(style: .grouped, viewFactory: viewFactory, paymentItems: paymentItems)
            paymentProductSelection.target = paymentProductsViewControllerTarget
            paymentProductSelection.amount = amountValue
            paymentProductSelection.currencyCode = context.amountOfMoney.currencyCode.rawValue
            navigationController!.pushViewController(paymentProductSelection, animated: true)
            SVProgressHUD.dismiss()
        }
    }
    
    
    // MARK: Continue shopping target
    
    func didSelectContinueShopping() {
        navigationController!.popToRootViewController(animated: true)
    }
    
    // MARK: Payment finished target
    
    func didFinishPayment() {
        let end = EndViewController()
        end.target = self
        end.viewFactory = viewFactory
        navigationController!.pushViewController(end, animated: true)
    }
    
}


extension StartViewController:  UIPickerViewDelegate, UIPickerViewDataSource {
    // MARK: Picker view delegate
    
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        let picker = pickerView as! PickerView
        return picker.content.count
    }
    
    public func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let picker = pickerView as! PickerView
        let item = picker.content[row]
        let string = NSAttributedString(string: item)
        return string
    }
}
