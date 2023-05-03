//
//  StatusView.swift
//  IngenicoConnectExample
//
//  Created for Ingenico ePayments on 22/06/2017.
//  Copyright © 2017 Ingenico. All rights reserved.
//

import UIKit
enum StatusViewStatus {
    case waiting
    case progress
    case finished
}
class StatusView: UIView {
    var status: StatusViewStatus = .waiting {
        didSet {
            switch self.status {
            case .waiting:
                self.showCheckMark(color: UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1.0))
            case .progress:
                self.showActivityIndicator()
            case .finished:
                self.showCheckMark(color: UIColor(red: 0.0, green: 0.5, blue: 0.0, alpha: 1.0))
            }
        }

    }
    private func showActivityIndicator() {
        if checkMarkView.isDescendant(of: self) {
            self.checkMarkView.removeFromSuperview()
        }
        self.activityIndicatorView.startAnimating()
        self.addSubview(activityIndicatorView)
    }
    private func showCheckMark(color: UIColor) {
        if activityIndicatorView.isDescendant(of: self) {
            self.activityIndicatorView.stopAnimating()
            self.activityIndicatorView.removeFromSuperview()
        }
        self.checkMarkView.currentColor = color
        self.addSubview(checkMarkView)
    }
    let checkMarkView: CheckMarkView
    let activityIndicatorView: UIActivityIndicatorView
    init(frame: CGRect, status: StatusViewStatus) {
        self.status = status
        self.checkMarkView =
            CheckMarkView(
                frame: CGRect(x: 10.0, y: 10.0, width: frame.width - 20.0, height: frame.height - 20.0)
            )
        self.activityIndicatorView = UIActivityIndicatorView(frame: frame)
        self.activityIndicatorView.style = .gray
        super.init(frame: frame)
        self.checkMarkView.backgroundColor = self.backgroundColor
        self.checkMarkView.isOpaque = false
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
