//
//  VerifyCodeView.swift
//  PhoneIdSDK
//
//  Created by Alyona on 7/2/15.
//  Copyright © 2015 phoneId. All rights reserved.
//

import Foundation

public protocol VerifyCodeViewViewDelegate:NSObjectProtocol{
    func verifyCode(model:NumberInfo, code:String)
    func goBack()
}

public class VerifyCodeView: PhoneIdBaseView, UITextFieldDelegate{
    
    internal weak var delegate:VerifyCodeViewViewDelegate?
    
    public private(set) var placeholderView:UIView!
    public private(set) var codeText:NumericTextField!
    public private(set) var placeholderLabel:UILabel!
    public private(set) var activityIndicator:UIActivityIndicatorView!
    public private(set) var backButton:UIButton!
    public private(set) var statusImage: UIImageView!
    
    public private(set) var hintText: UITextView!
    public private(set) var statusText: UITextView!
    
    let verificationCodeLength = 6
    
    public override init(model:NumberInfo, scheme:ColorScheme, bundle:NSBundle, tableName:String){
        super.init(model: model, scheme:scheme, bundle:bundle, tableName:tableName)
    }
    
    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setupSubviews(){
        super.setupSubviews()
        
        codeText = NumericTextField(maxLength: verificationCodeLength)
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

        hintText = UITextView()
        hintText.backgroundColor = UIColor.clearColor()
        hintText.editable = false
        hintText.scrollEnabled = false

        statusText = UITextView()
        statusText.editable = false
        statusText.scrollEnabled = false
        statusText.font = UIFont.systemFontOfSize(18)
   
        statusText.backgroundColor = UIColor.clearColor()

        let subviews:[UIView] = [placeholderView, placeholderLabel, codeText]+[activityIndicator, backButton, statusImage, hintText, statusText]
        
        for(_, element) in subviews.enumerate(){
            element.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview(element)
        }
                
    }
    
    override func setupLayout(){
        
        super.setupLayout()
        
        var c:[NSLayoutConstraint] = []
        
        c.append(NSLayoutConstraint(item: hintText, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1, constant: 0))
        c.append(NSLayoutConstraint(item: hintText, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1, constant: 20))
        c.append(NSLayoutConstraint(item: hintText, attribute: .Bottom, relatedBy: .Equal, toItem: placeholderView, attribute: .Top, multiplier: 1, constant: 0))
        c.append(NSLayoutConstraint(item: hintText, attribute: .Width, relatedBy: .Equal, toItem: self, attribute: .Width, multiplier: 0.8, constant: 0))
        
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
        
        c.append(NSLayoutConstraint(item: statusText, attribute: .Top, relatedBy: .Equal, toItem: placeholderView, attribute: .Bottom, multiplier: 1, constant: 10))
        c.append(NSLayoutConstraint(item: statusText, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1, constant: 0))
        c.append(NSLayoutConstraint(item: statusText, attribute: .Width, relatedBy: .Equal, toItem: self, attribute: .Width, multiplier: 0.85, constant: 0))
        
        self.customContraints += c
        
        self.addConstraints(c)
        
    }
    
    override func localizeAndApplyColorScheme(){
        
        super.localizeAndApplyColorScheme()
        
        hintText.attributedText = localizedStringAttributed("html-type.the.confirmation.code")
        placeholderView.backgroundColor = colorScheme.defaultTextInputBackground
        statusText.textColor = colorScheme.normalText
        codeText.textColor = colorScheme.mainAccent
        placeholderLabel.textColor = colorScheme.placeholderText
        activityIndicator.color = colorScheme.mainAccent
        self.needsUpdateConstraints()
    }
    
    func backTapped(sender:UIButton){
        self.codeText.resignFirstResponder()
        if let delegate = delegate{
            delegate.goBack()
        }
    }
    
    func textFieldDidChange(textField:UITextField) {

        textField.attributedText = applyCodeFieldStyle(textField.attributedText!)
        
        if (textField.text!.utf16.count == verificationCodeLength) {
            
            statusText.attributedText = localizedStringAttributed("logging.in")
            activityIndicator.startAnimating()
            backButton.enabled = false
            if let delegate = delegate {
                delegate.verifyCode(self.phoneIdModel, code:textField.text!)
            }
            
        } else {
            statusText.text = ""
            activityIndicator.stopAnimating()
            phoneIdService.abortCall()
            statusImage.hidden = true
            backButton.enabled = true
        }
        
    }
    
    // TODO: need to provide fonts from Font factory, like as colors from ColorScheme 
    func applyCodeFieldStyle(input:NSAttributedString)->NSAttributedString {
        let attributedString:NSMutableAttributedString = NSMutableAttributedString(attributedString: input)
        let range:NSRange = NSMakeRange(0, attributedString.length)
        attributedString.addAttribute(NSKernAttributeName, value: 12, range: range)
        attributedString.addAttribute(NSFontAttributeName, value: UIFont(name: "Menlo-Bold", size: 22)!, range: range)
        return attributedString
    }
    
    public func indicateVerificationFail(){
        activityIndicator.stopAnimating()
        statusImage.image = UIImage(namedInPhoneId: "icon-ko")
        statusImage.hidden = false
        statusText.attributedText = localizedStringAttributed("loggin.failed")
        backButton.enabled = true
    }
    
    public func indicateVerificationSuccess(){
        statusText.attributedText = localizedStringAttributed("logged.in")
        activityIndicator.stopAnimating()
        statusImage.image = UIImage(namedInPhoneId: "icon-ok")
        statusImage.hidden = false
    }
    
}