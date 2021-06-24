//
// Created by Sjors de Haas on 20/04/2021.
// Copyright (c) 2021 Ingenico. All rights reserved.
//

import Foundation

protocol ParseJsonTarget {
    func success(sessionData data: StartPaymentParsedJsonData)
}
