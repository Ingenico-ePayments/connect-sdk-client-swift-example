//
//  PaymentProductsViewControllerTarget.swift
//  IngenicoConnectExample
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2016 Global Collect Services. All rights reserved.
//

import Foundation
import PassKit
import IngenicoConnectKit
import SVProgressHUD

class PaymentProductsViewControllerTarget: NSObject, PKPaymentAuthorizationViewControllerDelegate,
                                           PaymentProductSelectionTarget, PaymentRequestTarget {

    var session: Session!
    var context: PaymentContext!
    var navigationController: UINavigationController!

    var applePayPaymentProduct: PaymentProduct?
    var summaryItems: [PKPaymentSummaryItem] = []
    var authorizationViewController: PKPaymentAuthorizationViewController?

    var paymentFinishedTarget: PaymentFinishedTarget?

    init(
        navigationController: UINavigationController,
        session: Session!,
        context: PaymentContext!
    ) {
        self.navigationController = navigationController
        self.session = session
        self.context = context
    }

    convenience override init() {
        NSException(
            name: NSExceptionName.internalInconsistencyException,
            reason: "-init is not a valid initializer for the class PaymentProductsViewControllerTarget",
            userInfo: nil
        ).raise()
        self.init()
    }

    // swiftlint:disable line_length
    func getBancontactJSON(success: (_ json: [String: Any]) -> Void) {
        // *******************************************************************************
        //
        // To be able to show the Bancontact QR-Code and/or "open Bancontact app"-button,
        // a payment has to be created first. Create this payment with the S2S API from
        // your payment server.
        //
        // The PaymentResponse will contain QR-Code and button render information, which
        // you should send back to the app.
        //
        // As this is merely an example app, we create a payment response JSON here that
        // is similar to the payment response that you can expect to receive after having
        // created the payment via the server API.
        //
        // *******************************************************************************
        let json = [
            "creationOutput": [
            ],
            "merchantAction": [
                "actionType": "SHOW_FORM",
                "formFields": [ [
                    "dataRestrictions": [
                        "isRequired": true,
                        "validators": [
                            "length": [
                                "maxLength": 19,
                                "minLength": 16
                            ],
                            "luhn": [
                            ],
                            "regularExpression": [
                                "regularExpression": "^[0-9]*$"
                            ]
                        ]
                    ],
                    "displayHints": [
                        "alwaysShow": false,
                        "displayOrder": 0,
                        "formElement": [
                            "type": "text"
                        ],
                        "label": "Card number",
                        "mask": "{{9999}} {{9999}} {{9999}} {{9999}} {{999}}",
                        "obfuscate": false,
                        "placeholderLabel": "**** **** **** ****",
                        "preferredInputType": "IntegerKeyboard"
                    ],
                    "id": "cardNumber",
                    "type": "numericstring"
                    ], [
                        "dataRestrictions": [
                            "isRequired": true,
                            "validators": [
                                "length": [
                                    "maxLength": 35,
                                    "minLength": 0
                                ],
                                "regularExpression": [
                                    "regularExpression": "^[a-zA-ZàáâãäåæçèéêëìíîïðñòóôõöøùúûüýþÿÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖØÙÚÛÜÝÞßŠšŽžŸÿęĘ0-9 +_.=,:\\-\\[\\]\\/\\(\\)]*$"
                                ]
                            ]
                        ],
                        "displayHints": [
                            "alwaysShow": false,
                            "displayOrder": 1,
                            "formElement": [
                                "type": "text"
                            ],
                            "label": "Cardholder name",
                            "obfuscate": false,
                            "placeholderLabel": "John Doe",
                            "preferredInputType": "StringKeyboard"
                        ],
                        "id": "cardholderName",
                        "type": "string"
                    ], [
                        "dataRestrictions": [
                            "isRequired": true,
                            "validators": [
                                "expirationDate": [
                                ],
                                "regularExpression": [
                                    "regularExpression": "^(0[1-9]|1[0-2])\\d\\d$"
                                ]
                            ]
                        ],
                        "displayHints": [
                            "alwaysShow": false,
                            "displayOrder": 2,
                            "formElement": [
                                "type": "text"
                            ],
                            "label": "Expiry date",
                            "mask": "{{99}}/{{99}}",
                            "obfuscate": false,
                            "placeholderLabel": "MM/YY",
                            "preferredInputType": "IntegerKeyboard"
                        ],
                        "id": "expiryDate",
                        "type": "expirydate"
                    ] ],
                "redirectData": [
                    "RETURNMAC": "d9f0385f-10cf-4d59-adea-d7e20d5e7473"
                ],
                "renderingData": "eyJjcmVhdGVkUGF5bWVudE91dHB1dCI6eyJwYXltZW50Ijp7ImlkIjoiMjczNzg2MF8wIiwic3RhdHVzIjoiUEVORElOR19QQVlNRU5UIn0sIm1lcmNoYW50QWN0aW9uIjp7ImFjdGlvblR5cGUiOiJTSE9XX0ZPUk0iLCJmb3JtRmllbGRzIjpbeyJkYXRhUmVzdHJpY3Rpb25zIjp7ImlzUmVxdWlyZWQiOnRydWUsInZhbGlkYXRvcnMiOnsibGVuZ3RoIjp7Im1heExlbmd0aCI6MTksIm1pbkxlbmd0aCI6MTZ9LCJsdWhuIjp7fSwicmVndWxhckV4cHJlc3Npb24iOnsicmVndWxhckV4cHJlc3Npb24iOiJeWzAtOV0qJCJ9fX0sImRpc3BsYXlIaW50cyI6eyJhbHdheXNTaG93IjpmYWxzZSwiZGlzcGxheU9yZGVyIjowLCJmb3JtRWxlbWVudCI6eyJ0eXBlIjoidGV4dCJ9LCJsYWJlbCI6IkNhcmQgbnVtYmVyIiwibWFzayI6Int7OTk5OX19IHt7OTk5OX19IHt7OTk5OX19IHt7OTk5OX19IHt7OTk5fX0iLCJvYmZ1c2NhdGUiOmZhbHNlLCJwbGFjZWhvbGRlckxhYmVsIjoiKioqKiAqKioqICoqKiogKioqKiIsInByZWZlcnJlZElucHV0VHlwZSI6IkludGVnZXJLZXlib2FyZCJ9LCJpZCI6ImNhcmROdW1iZXIiLCJ0eXBlIjoibnVtZXJpY3N0cmluZyJ9LHsiZGF0YVJlc3RyaWN0aW9ucyI6eyJpc1JlcXVpcmVkIjp0cnVlLCJ2YWxpZGF0b3JzIjp7Imxlbmd0aCI6eyJtYXhMZW5ndGgiOjM1LCJtaW5MZW5ndGgiOjB9LCJyZWd1bGFyRXhwcmVzc2lvbiI6eyJyZWd1bGFyRXhwcmVzc2lvbiI6Il5bYS16QS1aw6DDocOiw6PDpMOlw6bDp8Oow6nDqsOrw6zDrcOuw6/DsMOxw7LDs8O0w7XDtsO4w7nDusO7w7zDvcO+w7/DgMOBw4LDg8OEw4XDhsOHw4jDicOKw4vDjMONw47Dj8OQw5HDksOTw5TDlcOWw5jDmcOaw5vDnMOdw57Dn8WgxaHFvcW+xbjDv8SZxJgwLTkgK18uPSw6XFwtXFxbXFxdXFwvXFwoXFwpXSokIn19fSwiZGlzcGxheUhpbnRzIjp7ImFsd2F5c1Nob3ciOmZhbHNlLCJkaXNwbGF5T3JkZXIiOjEsImZvcm1FbGVtZW50Ijp7InR5cGUiOiJ0ZXh0In0sImxhYmVsIjoiQ2FyZGhvbGRlciBuYW1lIiwib2JmdXNjYXRlIjpmYWxzZSwicGxhY2Vob2xkZXJMYWJlbCI6IkpvaG4gRG9lIiwicHJlZmVycmVkSW5wdXRUeXBlIjoiU3RyaW5nS2V5Ym9hcmQifSwiaWQiOiJjYXJkaG9sZGVyTmFtZSIsInR5cGUiOiJzdHJpbmcifSx7ImRhdGFSZXN0cmljdGlvbnMiOnsiaXNSZXF1aXJlZCI6dHJ1ZSwidmFsaWRhdG9ycyI6eyJleHBpcmF0aW9uRGF0ZSI6e30sInJlZ3VsYXJFeHByZXNzaW9uIjp7InJlZ3VsYXJFeHByZXNzaW9uIjoiXigwWzEtOV18MVswLTJdKVxcZFxcZCQifX19LCJkaXNwbGF5SGludHMiOnsiYWx3YXlzU2hvdyI6ZmFsc2UsImRpc3BsYXlPcmRlciI6MiwiZm9ybUVsZW1lbnQiOnsidHlwZSI6InRleHQifSwibGFiZWwiOiJFeHBpcnkgZGF0ZSIsIm1hc2siOiJ7ezk5fX0ve3s5OX19Iiwib2JmdXNjYXRlIjpmYWxzZSwicGxhY2Vob2xkZXJMYWJlbCI6Ik1NL1lZIiwicHJlZmVycmVkSW5wdXRUeXBlIjoiSW50ZWdlcktleWJvYXJkIn0sImlkIjoiZXhwaXJ5RGF0ZSIsInR5cGUiOiJleHBpcnlkYXRlIn1dLCJyZWRpcmVjdERhdGEiOnsiUkVUVVJOTUFDIjoiZDlmMDM4NWYtMTBjZi00ZDU5LWFkZWEtZDdlMjBkNWU3NDczIn0sInNob3dEYXRhIjpbeyJrZXkiOiJVUkxJTlRFTlQiLCJ2YWx1ZSI6IkJFUEdlbkFwcDovL0RvVHg/VHJhbnNJZD0xZXhhbXBsZS5jb20qUC0yNzM3ODYwJDdPTElGQ0JVUzVUVEhCQTdGTTdZU043QyZDYWxsYmFjaz1odHRwJTNBJTJGJTJGcnBwLmdjLWNpLWRldi5pc2FhYy5sb2NhbCUzQTcwMDMlMkZyZWRpcmVjdG9yJTJGcmV0dXJuJTJGYTBmNDVhZmQtZGQxNi00Yjk5LTkwNzUtYjdjNzZiMjUxMTcxIn0seyJrZXkiOiJRUkNPREUiLCJ2YWx1ZSI6ImlWQk9SdzBLR2dvQUFBQU5TVWhFVWdBQUFNZ0FBQURJQVFBQUFBQ0ZJNU16QUFBQndFbEVRVlI0MnUyWU1hNkRNQkJFQjdtZzVBamNCQzZHaENVdUZtN2lJMUJTSVBiUExDSEpqNVIyK2ZvS1JSVDhVbGk3cytOeFlKOGVmTWxmSnhsQVk4VnV6UWE3SVJXK3AxQXltZTFOaHUxY1hQc2xGZk8xU0ZMUU5jSVlXblFZeTRybUFySzEzTmFBQzBuR1dyRlR4RmNROVdjNldvUGU3SzF6QWNRMVN0S2RINy9WRzBEOG1VcTlxMG5Wa3Q0bU9JRGt0dDR4bXN2RVptOFhYeU1KdjFLZUhKRG12a3ROYkRTQjlnWnZqYXQxaVNVdXlnMm9PQ0R5VGRPb0JCTlhadTJ6TWZNM1QrMkVrZHBZamxwdVNhRk90bmJubEFRUkZvYmlLUFdzdlpsSzFOLzNGa1hvRDVYbTlLWTVsVWx3cTJNc01aN1dvN0JaUGRNeUg5VUpKUE1DK0R2bENiZUxVTEpwRVMzOHpJSUN6UDVRU0F6SjJveWYyMUI2b21lY2N4cEZ0dGI5UVNWcXVaalVwRmhpRW1XaVJsa2l4a2ozNjFpU1FYOWdpZFNwMDdDbVVPS3RHVldkcEVYYTk3TnVNVVFtZ1lIUlRZVmlpVHpLaEJKL3NzUXg0UERyL2pYVkJKQWp2NWt5TE9zazg4UkRJVEhFTXl4UGE1VkZHcFZocFZoU2pqTkxpenk0c2pMRUJlUkliU3JNZ05mOEZrYzBHK1ozV3VoU0YwejhMaU9QSEhCY0l1WXpPUVFSMTJqMkZLMnJIR1A5bVJ5aXlQZGZuSDlHZmdDZGJCRGpxS0lUOHdBQUFBQkpSVTVFcmtKZ2dnPT0ifV19fSwicGFydGlhbFBheW1lbnRJbnB1dCI6eyJhbW91bnQiOjI5ODAsImNvdW50cnlDb2RlIjoiVVMiLCJjdXJyZW5jeUNvZGUiOiJFVVIiLCJpc1JlY3VycmluZyI6ZmFsc2UsIm1lcmNoYW50SWQiOiI5OTkxOTk5OSIsInBheW1lbnRQcm9kdWN0SWQiOjMwMTJ9LCJycHBTcGVjaWZpY0lucHV0Ijp7ImNhcnQiOnsiY3VycmVuY3lTeW1ib2wiOiLigqwiLCJsaW5lSXRlbXMiOlt7ImRlc2NyaXB0aW9uIjoiQUNNRSBTdXBlciBPdXRmaXQiLCJuck9mSXRlbXMiOiIxIiwicHJpY2VQZXJJdGVtIjoyNTAwLCJ0b3RhbFByaWNlIjoyNTAwfSx7ImRlc2NyaXB0aW9uIjoiQXNwZXJpbiIsIm5yT2ZJdGVtcyI6IjEyIiwicHJpY2VQZXJJdGVtIjo0MCwidG90YWxQcmljZSI6NDgwfV0sInRvdGFsUHJpY2UiOjI5ODB9fX0=",
                "showData": [ [
                    "key": "URLINTENT",
                    "value": "BEPGenApp://DoTx?TransId=1example.com*P-2737860$7OLIFCBUS5TTHBA7FM7YSN7C&Callback=http%3A%2F%2Frpp.gc-ci-dev.isaac.local%3A7003%2Fredirector%2Freturn%2Fa0f45afd-dd16-4b99-9075-b7c76b251171"
                    ], [
                        "key": "QRCODE",
                        "value": "iVBORw0KGgoAAAANSUhEUgAAAMgAAADIAQAAAACFI5MzAAABwElEQVR42u2YMa6DMBBEB7mg5AjcBC6GhCUuFm7iI1BSIPbPLCHJj5R2+foKRRT8Uli7s+NxYJ8efMlfJxlAY8VuzQa7IRW+p1Ayme1Nhu1cXPslFfO1SFLQNcIYWnQYy4rmArK13NaAC0nGWrFTxFcQ9Wc6WoPe7K1zAcQ1StKdH7/VG0D8mUq9q0nVkt4mOIDktt4xmsvEZm8XXyMJv1KeHJDmvktNbDSB9gZvjat1iSUuyg2oOCDyTdOoBBNXZu2zMfM3T+2EkdpYjlpuSaFOtnbnlAQRFobiKPWsvZlK1N/3FkXoD5Xm9KY5lUlwq2MsMZ7Wo7BZPdMyH9UJJPMC+DvlCbeLULJpES38zIICzP5QSAzJ2oyf21B6omeccxpFttb9QSVquZjUpFhiEmWiRlkixkj361iSQX9gidSp07CmUOKtGVWdpEXa97NuMUQmgYHRTYViiTzKhBJ/ssQx4PDr/jXVBJAjv5kyLOsk88RDITHEMyxPa5VFGpVhpVhSjjNLizy4sjLEBeRIbSrMgNf8Fkc0G+Z3WuhSF0z8LiOPHHBcIuYzOQQR12j2FK2rHGP9mRyiyPdfnH9GfgCdbBDjqKIT8wAAAABJRU5ErkJggg=="
                    ] ]
            ],
            "payment": [
                "id": "2737860_0",
                "paymentOutput": [
                    "amountOfMoney": [
                        "amount": 2980,
                        "currencyCode": "EUR"
                    ],
                    "references": [
                        "merchantReference": "AcmeOrder0001"
                    ],
                    "paymentMethod": "card",
                    "cardPaymentMethodSpecificOutput": [
                        "paymentProductId": 3012,
                        "card": [
                        ]
                    ]
                ],
                "status": "PENDING_PAYMENT",
                "statusOutput": [
                    "isCancellable": false,
                    "statusCategory": "PENDING_PAYMENT",
                    "statusCode": 0,
                    "isAuthorized": false,
                    "isRefundable": false
                ]
            ]
        ] as [String: Any]
        success(json)
    }
    // swiftlint:enable line_length

    // MARK: PaymentProduct selection target

    func didSelect(paymentItem: BasicPaymentItem, accountOnFile: AccountOnFile?) {

        SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.clear)
        let status =
            NSLocalizedString(
                "gc.app.general.loading.body",
                tableName: SDKConstants.kSDKLocalizable,
                bundle: AppConstants.sdkBundle,
                value: "",
                comment: ""
            )
        SVProgressHUD.show(withStatus: status)

        // ***************************************************************************
        //
        // After selecting a payment product or an account on file associated to a
        // payment product in the payment product selection screen, the Session
        // object is used to retrieve all information for this payment product.
        //
        // Afterwards, a screen is shown that allows the user to fill in all
        // relevant information, unless the payment product has no fields.
        // This screen is also not part of the SDK and is offered for demonstration
        // purposes only.
        //
        // If the payment product has no fields, the merchant is responsible for
        // fetching the URL for a redirect to a third party and show the corresponding
        // website.
        //
        // ***************************************************************************

        if paymentItem is BasicPaymentProduct {
            session.paymentProduct(
                withId: paymentItem.identifier,
                context: context,
                success: {(_ paymentProduct: PaymentProduct) -> Void in
                    if paymentItem.identifier.isEqual(SDKConstants.kApplePayIdentifier) {
                        self.showApplePayPaymentItem(paymentProduct: paymentProduct)
                    } else {
                        SVProgressHUD.dismiss()

                        if paymentProduct.identifier == AppConstants.kBancontactId {
                            self.getBancontactJSON(success: { (json: [String: Any]) in
                                let viewController =
                                    BancontactProductViewController(
                                        paymentItem: paymentProduct,
                                        session: self.session,
                                        context: self.context,
                                        accountOnFile: accountOnFile,
                                        customServerJSON: json
                                    )
                                viewController.paymentRequestTarget = self
                                self.navigationController.pushViewController(viewController, animated: true)
                                return
                            })
                        } else if paymentProduct.fields.paymentProductFields.count > 0 {
                            self.show(paymentItem: paymentProduct, accountOnFile: accountOnFile)
                        } else {
                            let request =
                                PaymentRequest(
                                    paymentProduct: paymentProduct,
                                    accountOnFile: accountOnFile,
                                    tokenize: false
                                )
                            self.didSubmitPaymentRequest(paymentRequest: request)
                        }
                    }
                },
                failure: { _ in
                    SVProgressHUD.dismiss()
                    let alert =
                        UIAlertController(
                            title: NSLocalizedString(
                                "ConnectionErrorTitle",
                                tableName: AppConstants.kAppLocalizable,
                                bundle: AppConstants.appBundle,
                                value: "",
                                comment: "Title of the connection error dialog."
                            ),
                            message: NSLocalizedString(
                                "PaymentProductErrorExplanation",
                                tableName: AppConstants.kAppLocalizable,
                                bundle: AppConstants.appBundle,
                                value: "",
                                comment: ""
                            ),
                            preferredStyle: .alert
                        )
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.navigationController.topViewController?.present(alert, animated: true, completion: nil)
                }
            )
        } else if paymentItem is BasicPaymentProductGroup {
            self.session.paymentProductGroup(
                withId: paymentItem.identifier,
                context: self.context,
                success: {(_ paymentProductGroup: PaymentProductGroup) -> Void in
                    SVProgressHUD.dismiss()
                    self.show(paymentItem: paymentProductGroup, accountOnFile: accountOnFile)
                },
                failure: { _ in
                    SVProgressHUD.dismiss()

                    let alert =
                        UIAlertController(
                            title: NSLocalizedString(
                                "ConnectionErrorTitle",
                                tableName: AppConstants.kAppLocalizable,
                                bundle: AppConstants.appBundle,
                                value: "",
                                comment: "Title of the connection error dialog."
                            ),
                            message: NSLocalizedString(
                                "PaymentProductErrorExplanation",
                                tableName: AppConstants.kAppLocalizable,
                                bundle: AppConstants.appBundle,
                                value: "",
                                comment: ""
                            ),
                            preferredStyle: .alert
                        )
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.navigationController.topViewController?.present(alert, animated: true, completion: nil)
                }
            )
        }
    }

    func show(paymentItem: PaymentItem, accountOnFile: AccountOnFile?) {
        var paymentProductForm: PaymentProductViewController! = nil
        if (paymentItem is PaymentProductGroup && paymentItem.identifier == "cards") ||
                  (paymentItem as? PaymentProduct)?.paymentMethod == "card" {
            paymentProductForm =
                CardProductViewController(
                    paymentItem: paymentItem,
                    session: session,
                    context: context,
                    accountOnFile: accountOnFile
                )
        } else if paymentItem.identifier == AppConstants.kBoletoBancarioId {
            paymentProductForm =
                BoletoProductViewController(
                    paymentItem: paymentItem,
                    session: session,
                    context: context,
                    accountOnFile: accountOnFile
                )
        } else {
            paymentProductForm =
                PaymentProductViewController(
                    paymentItem: paymentItem,
                    session: session,
                    context: context,
                    accountOnFile: accountOnFile
                )
        }
        paymentProductForm.paymentRequestTarget = self
        navigationController.pushViewController(paymentProductForm, animated: true)
    }

    // MARK: ApplePay selection handling

    func showApplePayPaymentItem(paymentProduct: PaymentProduct) {
        if SDKConstants.SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v: "8.0") &&
           PKPaymentAuthorizationViewController.canMakePayments() {
            SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.clear)
            let status =
                NSLocalizedString(
                    "gc.app.general.loading.body",
                    tableName: SDKConstants.kSDKLocalizable,
                    bundle: AppConstants.sdkBundle,
                    value: "",
                    comment: ""
                )
            SVProgressHUD.show(withStatus: status)

            // ***************************************************************************
            //
            // If the payment product is Apple Pay, the supported networks are retrieved.
            //
            // A view controller for Apple Pay will be shown when these networks have been
            // retrieved.
            //
            // ***************************************************************************

            session.paymentProductNetworks(
                forProductId: SDKConstants.kApplePayIdentifier,
                context: context,
                success: {(_ paymentProductNetworks: PaymentProductNetworks) -> Void in
                    self.showApplePaySheet(for: paymentProduct, withAvailableNetworks: paymentProductNetworks)
                    SVProgressHUD.dismiss()
                },
                failure: { _ in
                    SVProgressHUD.dismiss()

                    let alert =
                        UIAlertController(
                            title: NSLocalizedString(
                                "ConnectionErrorTitle",
                                tableName: AppConstants.kAppLocalizable,
                                bundle: AppConstants.appBundle,
                                value: "",
                                comment: "Title of the connection error dialog."
                            ),
                            message: NSLocalizedString(
                                "PaymentProductNetworksErrorExplanation",
                                tableName: AppConstants.kAppLocalizable,
                                bundle: AppConstants.appBundle,
                                value: "",
                                comment: ""
                            ),
                            preferredStyle: .alert
                        )
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.navigationController.topViewController?.present(alert, animated: true, completion: nil)
                }
            )
        }
    }

    func showApplePaySheet(
        for paymentProduct: PaymentProduct,
        withAvailableNetworks paymentProductNetworks: PaymentProductNetworks
    ) {

        if UserDefaults.standard.object(forKey: AppConstants.kMerchantId) == nil {
            return
        }

        // This merchant should be the merchant id specified in the merchants developer portal.
        guard let merchantId = UserDefaults.standard.value(forKey: AppConstants.kMerchantId) as? String else {
            fatalError("MerchantId could not be retrieved as a String")
            return
        }

        generateSummaryItems()
        let paymentRequest = PKPaymentRequest()

        if let acquirerCountry = paymentProduct.acquirerCountry,
           !acquirerCountry.isEmpty {
            paymentRequest.countryCode = acquirerCountry
        } else {
            paymentRequest.countryCode = context.countryCodeString
        }

        paymentRequest.currencyCode = context.amountOfMoney.currencyCodeString
        paymentRequest.supportedNetworks = paymentProductNetworks.paymentProductNetworks
        paymentRequest.paymentSummaryItems = summaryItems
        paymentRequest.merchantCapabilities = [.capability3DS, .capabilityDebit, .capabilityCredit]

        // This merchant id is set in the merchants apple developer portal and is linked to a certificate
        paymentRequest.merchantIdentifier = merchantId

        // These shipping and billing address fields are optional and can be chosen by the merchant
        paymentRequest.requiredShippingAddressFields = .all
        paymentRequest.requiredBillingAddressFields = .all
        authorizationViewController = PKPaymentAuthorizationViewController(paymentRequest: paymentRequest)
        authorizationViewController?.delegate = self

        // The authorizationViewController will be nil if the paymentRequest was incomplete or not created correctly
        if let authorizationViewController = authorizationViewController,
            PKPaymentAuthorizationViewController.canMakePayments(
                usingNetworks: paymentProductNetworks.paymentProductNetworks
            ) {
                applePayPaymentProduct = paymentProduct
                navigationController!.topViewController!.present(
                    authorizationViewController,
                    animated: true,
                    completion: { return }
                )
        }
    }

    func generateSummaryItems() {

        // ***************************************************************************
        //
        // The summaryItems for the paymentRequest is a list of values with the last
        // value being the total and having the name of the merchant as label.
        //
        // A list of subtotal, shipping cost, and total is created below as example.
        // The values are specified in cents and converted to a NSDecimalNumber with
        // a exponent of -2.
        //
        // ***************************************************************************

        let subtotal = context.amountOfMoney.totalAmount
        let shippingCost = 200
        let total = subtotal + shippingCost

        var summaryItems = [PKPaymentSummaryItem]()
        summaryItems.append(
            PKPaymentSummaryItem(
                label: NSLocalizedString(
                    "gc.app.general.shoppingCart.subtotal",
                    tableName: SDKConstants.kSDKLocalizable,
                    bundle: AppConstants.sdkBundle,
                    value: "",
                    comment: "subtotal summary item title"
                ),
                amount: NSDecimalNumber(mantissa: UInt64(subtotal), exponent: -2, isNegative: false)
            )
        )
        summaryItems.append(
            PKPaymentSummaryItem(
                label: NSLocalizedString(
                    "gc.app.general.shoppingCart.shippingCost",
                    tableName: SDKConstants.kSDKLocalizable,
                    bundle: AppConstants.sdkBundle,
                    value: "",
                    comment: "shipping cost summary item title"
                ),
                amount: NSDecimalNumber(mantissa: UInt64(shippingCost), exponent: -2, isNegative: false)
            )
        )
        if #available(iOS 9.0, *) {
            summaryItems.append(
                PKPaymentSummaryItem(
                    label: "Merchant Name",
                    amount: NSDecimalNumber(mantissa: UInt64(total), exponent: -2, isNegative: false),
                    type: .final
                )
            )
        } else {
            summaryItems.append(
                PKPaymentSummaryItem(
                    label: "Merchant Name",
                    amount: NSDecimalNumber(mantissa: UInt64(total), exponent: -2, isNegative: false)
                )
            )
        }

        self.summaryItems = summaryItems
    }

    // MARK: -

    // MARK: Payment request target

    func didSubmitPaymentRequest(paymentRequest: PaymentRequest) {
        didSubmitPaymentRequest(paymentRequest, success: nil, failure: nil)
    }

    func didSubmitPaymentRequest(_ paymentRequest: PaymentRequest, success: (() -> Void)?, failure: (() -> Void)?) {
        SVProgressHUD.setDefaultMaskType(.clear)
        let status =
            NSLocalizedString(
                "gc.app.general.loading.body",
                tableName: SDKConstants.kSDKLocalizable,
                bundle: AppConstants.sdkBundle,
                value: "",
                comment: ""
            )
        SVProgressHUD.show(withStatus: status)

        self.session.prepare(paymentRequest, success: {(_ preparedPaymentRequest: PreparedPaymentRequest) -> Void in
            SVProgressHUD.dismiss()

            // ***************************************************************************
            //
            // The information contained in preparedPaymentRequest is stored in such a way
            // that it can be sent to the Ingenico ePayments platform via your server.
            //
            // ***************************************************************************
            self.paymentFinishedTarget?.didFinishPayment(preparedPaymentRequest)
            success?()
        }, failure: { _ in
            SVProgressHUD.dismiss()
            let alert =
                UIAlertController(
                    title: NSLocalizedString(
                        "ConnectionErrorTitle",
                        tableName: AppConstants.kAppLocalizable,
                        bundle: AppConstants.appBundle,
                        value: "",
                        comment: "Title of the connection error dialog."
                    ),
                    message:
                        NSLocalizedString(
                            "SubmitErrorExplanation",
                            tableName: AppConstants.kAppLocalizable,
                            bundle: AppConstants.appBundle,
                            value: "",
                            comment: ""
                        ),
                    preferredStyle: .alert
                )
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.navigationController.topViewController?.present(alert, animated: true, completion: nil)

            if failure != nil {
                failure!()
            }
        })
    }

    func didCancelPaymentRequest() {
        navigationController!.popToRootViewController(animated: true)
    }

    // MARK: -

    // MARK: PKPaymentAuthorizationViewControllerDelegate
    // Sent to the delegate after the user has acted on the payment request.  The application
    // should inspect the payment to determine whether the payment request was authorized.
    //
    // If the application requested a shipping address then the full addresses is now part of the payment.
    //
    // The delegate must call completion with an appropriate authorization status, as may be determined
    // by submitting the payment credential to a processing gateway for payment authorization.
    // MARK: -
    // MARK: PKPaymentAuthorizationViewControllerDelegate
    // Sent to the delegate after the user has acted on the payment request.  The application
    // should inspect the payment to determine whether the payment request was authorized.
    //
    // If the application requested a shipping address then the full addresses is now part of the payment.
    //
    // The delegate must call completion with an appropriate authorization status, as may be determined
    // by submitting the payment credential to a processing gateway for payment authorization.
    func paymentAuthorizationViewController(
        _ controller: PKPaymentAuthorizationViewController,
        didAuthorizePayment payment: PKPayment,
        completion: @escaping (PKPaymentAuthorizationStatus
    ) -> Void) {
        DispatchQueue.main.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(1 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC),
            execute: {() -> Void in
                // ***************************************************************************
                //
                // The information contained in preparedPaymentRequest is stored in such a way
                // that it can be sent to the Ingenico ePayments platform via your server.
                //
                // ***************************************************************************

                guard let applePayPaymentProduct = self.applePayPaymentProduct else {
                    Macros.DLog(message: "Invalid Apple pay product.")
                    return
                }

                let request = PaymentRequest(paymentProduct: applePayPaymentProduct)

                guard let paymentDataString =
                        String(data: payment.token.paymentData, encoding: String.Encoding.utf8) else {
                    completion(.failure)
                    return
                }
                request.setValue(forField: "encryptedPaymentData", value: paymentDataString)
                request.setValue(forField: "transactionId", value: payment.token.transactionIdentifier)

                self.didSubmitPaymentRequest(
                    request,
                    success: {() -> Void in
                        completion(.success)
                    },
                    failure: {() -> Void in
                        completion(.failure)
                    }
                )
        })
    }

    // Sent to the delegate when payment authorization is finished.  This may occur when
    // the user cancels the request, or after the PKPaymentAuthorizationStatus parameter of the
    // paymentAuthorizationViewController:didAuthorizePayment:completion: has been shown to the user.
    //
    // The delegate is responsible for dismissing the view controller in this method.
    func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
        applePayPaymentProduct = nil
        authorizationViewController?.dismiss(animated: true, completion: { return })
    }

    // Sent when the user has selected a new payment card.  Use this delegate callback if you need to
    // update the summary items in response to the card type changing (for example, applying credit card surcharges)
    //
    // The delegate will receive no further callbacks except paymentAuthorizationViewControllerDidFinish:
    // until it has invoked the completion block.
    @available(iOS 9.0, *)
    func paymentAuthorizationViewController(
        _ controller: PKPaymentAuthorizationViewController,
        didSelect paymentMethod: PKPaymentMethod,
        completion: @escaping ([PKPaymentSummaryItem]) -> Void
    ) {
        completion(summaryItems)
    }
}
