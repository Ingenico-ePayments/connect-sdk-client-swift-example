//
//  SummaryTableHeaderView.swift
//  IngenicoConnectExample
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2016 Global Collect Services. All rights reserved.
//

import Foundation
import UIKit

class SummaryTableHeaderView: UIView {
    var summaryLabel: UILabel!
    var amountLabel: UILabel!
    var securePaymentLabel: UILabel!

    convenience init() {
        self.init(frame: CGRect.zero)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        let securePaymentContainer = UIView()
        securePaymentContainer.translatesAutoresizingMaskIntoConstraints = false
        let securePaymentIcon =
            UIImageView(frame: CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(10), height: CGFloat(10)))
        securePaymentIcon.contentMode = .scaleAspectFit
        securePaymentIcon.image = UIImage(named: "SecurePaymentIcon")
        securePaymentIcon.translatesAutoresizingMaskIntoConstraints = false
        securePaymentLabel = UILabel()
        securePaymentLabel.textColor =
            UIColor(red: CGFloat(0), green: CGFloat(0.8), blue: CGFloat(0), alpha: CGFloat(1))
        securePaymentLabel.backgroundColor = UIColor.clear
        securePaymentLabel.font = UIFont.systemFont(ofSize: CGFloat(12))
        securePaymentLabel.translatesAutoresizingMaskIntoConstraints = false
        securePaymentContainer.addSubview(securePaymentIcon)
        securePaymentContainer.addSubview(securePaymentLabel)

        let banner = UIView()
        banner.layer.cornerRadius = 5.0
        banner.backgroundColor =
            UIColor(red: CGFloat(0.95), green: CGFloat(0.95), blue: CGFloat(0.95), alpha: CGFloat(1))
        banner.translatesAutoresizingMaskIntoConstraints = false
        addSubview(banner)
        addSubview(securePaymentContainer)

        summaryLabel = UILabel()
        summaryLabel.translatesAutoresizingMaskIntoConstraints = false
        summaryLabel.font = UIFont.boldSystemFont(ofSize: CGFloat(16))
        summaryLabel.backgroundColor = UIColor.clear
        amountLabel = UILabel()
        amountLabel.translatesAutoresizingMaskIntoConstraints = false
        amountLabel.font = UIFont.boldSystemFont(ofSize: CGFloat(16))
        amountLabel.backgroundColor = UIColor.clear
        banner.addSubview(summaryLabel)
        banner.addSubview(amountLabel)

        let viewMapping: [String: Any] = [
            "summaryLabel": summaryLabel,
            "amountLabel": amountLabel,
            "securePaymentContainer": securePaymentContainer,
            "securePaymentIcon": securePaymentIcon,
            "securePaymentLabel": securePaymentLabel,
            "banner": banner
        ]
        let metrics = ["bannerInnerMargin": "8"]
        addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "|-(10)-[banner]-(10)-|",
                options: NSLayoutConstraint.FormatOptions(),
                metrics: nil,
                views: viewMapping
            )
        )
        addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "[securePaymentContainer]-(10)-|",
                options: NSLayoutConstraint.FormatOptions(),
                metrics: nil,
                views: viewMapping
            )
        )
        addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "V:|-[banner]-(1)-[securePaymentContainer]",
                options: NSLayoutConstraint.FormatOptions(),
                metrics: nil,
                views: viewMapping
            )
        )
        banner.addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "|-(bannerInnerMargin)-[summaryLabel]",
                options: NSLayoutConstraint.FormatOptions(),
                metrics: metrics,
                views: viewMapping
            )
        )
        banner.addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "[amountLabel]-(bannerInnerMargin)-|",
                options: NSLayoutConstraint.FormatOptions(),
                metrics: metrics,
                views: viewMapping
            )
        )
        banner.addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "V:|-(bannerInnerMargin)-[summaryLabel]-(bannerInnerMargin)-|",
                options: NSLayoutConstraint.FormatOptions(),
                metrics: metrics,
                views: viewMapping
            )
        )
        banner.addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "V:|-(bannerInnerMargin)-[amountLabel]-(bannerInnerMargin)-|",
                options: NSLayoutConstraint.FormatOptions(),
                metrics: metrics,
                views: viewMapping
            )
        )
        securePaymentContainer.addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "[securePaymentIcon(==7)]-(3)-[securePaymentLabel]|",
                options: NSLayoutConstraint.FormatOptions(),
                metrics: nil,
                views: viewMapping
            )
        )
        securePaymentContainer.addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "V:|[securePaymentLabel(==20)]",
                options: NSLayoutConstraint.FormatOptions(),
                metrics: nil,
                views: viewMapping
            )
        )
        securePaymentContainer.addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "V:|-(5)-[securePaymentIcon(==7)]",
                options: NSLayoutConstraint.FormatOptions(),
                metrics: nil,
                views: viewMapping
            )
        )
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func setSummary(summary: String) {
        summaryLabel.text = summary
    }

    func setAmount(amount: String) {
        amountLabel.text = amount
    }

    func setSecurePayment(securePayment: String) {
        securePaymentLabel.text = securePayment
    }
}
