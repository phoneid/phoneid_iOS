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



@IBDesignable open class CompactPhoneIdLoginButton: PhoneIdBaseView {
    @objc open var phoneNumberE164: String! {
        get {
            return self.phoneIdModel.e164Format()
        }
        set {
            self.phoneIdModel = NumberInfo(numberE164: newValue)
            self.numberInputControl?.setupWithModel(self.phoneIdModel)
            self.verifyCodeControl?.setupWithModel(self.phoneIdModel)
        }
    }

    fileprivate(set) var loginButton: PhoneIdLoginButton!
    fileprivate(set) var numberInputControl: NumberInputControl!
    fileprivate(set) var verifyCodeControl: VerifyCodeControl!
    
    @objc open var titleText:String?{
        get{ return loginButton.titleLabel.text}
        set{ loginButton.titleLabel.text = newValue}
    }
    
    @objc open var placeholderText:String?{
        get{ return numberInputControl.numberText.placeholder}
        set{ numberInputControl.numberText.placeholder = newValue}
    }

    @objc public init() {
        super.init(frame: CGRect.zero)
        prep()
        initUI(designtime: false)
    }

    // init from viewcontroller
    @objc public override init(frame: CGRect) {
        super.init(frame: frame)
        prep()
        initUI(designtime: false)
    }

    // init from interface builder
    @objc required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        prep()
        initUI(designtime: false);
    }
    
    @objc override open func prepareForInterfaceBuilder() {
        self.prep()
        initUI(designtime: true);
    }
    
    fileprivate class InternalPhoneIdLoginButton: PhoneIdLoginButton{
        var loginTouchedBlock: (() -> Void)?
        override func loginTouched() { loginTouchedBlock?() }
    }
    
    func initUI(designtime:Bool) {

        loginButton = InternalPhoneIdLoginButton(frame:CGRect.zero, designtime:designtime)

        

        var subviews:[UIView] = []
        
        if designtime {
            subviews = [loginButton]
            
        }else{
            phoneIdModel = NumberInfo()
            setupNumberInputControl()
            setupVerificationCodeControl()
            subviews = [loginButton, numberInputControl, verifyCodeControl]
            
            (loginButton as? InternalPhoneIdLoginButton)?.loginTouchedBlock = {
                self.numberInputControl.isHidden = false
                self.loginButton.isHidden = true
                self.numberInputControl.validatePhoneNumber()
                self.numberInputControl.becomeFirstResponder()
            }
        }


        for subview in subviews {
            subview.translatesAutoresizingMaskIntoConstraints = false
            addSubview(subview)
            addConstraint(NSLayoutConstraint(item: subview, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0))
            addConstraint(NSLayoutConstraint(item: subview, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
            addConstraint(NSLayoutConstraint(item: subview, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 1, constant: 0))
            addConstraint(NSLayoutConstraint(item: subview, attribute: .height, relatedBy: .equal, toItem: self, attribute: .height, multiplier: 1, constant: 0))
            subview.isHidden = true
        }

        loginButton.isHidden = false

 

    }

    func prep() {
        localizationBundle = phoneIdComponentFactory.localizationBundle
        localizationTableName = phoneIdComponentFactory.localizationTableName
        colorScheme = phoneIdComponentFactory.colorScheme

        let notificator = NotificationCenter.default
        notificator.addObserver(self, selector: #selector(CompactPhoneIdLoginButton.doOnSuccessfulLogin), name: NSNotification.Name(rawValue: Notifications.VerificationSuccess), object: nil)
       notificator.addObserver(self, selector: #selector(CompactPhoneIdLoginButton.doOnlogout), name: NSNotification.Name(rawValue: Notifications.DidLogout), object: nil)

    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func setupNumberInputControl() {

        numberInputControl = NumberInputControl(model: phoneIdModel, scheme: colorScheme, bundle: localizationBundle, tableName: localizationTableName)

        numberInputControl.numberInputCompleted = { [weak self] (numberInfo) -> Void in
            guard let me = self else {return}
            me.phoneIdModel = numberInfo
            me.verifyCodeControl.phoneIdModel = numberInfo
            me.requestAuthentication()
            PhoneIdService.sharedInstance.phoneIdWorkflowNumberInputCompleted?(numberInfo)
        }

    }

    func setupVerificationCodeControl() {

        verifyCodeControl = VerifyCodeControl(model: phoneIdModel, scheme: colorScheme, bundle: localizationBundle, tableName: self.localizationTableName)

        verifyCodeControl.verificationCodeDidCahnge = { [weak self] (code) -> Void in
            guard let me = self else {return}

            if (code.utf16.count == me.verifyCodeControl.maxVerificationCodeLength) {

                PhoneIdService.sharedInstance.phoneIdWorkflowVerificationCodeInputCompleted?(code)
                
                me.phoneIdService.verifyAuthentication(code, info: me.phoneIdModel) { (token, error) -> Void in
                    guard let me = self else {return}

                    if (error == nil) {
                        me.verifyCodeControl.indicateVerificationSuccess() { [weak self] in
                            guard let me = self else {return}
                            print("PhoneId login finished")
                            me.phoneIdService.phoneIdAuthenticationSucceed?(me.phoneIdService.token!)
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
            self.verifyCodeControl.isHidden = true
            self.numberInputControl.isHidden = false
            self.numberInputControl.validatePhoneNumber()
            self.numberInputControl.becomeFirstResponder()
        }

        verifyCodeControl.requestVoiceCall = {
            self.phoneIdService.requestAuthenticationCode(self.phoneIdModel, channel: .call, completion: {
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
                me.numberInputControl.isHidden = true
                me.verifyCodeControl.isHidden = false
                me.verifyCodeControl.becomeFirstResponder()
                me.verifyCodeControl.setupHintTimer()
            }
        });
    }

    func presentErrorMessage(_ error: NSError) {
        let bundle = self.phoneIdService.componentFactory.localizationBundle
        let alert = UIAlertController(title: NSLocalizedString("alert.title.error", bundle: bundle, comment: "Error"), message: "\(error.localizedDescription)", preferredStyle: UIAlertControllerStyle.alert)

        alert.addAction(UIAlertAction(title: NSLocalizedString("alert.button.title.dismiss", bundle: bundle, comment: "Dismiss"), style: .cancel, handler: nil))

        let presenter: UIViewController = PhoneIdWindow.currentPresenter()
        presenter.present(alert, animated: true, completion: nil)
        self.numberInputControl.validatePhoneNumber()
    }


    @objc func doOnSuccessfulLogin() -> Void {

    }

    @objc func doOnlogout() -> Void {
        resetControls()
    }

    func resetControls() {
        if let control = numberInputControl {
            control.reset();
            control.isHidden = true
            control.resignFirstResponder()
        }

        if let control = verifyCodeControl {
            control.reset();
            control.isHidden = true
            control.resignFirstResponder()
        }
        self.loginButton?.isHidden = false
    }

    @objc open override var intrinsicContentSize : CGSize {
        return CGSize(width: 280, height: 48)
    }

}
