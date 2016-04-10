//
//  CompactPhoneIdLoginButton.swift
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



@IBDesignable public class CompactPhoneIdLoginButton: PhoneIdBaseView {
    public var phoneNumberE164: String! {
        get {
            return self.phoneIdModel.e164Format()
        }
        set {
            self.phoneIdModel = NumberInfo(numberE164: newValue)
            self.numberInputControl?.setupWithModel(self.phoneIdModel)
            self.verifyCodeControl?.setupWithModel(self.phoneIdModel)
        }
    }

    private(set) var loginButton: PhoneIdLoginButton!
    private(set) var numberInputControl: NumberInputControl!
    private(set) var verifyCodeControl: VerifyCodeControl!
    
    public var titleText:String?{
        get{ return loginButton.titleLabel.text}
        set{ loginButton.titleLabel.text = newValue}
    }
    
    public var placeholderText:String?{
        get{ return numberInputControl.numberText.placeholder}
        set{ numberInputControl.numberText.placeholder = newValue}
    }

    public init() {
        super.init(frame: CGRectZero)
        prep()
        initUI()
    }

    // init from viewcontroller
    public override init(frame: CGRect) {
        super.init(frame: frame)
        prep()
        initUI()
    }

    // init from interface builder
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        prep()
        initUI();
    }
    
    override public func prepareForInterfaceBuilder() {
        self.prep()
        initUI(designtime: true);
    }
    
    private class InternalPhoneIdLoginButton: PhoneIdLoginButton{
        var loginTouchedBlock: (() -> Void)?
        override func loginTouched() { loginTouchedBlock?() }
    }
    
    func initUI(designtime designtime:Bool = false) {

        loginButton = InternalPhoneIdLoginButton()

        phoneIdModel = NumberInfo()

        var subviews:[UIView] = []
        
        if designtime {
            subviews = [loginButton]
        }else{
            setupNumberInputControl()
            setupVerificationCodeControl()
            
            subviews = [loginButton, numberInputControl, verifyCodeControl]
        }

        for subview in subviews {
            subview.translatesAutoresizingMaskIntoConstraints = false
            addSubview(subview)
            addConstraint(NSLayoutConstraint(item: subview, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1, constant: 0))
            addConstraint(NSLayoutConstraint(item: subview, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1, constant: 0))
            addConstraint(NSLayoutConstraint(item: subview, attribute: .Width, relatedBy: .Equal, toItem: self, attribute: .Width, multiplier: 1, constant: 0))
            addConstraint(NSLayoutConstraint(item: subview, attribute: .Height, relatedBy: .Equal, toItem: self, attribute: .Height, multiplier: 1, constant: 0))
            subview.hidden = true
        }

        loginButton.hidden = false

        (loginButton as? InternalPhoneIdLoginButton)?.loginTouchedBlock = {
            self.numberInputControl.hidden = false
            self.loginButton.hidden = true
            self.numberInputControl.validatePhoneNumber()
            self.numberInputControl.becomeFirstResponder()
        }

    }

    func prep() {
        localizationBundle = phoneIdComponentFactory.localizationBundle
        localizationTableName = phoneIdComponentFactory.localizationTableName
        colorScheme = phoneIdComponentFactory.colorScheme

        let notificator = NSNotificationCenter.defaultCenter()
        notificator.addObserver(self, selector: #selector(CompactPhoneIdLoginButton.doOnSuccessfulLogin), name: Notifications.VerificationSuccess, object: nil)
       notificator.addObserver(self, selector: #selector(CompactPhoneIdLoginButton.doOnlogout), name: Notifications.DidLogout, object: nil)

    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    func setupNumberInputControl() {

        numberInputControl = NumberInputControl(model: phoneIdModel, scheme: colorScheme, bundle: localizationBundle, tableName: localizationTableName)

        numberInputControl.numberInputCompleted = {
            (numberInfo) -> Void in
            self.phoneIdModel = numberInfo
            self.verifyCodeControl.phoneIdModel = numberInfo
            self.requestAuthentication()
        }

    }

    func setupVerificationCodeControl() {

        verifyCodeControl = VerifyCodeControl(model: phoneIdModel, scheme: colorScheme, bundle: localizationBundle, tableName: self.localizationTableName)

        verifyCodeControl.verificationCodeDidCahnge = { [weak self] (code) -> Void in
            guard let me = self else {return}

            if (code.utf16.count == me.verifyCodeControl.maxVerificationCodeLength) {

                me.phoneIdService.verifyAuthentication(code, info: me.phoneIdModel) { (token, error) -> Void in
                    guard let me = self else {return}

                    if (error == nil) {
                        me.verifyCodeControl.indicateVerificationSuccess() { [weak self] in
                            guard let me = self else {return}
                            print("PhoneId login finished")
                            me.phoneIdService.phoneIdAuthenticationSucceed?(token: me.phoneIdService.token!)
                            me.resetControls()
                        }
                    } else {
                        print("PhoneId login cancelled")
                        me.verifyCodeControl.indicateVerificationFail()
                    }

                }

            } else {
                me.phoneIdService.abortCall()
            }

        }

        verifyCodeControl.backButtonTapped = {
            self.verifyCodeControl.reset()
            self.verifyCodeControl.resignFirstResponder()
            self.verifyCodeControl.hidden = true
            self.numberInputControl.hidden = false
            self.numberInputControl.validatePhoneNumber()
            self.numberInputControl.becomeFirstResponder()
        }

        verifyCodeControl.requestVoiceCall = {
            self.phoneIdService.requestAuthenticationCode(self.phoneIdModel, channel: .Call, completion: {
                [weak self] (error) -> Void in
                
                if let e = error {
                    self?.presentErrorMessage(e)
                }
            })
        }
    }

    func requestAuthentication() {

        phoneIdService.requestAuthenticationCode(self.phoneIdModel, completion: {
            [weak self] (error) -> Void in

            guard let me = self else {return}
            
            if let e = error {
                me.presentErrorMessage(e)
            } else {
                me.numberInputControl.hidden = true
                me.verifyCodeControl.hidden = false
                me.verifyCodeControl.becomeFirstResponder()
                me.verifyCodeControl.setupHintTimer()
            }
        });
    }

    func presentErrorMessage(error: NSError) {
        let bundle = self.phoneIdService.componentFactory.localizationBundle
        let alert = UIAlertController(title: NSLocalizedString("alert.title.error", bundle: bundle, comment: "Error"), message: "\(error.localizedDescription)", preferredStyle: UIAlertControllerStyle.Alert)

        alert.addAction(UIAlertAction(title: NSLocalizedString("alert.button.title.dismiss", bundle: bundle, comment: "Dismiss"), style: .Cancel, handler: nil))

        let presenter: UIViewController = PhoneIdWindow.currentPresenter()
        presenter.presentViewController(alert, animated: true, completion: nil)
        self.numberInputControl.validatePhoneNumber()
    }


    func doOnSuccessfulLogin() -> Void {

    }

    func doOnlogout() -> Void {
        resetControls()
    }

    func resetControls() {
        if let control = numberInputControl {
            control.reset();
            control.hidden = true
            control.resignFirstResponder()
        }

        if let control = verifyCodeControl {
            control.reset();
            control.hidden = true
            control.resignFirstResponder()
        }
        self.loginButton?.hidden = false
    }


}
