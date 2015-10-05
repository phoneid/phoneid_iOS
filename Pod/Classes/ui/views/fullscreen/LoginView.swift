//
//  LoginView.swift
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


public protocol LoginViewDelegate: NSObjectProtocol{
    func close()
    func goBack()
    func verifyCode(model:NumberInfo, code:String)
    func numberInputCompleted(model: NumberInfo)
    
}

internal enum LoginState {
    case NumberInput
    case CodeVerification
    case CodeVerificationFail
    case CodeVerificationSuccess
}

public class LoginView: PhoneIdBaseFullscreenView{
    
    private(set) var verifyCodeControl:VerifyCodeControl!
    private(set) var numberInputControl: NumberInputControl!
    
    private(set) var topText: UITextView!
    private(set) var midText: UITextView!
    private(set) var bottomText: UITextView!
    
    private var timer:NSTimer!
    private var textViewBottomConstraint:NSLayoutConstraint!
    
    internal weak var loginViewDelegate:LoginViewDelegate?
    
    override init(model:NumberInfo, scheme:ColorScheme, bundle:NSBundle, tableName:String){
        super.init(model: model, scheme:scheme, bundle:bundle, tableName:tableName)
    }
    
    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit{
        timer?.invalidate()
        timer = nil
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func setupSubviews(){
        super.setupSubviews()
        
        topText = UITextView()
        topText.backgroundColor = UIColor.clearColor()
        topText.editable = false
        topText.scrollEnabled = false
        
        midText = UITextView()
        midText.editable = false
        midText.scrollEnabled = false
        midText.font = UIFont.systemFontOfSize(18)
        midText.backgroundColor = UIColor.clearColor()
        
        setupVerificationCodeControl()
        
        bottomText = UITextView()
        bottomText.editable = false
        bottomText.scrollEnabled = false
        bottomText.hidden = true
        bottomText.backgroundColor = UIColor.clearColor()
        
        numberInputControl = NumberInputControl(model: phoneIdModel, scheme:colorScheme, bundle:localizationBundle, tableName:localizationTableName)
        
        numberInputControl.numberInputCompleted = {(numberInfo)-> Void in
            self.phoneIdModel = numberInfo
            self.loginViewDelegate?.numberInputCompleted(self.phoneIdModel)
        }
        
        let subviews:[UIView] = [verifyCodeControl, numberInputControl, topText, midText, bottomText]
        
        for(_, element) in subviews.enumerate(){
            element.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview(element)
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object:nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object:nil)
    }
    
    func setupVerificationCodeControl(){
        verifyCodeControl = VerifyCodeControl(model: phoneIdModel, scheme:colorScheme, bundle:localizationBundle, tableName:localizationTableName)
        
        verifyCodeControl.verificationCodeDidCahnge = { (code)->Void in
            
            if (code.utf16.count == self.verifyCodeControl.maxVerificationCodeLength) {
                
                self.midText.attributedText = self.localizedStringAttributed("html-logging.in")
                
                if let delegate = self.loginViewDelegate {
                    delegate.verifyCode(self.phoneIdModel, code:code)
                }
                
            } else {
                self.phoneIdService.abortCall()
            }
            
        }
        
        verifyCodeControl.backButtonTapped = { [weak self] in
            self?.verifyCodeControl.resignFirstResponder()
            self?.loginViewDelegate?.goBack()
        }
    }
    
    override func setupLayout(){
        
        super.setupLayout()
        
        var c:[NSLayoutConstraint] = []
        
        c.append(NSLayoutConstraint(item: topText, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1, constant: 0))
        c.append(NSLayoutConstraint(item: topText, attribute: .Top, relatedBy: .Equal, toItem: self.headerBackgroundView, attribute: .Bottom, multiplier: 1, constant: 20))
        c.append(NSLayoutConstraint(item: topText, attribute: .Bottom, relatedBy: .Equal, toItem: numberInputControl, attribute: .TopMargin, multiplier: 1, constant: 0))
        c.append(NSLayoutConstraint(item: topText, attribute: .Width, relatedBy: .Equal, toItem: self, attribute: .Width, multiplier: 0.8, constant: 0))
        
        c.append(NSLayoutConstraint(item: numberInputControl, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1, constant: 0))
        c.append(NSLayoutConstraint(item: numberInputControl, attribute: .Width, relatedBy: .Equal, toItem: self, attribute: .Width, multiplier: 0.8, constant: 0))
        c.append(NSLayoutConstraint(item: numberInputControl, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .Height, multiplier: 1, constant: 50))
        
        c.append(NSLayoutConstraint(item: verifyCodeControl, attribute: .CenterX, relatedBy: .Equal, toItem: numberInputControl, attribute: .CenterX, multiplier: 1, constant: 0))
        c.append(NSLayoutConstraint(item: verifyCodeControl, attribute: .CenterY, relatedBy: .Equal, toItem: numberInputControl, attribute: .CenterY, multiplier: 1, constant: 0))
        c.append(NSLayoutConstraint(item: verifyCodeControl, attribute: .Width, relatedBy: .Equal, toItem: numberInputControl, attribute: .Width, multiplier: 1, constant: 0))
        c.append(NSLayoutConstraint(item: verifyCodeControl, attribute: .Height, relatedBy: .Equal, toItem: numberInputControl, attribute: .Height, multiplier: 1, constant: 0))
        
        c.append(NSLayoutConstraint(item: midText, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1, constant: 0))
        c.append(NSLayoutConstraint(item: midText, attribute: .Top, relatedBy: .Equal, toItem: numberInputControl, attribute: .Bottom, multiplier: 1, constant: 20))
        c.append(NSLayoutConstraint(item: midText, attribute: .Width, relatedBy: .Equal, toItem: numberInputControl, attribute: .Width, multiplier: 1, constant:0))
        
        c.append(NSLayoutConstraint(item: bottomText, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1, constant: 0))
        
        textViewBottomConstraint = NSLayoutConstraint(item: bottomText, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1, constant: -20)
        c.append(textViewBottomConstraint)
        
        c.append(NSLayoutConstraint(item: bottomText, attribute: .Width, relatedBy: .Equal, toItem: numberInputControl, attribute: .Width, multiplier: 1, constant:0))
        
        self.customConstraints += c
        
        self.addConstraints(c)
        
    }
    
    override func localizeAndApplyColorScheme(){
        
        super.localizeAndApplyColorScheme()
        titleLabel.attributedText =  localizedStringAttributed("html-title.login")
        
        self.needsUpdateConstraints()
    }
    
    
    func switchToState(state:LoginState, completion:(()->Void)? = nil){
        
        self.numberInputControl.hidden = state != .NumberInput
        self.verifyCodeControl.hidden = !self.numberInputControl.hidden
        midText.hidden =  false
        timer?.invalidate()
        switch(state){
        case .NumberInput:
            indicateNumberInput()
            break
        case .CodeVerification:
            indicateCodeVerification()
            break
        case .CodeVerificationFail:
            indicateVerificationFail()
            break
        case .CodeVerificationSuccess:
            indicateVerificationSuccess(completion)
            break
        }
    }
    
    func setupHintTimer(){
        
        
        let fireDate = NSDate(timeIntervalSinceNow: 30)
        timer = NSTimer(fireDate: fireDate, interval: 0, target: self, selector: "timerFired", userInfo: nil, repeats: false)
        NSRunLoop.mainRunLoop().addTimer(timer!, forMode: NSDefaultRunLoopMode)
        
    }
    
    func indicateNumberInput(){
        numberInputControl.validatePhoneNumber()
        numberInputControl.becomeFirstResponder()
        topText.attributedText = localizedStringAttributed("html-access.app.with.number") { (tmpResult) -> String in
            return String(format: tmpResult, self.phoneIdService.appName!)
        }
        
        midText.attributedText = localizedStringAttributed("html-label.we.will.send.sms")
        bottomText.attributedText = localizedStringAttributed("html-label.terms.and.conditions")
        
        bottomText.linkTextAttributes = [NSFontAttributeName: UIFont.systemFontOfSize(15),NSForegroundColorAttributeName:colorScheme.linkText]
        needsUpdateConstraints()
        bottomText.hidden = false
    }
    
    func indicateCodeVerification(){
        verifyCodeControl.reset()
        verifyCodeControl.becomeFirstResponder()
        verifyCodeControl.codeText.inputAccessoryView = nil
        verifyCodeControl.codeText.reloadInputViews()
        
        topText.attributedText = localizedStringAttributed("html-type.the.confirmation.code")
        midText.attributedText = nil
        midText.textColor = colorScheme.normalText
        bottomText.hidden = true
        setupHintTimer()
    }
    
    func indicateVerificationFail(){
        self.midText.attributedText = localizedStringAttributed("html-loggin.failed")
        verifyCodeControl.indicateVerificationFail()
    }
    
    func indicateVerificationSuccess(completion:(()->Void)?){
        self.midText.attributedText = localizedStringAttributed("html-logged.in")
        verifyCodeControl.indicateVerificationSuccess(completion)
    }
    
    func timerFired(){
        midText.attributedText = localizedStringAttributed("html-label.when.code.not.received")
        
        let toolBar = UIToolbar(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, 44))
        
        let callMeButton = UIBarButtonItem(title: localizedString("button.title.call.me"), style: .Plain, target: self, action: "callMeButtonTapped")
        
        let space = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
        
        toolBar.items = [space, callMeButton]
        
        verifyCodeControl.codeText.inputAccessoryView = toolBar
        verifyCodeControl.codeText.reloadInputViews()
        
    }
    
    func callMeButtonTapped(){
        
    }
    
    func keyboardWillShow(sender: NSNotification) {
        if let userInfo = sender.userInfo {
            if let keyboardHeight = userInfo[UIKeyboardFrameEndUserInfoKey]?.CGRectValue.size.height {
                textViewBottomConstraint.constant = -keyboardHeight
                UIView.animateWithDuration(0.25, animations: { () -> Void in
                    self.layoutIfNeeded()
                })
            }
        }
    }
    
    func keyboardWillHide(sender: NSNotification) {
        textViewBottomConstraint.constant = -25
        UIView.animateWithDuration(0.25, animations: { () -> Void in
            self.layoutIfNeeded()
        })
    }
    
    override func closeButtonTapped(){
        loginViewDelegate?.close()
    }
}
