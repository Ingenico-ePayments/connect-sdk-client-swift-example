//
//  MerchantLogoImageView.swift
//  IngenicoConnectExample
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2016 Global Collect Services. All rights reserved.
//

import Foundation
import UIKit

class MerchantLogoImageView: UIImageView {
    convenience init() {
        self.init(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        let logo = UIImage(named: "MerchantLogo")
        contentMode = .scaleAspectFit
        image = logo
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
