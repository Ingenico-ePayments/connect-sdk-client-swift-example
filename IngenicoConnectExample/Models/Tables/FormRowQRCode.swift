//
//  FormRowQRCode.swift
//  IngenicoConnectExample
//
//  Created for Ingenico ePayments on 15/06/2017.
//  Copyright © 2017 Ingenico. All rights reserved.
//

import UIKit

class FormRowQRCode: FormRowImage {
    convenience init(qrCodeString: String) {
        let data = qrCodeString.decode()
        //let data = qrCodeString.data(using: String.Encoding.utf8)
        self.init(data: data)
    }
    init(data: Data) {
        let image = UIImage(data: data)
        super.init(image: image!)
    }
}
