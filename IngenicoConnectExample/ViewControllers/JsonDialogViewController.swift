//
//  JsonDialogViewController.swift
//  IngenicoConnectExample
//
//  Created for Ingenico ePayments on 19/04/2021.
//  Copyright © 2021 Ingenico. All rights reserved.
//

import Foundation
import UIKit

class JsonDialogViewController: UIViewController, UITextViewDelegate {

    var containerView: UIView!
    var buttonContainer: UIView!
    var dialogView: UIView!
    var dismissButton: UIButton!
    var parseButton: UIButton!
    var dialogTitle: UILabel!
    var dialogMessage: UITextView!
    var dialogInputText: UITextView!
    var errorLabel: UITextView!

    var placeholderText =
        NSLocalizedString(
            "JsonPlaceholder",
            tableName: AppConstants.kAppLocalizable,
            bundle: AppConstants.appBundle,
            value: "",
            comment: "Placeholder for input"
        )

    var callback: ParseJsonTarget?

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)

        containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = UIColor.white
        containerView.layer.cornerRadius = 10
        view.addSubview(containerView)

        dialogView = UIView()
        dialogView.translatesAutoresizingMaskIntoConstraints = false
        dialogView.layer.cornerRadius = 10
        containerView.addSubview(dialogView)

        buttonContainer = UIView()
        buttonContainer.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(buttonContainer)

        dismissButton = Button(type: .secondary)
        dismissButton.translatesAutoresizingMaskIntoConstraints = false
        dismissButton.setTitle("Dismiss", for: .normal)
        dismissButton.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
        dismissButton.addTarget(self, action: #selector(JsonDialogViewController.dismissPressed), for: .touchUpInside)
        buttonContainer.addSubview(dismissButton)

        parseButton = Button(type: .primary)
        parseButton.translatesAutoresizingMaskIntoConstraints = false
        parseButton.setTitle(
            NSLocalizedString(
                "Parse",
                tableName: AppConstants.kAppLocalizable,
                bundle: AppConstants.appBundle,
                value: "",
                comment: "Parse JSON button"
            ),
            for: .normal
        )
        parseButton.addTarget(self, action: #selector(JsonDialogViewController.parsePressed), for: .touchUpInside)
        buttonContainer.addSubview(parseButton)

        dialogTitle = UILabel()
        dialogTitle.translatesAutoresizingMaskIntoConstraints = false
        dialogTitle.textAlignment = .center
        dialogTitle.text =
            NSLocalizedString(
                "Paste",
                tableName: AppConstants.kAppLocalizable,
                bundle: AppConstants.appBundle,
                value: "",
                comment: "Title for dialog"
            )

        dialogView.addSubview(dialogTitle)

        dialogMessage = UITextView()
        dialogMessage.translatesAutoresizingMaskIntoConstraints = false
        dialogMessage.textAlignment = .left
        dialogMessage.isEditable = false
        dialogMessage.textColor = UIColor.black.withAlphaComponent(0.8)
        dialogMessage.text =
            NSLocalizedString(
                "JsonDialogMessage",
                tableName: AppConstants.kAppLocalizable,
                bundle: AppConstants.appBundle,
                value: "",
                comment: "Message for the dialog"
            )
        dialogView.addSubview(dialogMessage)

        dialogInputText = UITextView()
        dialogInputText.translatesAutoresizingMaskIntoConstraints = false
        dialogInputText.textAlignment = .left
        dialogInputText.textColor = UIColor.lightGray
        dialogInputText.backgroundColor = UIColor.gray.withAlphaComponent(0.1)
        dialogInputText.delegate = self
        dialogInputText.text = placeholderText
        dialogInputText.layer.cornerRadius = 10
        dialogView.addSubview(dialogInputText)

        errorLabel = UITextView()
        errorLabel.textColor = UIColor.red
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        errorLabel.isEditable = false
        errorLabel.textAlignment = .left
        dialogView.addSubview(errorLabel)

        let viewMapping: [String: AnyObject] = [
            "dialogBox": dialogView,
            "buttonContainer": buttonContainer,
            "dismissButton": dismissButton,
            "containerView": containerView,
            "dialogTitle": dialogTitle,
            "parseButton": parseButton,
            "dialogMessage": dialogMessage,
            "dialogInput": dialogInputText,
            "errorLabel": errorLabel
        ]

        // Format buttons with equal gravity
        buttonContainer.addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "|[dismissButton]-(20)-[parseButton(==dismissButton)]|",
                options: [],
                metrics: nil,
                views: viewMapping
            )
        )

        // Horizontal and vertical constraints for the dialogBox
        dialogView.addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "|-[dialogTitle]-|",
                options: [],
                metrics: nil,
                views: viewMapping
            )
        )
        dialogView.addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "|-[dialogMessage]-|",
                options: [],
                metrics: nil,
                views: viewMapping
            )
        )
        dialogView.addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "|-(10)-[dialogInput]-(10)-|",
                options: [],
                metrics: nil,
                views: viewMapping
            )
        )
        dialogView.addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "|-(10)-[errorLabel]-(10)-|",
                options: [],
                metrics: nil,
                views: viewMapping
            )
        )
        dialogView.addConstraints(NSLayoutConstraint.constraints(
                withVisualFormat:
                    "V:|-(20)-[dialogTitle]-(20)-[dialogMessage(40)]-(20)-[dialogInput(150)]-[errorLabel(40)]",
                options: [], metrics: nil, views: viewMapping))

        // Horizontal constraints for the containerView
        containerView.addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "|[dialogBox]|",
                options: [],
                metrics: nil,
                views: viewMapping
            )
        )
        containerView.addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "|-[buttonContainer]-|",
                options: [],
                metrics: nil,
                views: viewMapping
            )
        )

        // DON'T CONSTRAIN CONTAINERVIEW WITH | |
        // AS THIS WILL CONSTRAIN THE VIEW AGAINST THE SUPERVIEW BORDERS. (hence centering fails)
        view.addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "H:[containerView]",
                options: [],
                metrics: nil,
                views: viewMapping
            )
        )
        view.addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "V:[containerView]",
                options: [],
                metrics: nil,
                views: viewMapping
            )
        )

        // Center containerView on the screen
        view.addConstraint(
            NSLayoutConstraint(
                item: containerView!,
                attribute: .centerY,
                relatedBy: .equal,
                toItem: view,
                attribute: .centerY,
                multiplier: 1,
                constant: 0
            )
        )
        view.addConstraint(
            NSLayoutConstraint(
                item: containerView!,
                attribute: .centerX,
                relatedBy: .equal,
                toItem: view,
                attribute: .centerX,
                multiplier: 1,
                constant: 0
            )
        )

        // Vertical constraints in the containerView
        // Constrain the dialogBox to left and top of the containerView
        view.addConstraint(
            NSLayoutConstraint(
                item: dialogView!,
                attribute: .top,
                relatedBy: .equal,
                toItem: containerView,
                attribute: .top,
                multiplier: 1,
                constant: 0
            )
        )
        // Constrain the buttonContainer to the bottom of the containerview
        view.addConstraint(
            NSLayoutConstraint(
                item: buttonContainer!,
                attribute: .bottom,
                relatedBy: .equal,
                toItem: containerView,
                attribute: .bottom,
                multiplier: 1,
                constant: 0
            )
        )

        // Size the containerview, buttonContainer and dialogview
        view.addConstraint(
            NSLayoutConstraint(
                item: containerView!,
                attribute: .height,
                relatedBy: .equal,
                toItem: view,
                attribute: .height,
                multiplier: 0.58,
                constant: 0
            )
        )
        view.addConstraint(
            NSLayoutConstraint(
                item: containerView!,
                attribute: .width,
                relatedBy: .equal,
                toItem: view,
                attribute: .width,
                multiplier: 0.9,
                constant: 0
            )
        )
        view.addConstraint(
            NSLayoutConstraint(
                item: dialogView!,
                attribute: .height,
                relatedBy: .equal,
                toItem: containerView,
                attribute: .height,
                multiplier: 0.9,
                constant: 0
            )
        )
        view.addConstraint(
            NSLayoutConstraint(
                item: buttonContainer!,
                attribute: .height,
                relatedBy: .equal,
                toItem: containerView,
                attribute: .height,
                multiplier: 0.1,
                constant: 0
            )
        )
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black.withAlphaComponent(0.6)
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = placeholderText
            textView.textColor = UIColor.lightGray
        }
    }

    @objc func parsePressed() {
        guard let data = parseJson(dialogInputText.text) else {
            return jsonParsingFailed()
        }

        callback?.success(sessionData: data)
        dialogInputText.text = placeholderText // Reset input field
        errorLabel.text = nil
        dismiss(animated: true)
    }

    @objc func dismissPressed() {
        dialogInputText.text = placeholderText // Reset input field
        errorLabel.text = nil
        dismiss(animated: true)
    }

    private func parseJson(_ jsonString: String) -> StartPaymentParsedJsonData? {
        let data = jsonString.data(using: .utf8)
        do {
            return try JSONDecoder().decode(StartPaymentParsedJsonData.self, from: data!)
        } catch {
            jsonParsingFailed()
            return nil
        }
    }

    private func jsonParsingFailed() {
        errorLabel.text =
            NSLocalizedString(
                "JsonErrorMessage",
                tableName: AppConstants.kAppLocalizable,
                bundle: AppConstants.appBundle,
                value: "",
                comment: "Error notification when parsing fails"
            )
    }
}
