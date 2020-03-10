//
//  StatusView.swift
//  IngenicoConnectExample
//
//  Created for Ingenico ePayments on 22/06/2017.
//  Copyright © 2017 Ingenico. All rights reserved.
//

import UIKit
enum StatusViewStatus {
    case Waiting
    case Progress
    case Finished
}
class StatusView: UIView {
    var status: StatusViewStatus = .Waiting {
        didSet {
            switch self.status {
            case .Waiting:
                self.showCheckMark(color: UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1.0))
                break
            case .Progress:
                self.showActivityIndicator()
                break
            case .Finished:
                self.showCheckMark(color: UIColor(red: 0.0, green: 0.5, blue: 0.0, alpha: 1.0))
                break
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
        self.checkMarkView = CheckMarkView(frame: CGRect(x: 10.0, y: 10.0, width: frame.width - 20.0, height: frame.height - 20.0))
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
