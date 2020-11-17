//
//  ValidationErrorExtension.swift
//  IngenicoConnectExample
//
//  Created for Ingenico ePayments on 7/10/2020
//  Copyright © 2020 Global Collect Services. All rights reserved.
//


import Foundation
import IngenicoConnectKit

extension ValidationError {
    @objc func errorMessageKey() -> String? {
        return nil
    }
}

extension ValidationErrorAllowed {
    @objc override func errorMessageKey() -> String? {
        return "allowedInContext"
    }
}

extension ValidationErrorEmailAddress {
    override func errorMessageKey() -> String? {
        return "emailAddress"
    }
}

extension ValidationErrorExpirationDate {
    override func errorMessageKey() -> String? {
        return "expirationDate"
    }
}

extension ValidationErrorFixedList {
    override func errorMessageKey() -> String? {
        return "fixedList"
    }
}

extension ValidationErrorIsRequired {
    override func errorMessageKey() -> String? {
        return "required"
    }
}

extension ValidationErrorLuhn {
    override func errorMessageKey() -> String? {
        return "luhn"
    }
}

extension ValidationErrorRegularExpression {
    override func errorMessageKey() -> String? {
        return "regularExpression"
    }
}

extension ValidationErrorTermsAndConditions {
    override func errorMessageKey() -> String? {
        return "termsAndConditions"
    }
}

extension ValidationErrorIBAN {
    override func errorMessageKey() -> String? {
        return "regularExpression"
    }
}

extension ValidationErrorResidentId {
    override func errorMessageKey() -> String? {
        return "residentIdNumber"
    }
}

