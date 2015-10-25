//
//  LoginViewController.swift
//  phoneid_iOS
//
//  Copyright 2015 phone.id - 73 knots, Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import UIKit

public class LoginViewController: UIViewController, PhoneIdConsumer, LoginViewDelegate {

    private var loginView: LoginView! {
        get {
            let result = self.view as? LoginView
            if (result == nil) {
                fatalError("self.view expected to be kind of LoginView")
            }
            return result
        }
    }

    lazy internal var phoneIdModel: NumberInfo = {
        let result = NumberInfo()
        return result
    }()

    public init() {
        super.init(nibName: nil, bundle: nil)
    }

    required public init(coder aDecoder: NSCoder) {
        fatalError("NSCoding not supported")
    }

    public override func loadView() {
        let result = phoneIdComponentFactory.loginView(self.phoneIdModel)
        result.loginViewDelegate = self

        self.view = result
        self.loginView.switchToState(.NumberInput)

        self.loginView.verifyCodeControl.requestVoiceCall = {
            self.phoneIdService.requestAuthenticationCode(self.phoneIdModel, channel: .Call, completion: {
                (error) -> Void in
                if let e = error {
                    self.presentError(e)
                }
            })
        }
    }

    public func numberInputCompleted(model: NumberInfo) {
        self.phoneIdModel = model
        phoneIdService.requestAuthenticationCode(phoneIdModel, completion: {
            (error) -> Void in
            if let e = error {
                self.presentError(e)
            } else {
                self.loginView.switchToState(.CodeVerification)
            }
        })
    }

    func presentError(error: NSError) {
        let bundle = self.phoneIdService.componentFactory.localizationBundle
        let alert = UIAlertController(title: NSLocalizedString("alert.title.error", bundle: bundle, comment: "Error"), message: "\(error.localizedDescription)", preferredStyle: UIAlertControllerStyle.Alert)

        alert.addAction(UIAlertAction(title: NSLocalizedString("alert.button.title.dismiss", bundle: bundle, comment: "Dismiss"), style: .Cancel, handler: nil))

        self.presentViewController(alert, animated: false, completion: nil)
    }

    public func goBack() {
        self.loginView.switchToState(.NumberInput)
    }

    public func verifyCode(model: NumberInfo, code: String) {
        phoneIdService.verifyAuthentication(code, info: model) {
            [unowned self] (token, error) -> Void in

            if (error == nil) {
                self.loginView.switchToState(.CodeVerificationSuccess) {
                    self.callPhoneIdCompletion(true)
                    self.dismissViewControllerAnimated(true, completion: nil)
                    PhoneIdWindow.activePhoneIdWindow()?.close()
                }

            } else {
                self.loginView.switchToState(.CodeVerificationFail)
            }

        }
    }

    func callPhoneIdCompletion(success: Bool) {
        if (success) {
            print("PhoneId login finished")
            self.phoneIdService.phoneIdAuthenticationSucceed?(token: self.phoneIdService.token!)
        } else {
            print("PhoneId login cancelled")
            self.phoneIdService.phoneIdAuthenticationCancelled?()
        }
    }

    public func close() {
        self.loginView.resignFirstResponder()
        self.dismissViewControllerAnimated(true, completion: nil)
        self.callPhoneIdCompletion(false)
        PhoneIdWindow.activePhoneIdWindow()?.close()
    }
}