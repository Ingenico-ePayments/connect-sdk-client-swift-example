//
//  AppConstants.swift
//  IngenicoConnectExample
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2016 Global Collect Services. All rights reserved.
//

import Foundation
import UIKit
import IngenicoConnectKit

class AppConstants {
    static let sdkBundle = Bundle(path: SDKConstants.kSDKBundlePath!)!
    static var appBundle = Bundle.main
    static let kAppLocalizable = "AppLocalizable"
    static var kPrimaryColor = UIColor(red: 0, green: 0.8, blue: 0, alpha: 1)
    static var kDestructiveColor = UIColor(red: 0.8, green: 0, blue: 0, alpha: 1)
    static let kClientSessionId = "kClientSessionId"
    static let kCustomerId = "kCustomerId"
    static let kMerchantId = "kMerchantId"
    static let kApplicationIdentifier = "Swift Example Application/v2.6.0"
    static let kBaseURL = "kBaseURL"
    static let kAssetsBaseURL = "kAssetsBaseURL"
    static let kPrice = "kPrice"
    static let kCurrency = "kCurrency"
    static let kCountryCode = "kCountryCode"
    static let kBoletoBancarioId = "1503"
    static let kBancontactId = "3012"
}
