//
//  ExternalAppStatusViewController.swift
//  IngenicoConnectExample
//
//  Created for Ingenico ePayments on 22/06/2017.
//  Copyright © 2017 Ingenico. All rights reserved.
//

import UIKit
import IngenicoConnectKit
class ExternalAppStatusViewController: UIViewController {
    var startStatus: StatusView?
    var authorizedStatus: StatusView?
    var endStatus: StatusView?
    var externalAppStatus: ThirdPartyStatus = .Waiting {
        didSet {
            switch self.externalAppStatus {
            case .Waiting:
                self.startStatus?.status = .progress
                self.authorizedStatus?.status = .waiting
                self.endStatus?.status = .waiting
            case .Initialized:
                self.startStatus?.status = .finished
                self.authorizedStatus?.status = .progress
                self.endStatus?.status = .waiting
            case .Authorized:
                self.startStatus?.status = .finished
                self.authorizedStatus?.status = .finished
                self.endStatus?.status = .progress
            case .Completed:
                self.authorizedStatus?.status = .finished
                self.endStatus?.status = .finished
            }
        }
    }
    override func loadView() {
        super.loadView()
        let limitView =
            UIView(frame: CGRect(x: self.view.frame.midX - 320/2, y: 0, width: 320, height: self.view.frame.height))
        self.view.addSubview(limitView)
        let inset: CGFloat = 40.0
        let descriptiveLabel = { () -> UIView in
            let label = UILabel(frame: CGRect(x: 20, y: inset, width: 320, height: 40))
            let key = "gc.general.paymentProducts.3012.processing"
            let text =
                NSLocalizedString(
                    key,
                    tableName: SDKConstants.kSDKLocalizable,
                    bundle: AppConstants.sdkBundle,
                    value: "Your payment is being processed",
                    comment: ""
                )
            label.text = text
            label.numberOfLines = 0
            let size = label.sizeThatFits(CGSize(width: 320, height: CGFloat.greatestFiniteMagnitude))
            label.frame.size = size
            return label
        }()
        limitView.addSubview(descriptiveLabel)
        self.startStatus = { () -> StatusView in
            let label = UILabel(frame: CGRect(x: 40, y: 0, width: self.view.frame.width - 40, height: 40))
            let key = "gc.general.paymentProducts.3012.paymentStatus1"
            label.text =
                NSLocalizedString(
                    key,
                    tableName: SDKConstants.kSDKLocalizable,
                    bundle: AppConstants.sdkBundle,
                    value: "Started Processing",
                    comment: ""
                )
            let statusView = StatusView(frame: CGRect(x: 0, y: 0, width: 40, height: 40), status: .waiting)
            let containerView =
                UIView(
                    frame: CGRect(
                        x: 20,
                        y: inset + descriptiveLabel.frame.size.height,
                        width: self.view.frame.width,
                        height: 40
                    )
                )
            containerView.addSubview(statusView)
            containerView.addSubview(label)
            limitView.addSubview(containerView)
            return statusView
        }()
        self.authorizedStatus = { () -> StatusView in
            let label = UILabel(frame: CGRect(x: 40, y: 0, width: self.view.frame.width - 40, height: 40))
            let key = "gc.general.paymentProducts.3012.paymentStatus2"
            label.text =
                NSLocalizedString(
                    key,
                    tableName: SDKConstants.kSDKLocalizable,
                    bundle: AppConstants.sdkBundle,
                    value: "Authenticated Transaction",
                    comment: ""
                )
            let statusView = StatusView(frame: CGRect(x: 0, y: 0, width: 40, height: 40), status: .waiting)
            let containerView = UIView(frame: CGRect(x: 20, y: inset + 80, width: self.view.frame.width, height: 40))
            containerView.addSubview(statusView)
            containerView.addSubview(label)
            limitView.addSubview(containerView)
            return statusView
        }()

        self.endStatus = { () -> StatusView in
            let label = UILabel(frame: CGRect(x: 40, y: 0, width: self.view.frame.width - 40, height: 40))
            let key = "gc.general.paymentProducts.3012.paymentStatus3"
            label.text =
                NSLocalizedString(
                    key,
                    tableName: SDKConstants.kSDKLocalizable,
                    bundle: AppConstants.sdkBundle,
                    value: "Completed Payment",
                    comment: ""
                )
            let statusView = StatusView(frame: CGRect(x: 0, y: 0, width: 40, height: 40), status: .waiting)
            let containerView = UIView(frame: CGRect(x: 20, y: inset + 120, width: self.view.frame.width, height: 40))
            containerView.addSubview(statusView)
            containerView.addSubview(label)
            limitView.addSubview(containerView)
            return statusView
        }()

    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
