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

open class LoginViewController: UIViewController, PhoneIdConsumer, LoginViewDelegate {

    fileprivate var loginView: LoginView! {
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

    open override func loadView() {
        let result = phoneIdComponentFactory.loginView(self.phoneIdModel)
        result.loginViewDelegate = self

        self.view = result
        self.loginView.switchToState(.numberInput)

        self.loginView.verifyCodeControl.requestVoiceCall = {
            self.phoneIdService.requestAuthenticationCode(self.phoneIdModel, channel: .call, completion: {
                (error) -> Void in
                if let e = error {
                    self.presentError(e)
                }
            })
        }
        
        self.phoneIdService.phoneIdDidGotPhoneNumberHint = { number in
            let alreadySetNumber = self.loginView.numberInputControl.numberText.text
            if alreadySetNumber == nil || alreadySetNumber == ""{
               self.updateFromHint()
            }
        }
        updateFromHint()
    }

    func updateFromHint(){
        if let hint = self.phoneIdService.phoneNumberHintParsed {
            self.loginView.numberInputControl.setupWithModel(hint)
        }
    }
    
    open func numberInputCompleted(_ model: NumberInfo) {
        self.phoneIdModel = model
        
        PhoneIdService.sharedInstance.phoneIdWorkflowNumberInputCompleted?(model)
        
        phoneIdService.requestAuthenticationCode(phoneIdModel, completion: {
            (error) -> Void in
            if let e = error {
                self.presentError(e)
            } else {
                self.loginView.switchToState(.codeVerification)
            }
        })
    }

    func presentError(_ error: NSError) {
        let bundle = self.phoneIdService.componentFactory.localizationBundle
        let alert = UIAlertController(title: NSLocalizedString("alert.title.error", bundle: bundle, comment: "Error"), message: "\(error.localizedDescription)", preferredStyle: UIAlertControllerStyle.alert)

        alert.addAction(UIAlertAction(title: NSLocalizedString("alert.button.title.dismiss", bundle: bundle, comment: "Dismiss"), style: .cancel, handler: nil))

        self.present(alert, animated: false, completion: nil)
    }

    open func goBack() {
        self.loginView.switchToState(.numberInput)
    }

    open func verifyCode(_ model: NumberInfo, code: String) {
        
        PhoneIdService.sharedInstance.phoneIdWorkflowVerificationCodeInputCompleted?(code)
        
        phoneIdService.verifyAuthentication(code, info: model) {
            [unowned self] (token, error) -> Void in

            if (error == nil) {
                self.loginView.switchToState(.codeVerificationSuccess) {
                    self.callPhoneIdCompletion(true)
                    self.dismiss(animated: true, completion: nil)
                    PhoneIdWindow.activePhoneIdWindow()?.close()
                }

            } else {
                self.loginView.switchToState(.codeVerificationFail)
            }

        }
    }

    func callPhoneIdCompletion(_ success: Bool) {
        if (success) {
            print("PhoneId login finished")
            self.phoneIdService.phoneIdAuthenticationSucceed?(self.phoneIdService.token!)
        } else {
            print("PhoneId login cancelled")
            self.phoneIdService.phoneIdAuthenticationCancelled?()
        }
    }

    open func close() {
        self.loginView.resignFirstResponder()
        self.dismiss(animated: true, completion: nil)
        self.callPhoneIdCompletion(false)
        PhoneIdWindow.activePhoneIdWindow()?.close()
    }
}
