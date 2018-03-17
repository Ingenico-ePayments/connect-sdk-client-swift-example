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

public class AppConstants {
    static let sdkBundle = Bundle(path: SDKConstants.kSDKBundlePath!)!
    public static var appBundle = Bundle.main
    static let kAppLocalizable = "AppLocalizable"
    public static var kPrimaryColor = UIColor(red: 0, green: 0.8, blue: 0, alpha: 1)
    public static var kDestructiveColor = UIColor(red: 0.8, green: 0, blue: 0, alpha: 1)
    static let kClientSessionId = "kClientSessionId"
    static let kCustomerId = "kCustomerId"
    static let kMerchantId = "kMerchantId"
    static let kApplicationIdentifier = "Swift Example Application/v2.0.0"
    static let kPrice = "kPrice"
    static let kCurrency = "kCurrency"
    static let kCountryCode = "kCountryCode"
    static let kBoletoBancarioId = "1503"
    static let kBancontactId = "3012"
    static let kArvatoIds = ["9000", "9001"]
}
