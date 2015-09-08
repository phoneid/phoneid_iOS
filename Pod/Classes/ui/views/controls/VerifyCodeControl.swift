//
//  VerifyCodeControl.swift
//
//  phoneid_iOS
//
//  Copyright 2015 Federico Pomi
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
    var backButtonTapped: (()->Void)?
    
    let maxVerificationCodeLength = 6

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
        backButton.setImage(UIImage(namedInPhoneId: "icon-back"), forState: .Normal)
        backButton.addTarget(self, action: "backTapped:", forControlEvents: .TouchUpInside)
        
        
        let subviews:[UIView] = [placeholderView, placeholderLabel, codeText, activityIndicator, backButton, statusImage]
        
        for(_, element) in subviews.enumerate(){
            element.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview(element)
        }
        
    }
    
    override func setupLayout(){
        
        super.setupLayout()
        
        var c:[NSLayoutConstraint] = []
        
        c.append(NSLayoutConstraint(item: placeholderView, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1, constant: 0))
        c.append(NSLayoutConstraint(item: placeholderView, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1, constant: 0))
        c.append(NSLayoutConstraint(item: placeholderView, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .Width, multiplier: 1, constant: 290))
        c.append(NSLayoutConstraint(item: placeholderView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .Height, multiplier: 1, constant: 50))
        
        c.append(NSLayoutConstraint(item: placeholderLabel, attribute: .CenterX, relatedBy: .Equal, toItem: placeholderView, attribute: .CenterX, multiplier: 1, constant: 0))
        c.append(NSLayoutConstraint(item: placeholderLabel, attribute: .CenterY, relatedBy: .Equal, toItem: placeholderView, attribute: .CenterY, multiplier: 1, constant: 7))
        
        c.append(NSLayoutConstraint(item: backButton, attribute: .CenterY, relatedBy: .Equal, toItem: placeholderView, attribute: .CenterY, multiplier: 1, constant:0))
        c.append(NSLayoutConstraint(item: backButton, attribute: .Left, relatedBy: .Equal, toItem: placeholderView, attribute: .Left, multiplier: 1, constant:10))
        c.append(NSLayoutConstraint(item: backButton, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .Height, multiplier: 1, constant:44))
        
        c.append(NSLayoutConstraint(item: codeText, attribute: .CenterX, relatedBy: .Equal, toItem: placeholderLabel, attribute: .CenterX, multiplier: 1, constant: 2))
        c.append(NSLayoutConstraint(item: codeText, attribute: .CenterY, relatedBy: .Equal, toItem: placeholderView, attribute: .CenterY, multiplier: 1, constant: 0))
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
        codeText.textColor = colorScheme.mainAccent
        codeText.accessibilityLabel = localizedString("accessibility.verification.input");
        backButton.accessibilityLabel = localizedString("accessibility.button.title.back");
        placeholderLabel.textColor = colorScheme.placeholderText
        activityIndicator.color = colorScheme.mainAccent
        self.needsUpdateConstraints()
    }
    
    
    // TODO: need to provide fonts from Font factory, like as colors from ColorScheme
    private func applyCodeFieldStyle(input:NSAttributedString)->NSAttributedString {
        let attributedString:NSMutableAttributedString = NSMutableAttributedString(attributedString: input)
        let range:NSRange = NSMakeRange(0, attributedString.length)
        attributedString.addAttribute(NSKernAttributeName, value: 12, range: range)
        attributedString.addAttribute(NSFontAttributeName, value: UIFont(name: "Menlo-Bold", size: 22)!, range: range)
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
    
    func indicateVerificationSuccess(){
        activityIndicator.stopAnimating()
        statusImage.image = UIImage(namedInPhoneId: "icon-ok")
        statusImage.hidden = false

    }
    
    func reset(){
        codeText.text=""
        textFieldDidChange(codeText)
    }
    
    override func resignFirstResponder() -> Bool {
        return codeText.resignFirstResponder()
    }
    
    override func becomeFirstResponder() -> Bool {
        return codeText.becomeFirstResponder()
    }
    
}
