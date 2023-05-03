//
//  CheckMarkView.swift
//  IngenicoConnectExample
//
//  Created for Ingenico ePayments on 22/06/2017.
//  Copyright © 2017 Ingenico. All rights reserved.
//

import UIKit

class CheckMarkView: UIView {

    var currentColor = UIColor.green
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        let bounds = self.bounds
        let startPoint = CGPoint(x: bounds.maxX - bounds.width * 0.2, y: bounds.minY + bounds.height * 0.4)
        let mirrorPoint = CGPoint(x: bounds.midX - 0.1 * bounds.width, y: bounds.maxY - bounds.height * 0.1)
        let endPoint = CGPoint(x: bounds.minX + bounds.width * 0.2, y: bounds.midY + bounds.height * 0.2)

        let path = UIBezierPath()
        path.lineWidth = ((bounds.width + bounds.height)/2)/6
        path.move(to: startPoint)
        path.addLine(to: mirrorPoint)
        path.addLine(to: endPoint)
        self.currentColor.setStroke()
        path.stroke()
    }

}
