//
//  EndViewController.swift
//  IngenicoConnectExample
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2016 Global Collect Services. All rights reserved.
//

import Foundation
import UIKit
import IngenicoConnectKit

class EndViewController: UIViewController {
    var target: ContinueShoppingTarget!
    var viewFactory: ViewFactory!
    var preparedPaymentRequest: PreparedPaymentRequest!
    var resultButton: UIButton!
    var encryptedText: UITextView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.hidesBackButton = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if responds(to: #selector(getter: UIViewController.edgesForExtendedLayout)) {
            edgesForExtendedLayout = []
        }
        view.backgroundColor = UIColor.white
        
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(container)
        
        var constraint = NSLayoutConstraint(item: container, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 750)
        container.addConstraint(constraint)
        constraint = NSLayoutConstraint(item: container, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 280)
        container.addConstraint(constraint)
        constraint = NSLayoutConstraint(item: container, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1, constant: 0)
        view.addConstraint(constraint)
        constraint = NSLayoutConstraint(item: container, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1, constant: 20)
        view.addConstraint(constraint)
        
        let label = UILabel()
        container.addSubview(label)
        label.textAlignment = .center
        label.text = NSLocalizedString("SuccessLabel", tableName: AppConstants.kAppLocalizable, bundle: AppConstants.appBundle, value: "", comment: "")
        label.translatesAutoresizingMaskIntoConstraints = false
        
        let textView = UITextView()
        container.addSubview(textView)
        textView.textAlignment = .center
        textView.text = NSLocalizedString("SuccessText", tableName: AppConstants.kAppLocalizable, bundle: AppConstants.appBundle, value: "", comment: "")
        textView.isEditable = false
        textView.backgroundColor = UIColor(red: 0.85, green: 0.94, blue: 0.97, alpha: 1)
        textView.textColor = UIColor(red: 0, green: 0.58, blue: 0.82, alpha: 1)
        textView.layer.cornerRadius = 5.0
        textView.translatesAutoresizingMaskIntoConstraints = false
        
        encryptedText = UITextView()
        container.addSubview(encryptedText)
        encryptedText.textAlignment = .left
        encryptedText.text = preparedPaymentRequest?.encryptedFields
        encryptedText.isEditable = false
        encryptedText.textColor = UIColor.black.withAlphaComponent(0.7)
        encryptedText.layer.cornerRadius = 5.0
        encryptedText.translatesAutoresizingMaskIntoConstraints = false
        encryptedText.isHidden = true
        encryptedText.isScrollEnabled = true
        
        resultButton = viewFactory.buttonWithType(type: .secondary)
        container.addSubview(resultButton)
        let encryptedDataButtonTitle = NSLocalizedString("EncryptedDataResultLabel", tableName: AppConstants.kAppLocalizable, bundle: AppConstants.appBundle, value: "", comment: "")
        resultButton.setTitle(encryptedDataButtonTitle, for: .normal)
        resultButton.addTarget(self, action: #selector(EndViewController.showEncryptedData), for: .touchUpInside)
        resultButton.translatesAutoresizingMaskIntoConstraints = false
        
        let button = viewFactory.buttonWithType(type: .primary)
        container.addSubview(button)
        let continueButtonTitle = NSLocalizedString("ContinueButtonTitle", tableName: AppConstants.kAppLocalizable, bundle: AppConstants.appBundle, value: "", comment: "")
        button.setTitle(continueButtonTitle, for: .normal)
        button.addTarget(self, action: #selector(EndViewController.continueButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        let viewMapping = ["label": label, "textView": textView, "button": button, "resultButton": resultButton!, "encryptedText": encryptedText!] as [String : Any]
        
        var constraints = NSLayoutConstraint.constraints(withVisualFormat: "|-[label]-|", options: [], metrics: nil, views: viewMapping)
        container.addConstraints(constraints)
        constraints = NSLayoutConstraint.constraints(withVisualFormat: "|-[textView]-|", options: [], metrics: nil, views: viewMapping)
        container.addConstraints(constraints)
        constraints = NSLayoutConstraint.constraints(withVisualFormat: "|-[encryptedText]-|", options: [], metrics: nil, views: viewMapping)
        container.addConstraints(constraints)
        constraints = NSLayoutConstraint.constraints(withVisualFormat: "|-[resultButton]-|", options: [], metrics: nil, views: viewMapping)
        container.addConstraints(constraints)
        constraints = NSLayoutConstraint.constraints(withVisualFormat: "|-[button]-|", options: [], metrics: nil, views: viewMapping)
        container.addConstraints(constraints)
        constraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|-[label]-(20)-[textView(115)]-(20)-[button]-(50)-[resultButton]-(20)-[encryptedText(250)]", options: [], metrics: nil, views: viewMapping)
        container.addConstraints(constraints)
    }
    
    @objc func continueButtonTapped() {
        target.didSelectContinueShopping()
    }
    
    @objc func showEncryptedData() {
        if (encryptedText.isHidden) {
            let copyButtonTitle = NSLocalizedString("CopyEncryptedDataLabel", tableName: AppConstants.kAppLocalizable, bundle: AppConstants.appBundle, value: "", comment: "")
            resultButton.setTitle(copyButtonTitle, for: .normal)
            encryptedText.isHidden = false
            encryptedText.isScrollEnabled = true
            encryptedText.sizeToFit()
        } else {
            UIPasteboard.general.string = encryptedText.text
        }

    }
}
