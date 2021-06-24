//
//  StartPaymentParsedJsonData.swift
//  IngenicoConnectExample
//
//  Created by Sjors de Haas on 20/04/2021.
//  Copyright © 2021 Ingenico. All rights reserved.
//

import Foundation

struct StartPaymentParsedJsonData : Codable {
    var clientId: String?
    var customerId: String?
    var baseUrl: String?
    var assetUrl: String?

    private enum CodingKeys: String, CodingKey {
        case clientId = "clientSessionId"
        case customerId = "customerId"
        case baseUrl = "clientApiUrl"
        case assetUrl = "assetUrl"
    }
}
