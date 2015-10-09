//
//  VerifyCodeControl.swift
//
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

class VerifyCodeControl: PhoneIdBaseView {
    
    private(set) var placeholderView:UIView!
    private(set) var codeText:NumericTextField!
    private(set) var placeholderLabel:UILabel!
    private(set) var activityIndicator:UIActivityIndicatorView!
    private(set) var backButton:UIButton!
    private(set) var statusImage: UIImageView!
    
    var verificationCodeDidCahnge: ((code:String)->Void)?
    var requestVoiceCall: (()->Void)?
    var backButtonTapped: (()->Void)?
    
    let maxVerificationCodeLength = 6
     private var timer:NSTimer!
    
    override func setupSubviews(){
        super.setupSubviews()
        
        codeText = NumericTextField(maxLength: maxVerificationCodeLength)
        codeText.keyboardType = .NumberPad
        codeText.addTarget(self, action:"textFieldDidChange:", forControlEvents:.EditingChanged)
        codeText.backgroundColor = UIColor.clearColor()
        
        placeholderLabel=UILabel()
        
        let attributedString:NSMutableAttributedString = NSMutableAttributedString(string: "______")
        
        placeholderLabel.attributedText = applyCodeFieldStyle(attributedString)
        
        activityIndicator=UIActivityIndicatorView()
        activityIndicator.activityIndicatorViewStyle = .WhiteLarge
        
        statusImage = UIImageView()
        
        placeholderView = UIView()
        placeholderView.layer.cornerRadius = 5
        
        backButton = UIButton()
        backButton.setImage(UIImage(namedInPhoneId: "compact-back"), forState: .Normal)
        backButton.addTarget(self, action: "backTapped:", forControlEvents: .TouchUpInside)
        
        
        let subviews:[UIView] = [placeholderView, placeholderLabel, codeText, activityIndicator, backButton, statusImage]
        
        for(_, element) in subviews.enumerate(){
            element.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview(element)
        }
        
    }
    
    deinit{
        timer?.invalidate()
        timer = nil
    }
    
    override func setupLayout(){
        
        super.setupLayout()
        
        var c:[NSLayoutConstraint] = []
        
        c.append(NSLayoutConstraint(item: placeholderView, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1, constant: 0))
        c.append(NSLayoutConstraint(item: placeholderView, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1, constant: 0))
        c.append(NSLayoutConstraint(item: placeholderView, attribute: .Width, relatedBy: .Equal, toItem: self, attribute: .Width, multiplier: 1, constant: 0))
        c.append(NSLayoutConstraint(item: placeholderView, attribute: .Height, relatedBy: .Equal, toItem: self, attribute: .Height, multiplier: 1, constant: 0))
        
        c.append(NSLayoutConstraint(item: placeholderLabel, attribute: .CenterX, relatedBy: .Equal, toItem: placeholderView, attribute: .CenterX, multiplier: 1, constant: 0))
        c.append(NSLayoutConstraint(item: placeholderLabel, attribute: .CenterY, relatedBy: .Equal, toItem: placeholderView, attribute: .CenterY, multiplier: 1, constant: 5))
        
        c.append(NSLayoutConstraint(item: backButton, attribute: .CenterY, relatedBy: .Equal, toItem: placeholderView, attribute: .CenterY, multiplier: 1, constant:0))
        c.append(NSLayoutConstraint(item: backButton, attribute: .Left, relatedBy: .Equal, toItem: placeholderView, attribute: .Left, multiplier: 1, constant:18))
        c.append(NSLayoutConstraint(item: backButton, attribute: .Height, relatedBy: .Equal, toItem: self, attribute: .Height, multiplier: 1, constant:0))
        
        c.append(NSLayoutConstraint(item: codeText, attribute: .CenterX, relatedBy: .Equal, toItem: placeholderLabel, attribute: .CenterX, multiplier: 1, constant: 2))
        c.append(NSLayoutConstraint(item: codeText, attribute: .CenterY, relatedBy: .Equal, toItem: placeholderView, attribute: .CenterY, multiplier: 1, constant: -2))
        c.append(NSLayoutConstraint(item: codeText, attribute: .Width, relatedBy: .Equal, toItem: placeholderLabel, attribute: .Width, multiplier: 1, constant: 5))
        
        c.append(NSLayoutConstraint(item: activityIndicator, attribute: .CenterY, relatedBy: .Equal, toItem: placeholderView, attribute: .CenterY, multiplier: 1, constant:0))
        c.append(NSLayoutConstraint(item: activityIndicator, attribute: .Right, relatedBy: .Equal, toItem: placeholderView, attribute: .Right, multiplier: 1, constant:-5))
        
        c.append(NSLayoutConstraint(item: statusImage, attribute: .CenterX, relatedBy: .Equal, toItem: activityIndicator, attribute: .CenterX, multiplier: 1, constant: 0))
        c.append(NSLayoutConstraint(item: statusImage, attribute: .CenterY, relatedBy: .Equal, toItem: activityIndicator, attribute: .CenterY, multiplier: 1, constant: 0))
        
        self.addConstraints(c)
        
    }
    
    override func localizeAndApplyColorScheme(){
        
        super.localizeAndApplyColorScheme()
        
        placeholderView.backgroundColor = colorScheme.defaultTextInputBackground
        codeText.textColor = colorScheme.inputText
        codeText.accessibilityLabel = localizedString("accessibility.verification.input");
        backButton.accessibilityLabel = localizedString("accessibility.button.title.back");
        placeholderLabel.textColor = colorScheme.mainAccent
        activityIndicator.color = colorScheme.disabledText
        self.needsUpdateConstraints()
    }
    
    
    // TODO: need to provide fonts from Font factory, like as colors from ColorScheme
    private func applyCodeFieldStyle(input:NSAttributedString)->NSAttributedString {
        let attributedString:NSMutableAttributedString = NSMutableAttributedString(attributedString: input)
        let range:NSRange = NSMakeRange(0, attributedString.length)
        attributedString.addAttribute(NSKernAttributeName, value: 8, range: range)
        
        if(attributedString.length > 2){
            let range:NSRange = NSMakeRange(2, 1)
            attributedString.addAttribute(NSKernAttributeName, value: 24, range: range)
        }
        
        attributedString.addAttribute(NSFontAttributeName, value: UIFont(name: "Menlo", size: 22)!, range: range)
        return attributedString
    }
    
    func textFieldDidChange(textField:UITextField) {
        
        textField.attributedText = applyCodeFieldStyle(textField.attributedText!)
        
        if (textField.text!.utf16.count == maxVerificationCodeLength) {
            
            activityIndicator.startAnimating()
            backButton.enabled = false
            
        } else {
            
            activityIndicator.stopAnimating()
            phoneIdService.abortCall()
            statusImage.hidden = true
            backButton.enabled = true
        }
        
        self.verificationCodeDidCahnge?(code: textField.text!)
        
    }
    
    func backTapped(sender:UIButton){
        backButtonTapped?()
    }
    
    func indicateVerificationFail(){
        activityIndicator.stopAnimating()
        statusImage.image = UIImage(namedInPhoneId: "icon-ko")
        statusImage.hidden = false
        backButton.enabled = true
    }
    
    func indicateVerificationSuccess(completion:(()->Void)?){
        
        activityIndicator.stopAnimating()
        statusImage.image = UIImage(namedInPhoneId: "icon-ok")
        statusImage.hidden = false
        
        UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: [], animations: { () -> Void in
            self.statusImage.transform = CGAffineTransformMakeScale(1.3, 1.3)
            }) {(_) -> Void in
                self.statusImage.transform = CGAffineTransformMakeScale(1, 1)
                completion?()
        }
        
    }
    
    func reset(){
        codeText.text=""
        codeText.inputAccessoryView = nil
        codeText.reloadInputViews()
        textFieldDidChange(codeText)
        timer?.invalidate()
    }
    
    override func resignFirstResponder() -> Bool {
        return codeText.resignFirstResponder()
    }
    
    override func becomeFirstResponder() -> Bool {
        return codeText.becomeFirstResponder()
    }
    
    func setupHintTimer(){
        
        timer?.invalidate()
        let fireDate = NSDate(timeIntervalSinceNow: 30)
        timer = NSTimer(fireDate: fireDate, interval: 0, target: self, selector: "timerFired", userInfo: nil, repeats: false)
        NSRunLoop.mainRunLoop().addTimer(timer!, forMode: NSDefaultRunLoopMode)
        
    }
    
    func timerFired(){
        let toolBar = UIToolbar(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, 44))
        
        let callMeButton = UIBarButtonItem(title: localizedString("button.title.call.me"), style: .Plain, target: self, action: "callMeButtonTapped")
        
        let space = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
        
        toolBar.items = [space, callMeButton]
        codeText.resignFirstResponder()
        codeText.inputAccessoryView = toolBar
        codeText.becomeFirstResponder()
    }
    
    func callMeButtonTapped(){
        requestVoiceCall?()
    }
    
}
