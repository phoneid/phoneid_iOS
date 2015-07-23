//
//  NumberInputView.swift
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


import Foundation
import libPhoneNumber_iOS

protocol NumberInputViewDelegate:NSObjectProtocol{
    func phoneNumberWasAccepted(model: NumberInfo)
    func countryCodePickerTapped(model: NumberInfo)
    func close()
}

public class NumberInputView: PhoneIdBaseView{
    
    private(set) var numberText:NumericTextField!
    private(set) var accessText: UITextView!
    private(set) var okButton:UIButton!
    private(set) var prefixButton:UIButton!
    private(set) var youNumberIsSafeText: UITextView!
    private(set) var termsText: UITextView!
    private(set) var numberPlaceholderView: UIView!
    private(set) var activityIndicator:UIActivityIndicatorView!
    private var asYouTypeFomratter:NBAsYouTypeFormatter!
    
    weak var delegate:NumberInputViewDelegate?

    override init(model:NumberInfo, scheme:ColorScheme, bundle:NSBundle, tableName:String){
        super.init(model: model, scheme:scheme, bundle:bundle, tableName:tableName)
    }
    
    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setupSubviews(){
        super.setupSubviews()

        numberText = NumericTextField(maxLength: 15)
        numberText.keyboardType = .NumberPad
        numberText.addTarget(self, action:"textFieldDidChange:", forControlEvents:.EditingChanged)
        numberText.backgroundColor = UIColor.clearColor()
        numberText.becomeFirstResponder()
        
        numberPlaceholderView = UIView()
        numberPlaceholderView.layer.cornerRadius = 5
        
        accessText = UITextView()
        accessText.backgroundColor = UIColor.clearColor()
        accessText.editable = false
        accessText.scrollEnabled = false
        
        okButton = UIButton()
        okButton.hidden = true
        okButton.addTarget(self, action: "okButtonTapped:", forControlEvents: .TouchUpInside)
        
        prefixButton = UIButton()
        prefixButton.titleLabel?.textAlignment = .Left
        prefixButton.addTarget(self, action: "countryCodeTapped:", forControlEvents: .TouchUpInside)
        
        youNumberIsSafeText = UITextView()
        youNumberIsSafeText.editable = false
        youNumberIsSafeText.scrollEnabled = false
        youNumberIsSafeText.backgroundColor = UIColor.clearColor()
        
        termsText = UITextView()
        termsText.editable = false
        termsText.scrollEnabled = false
        termsText.hidden = true
        termsText.backgroundColor = UIColor.clearColor()
        
        activityIndicator=UIActivityIndicatorView()
        activityIndicator.activityIndicatorViewStyle = .WhiteLarge
        
        
        let subviews:[UIView] = [numberPlaceholderView, accessText,numberText, okButton, prefixButton , youNumberIsSafeText, termsText,activityIndicator]
        
        for(_, element) in subviews.enumerate(){
            element.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview(element)
        }
        
        
    }
    
    override func setupLayout(){
        
        super.setupLayout()
        
        var c:[NSLayoutConstraint] = []
        
        c.append(NSLayoutConstraint(item: accessText, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1, constant: 0))
        c.append(NSLayoutConstraint(item: accessText, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1, constant: 20))
        c.append(NSLayoutConstraint(item: accessText, attribute: .Bottom, relatedBy: .Equal, toItem: numberPlaceholderView, attribute: .TopMargin, multiplier: 1, constant: 0))
        c.append(NSLayoutConstraint(item: accessText, attribute: .Width, relatedBy: .Equal, toItem: self, attribute: .Width, multiplier: 0.8, constant: 0))
        
        c.append(NSLayoutConstraint(item: numberPlaceholderView, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1, constant: 0))
        c.append(NSLayoutConstraint(item: numberPlaceholderView, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .Width, multiplier: 1, constant: 290))
        c.append(NSLayoutConstraint(item: numberPlaceholderView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .Height, multiplier: 1, constant: 50))
        
        c.append(NSLayoutConstraint(item: numberText, attribute: .Left, relatedBy: .Equal, toItem: prefixButton, attribute: .Right, multiplier: 1, constant: 5))
        c.append(NSLayoutConstraint(item: numberText, attribute: .Right, relatedBy: .Equal, toItem: okButton, attribute: .Left, multiplier: 1, constant: 0))
        c.append(NSLayoutConstraint(item: numberText, attribute: .CenterY, relatedBy: .Equal, toItem: numberPlaceholderView, attribute: .CenterY, multiplier: 1, constant: 0))
        
        c.append(NSLayoutConstraint(item: prefixButton, attribute: .Left, relatedBy: .Equal, toItem: numberPlaceholderView, attribute: .Left, multiplier: 1, constant: 2))
        c.append(NSLayoutConstraint(item: prefixButton, attribute: .Baseline, relatedBy: .Equal, toItem: numberText, attribute: .Baseline, multiplier: 1, constant: 0))
        c.append(NSLayoutConstraint(item: prefixButton, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .Width, multiplier: 1, constant:50))
        
        c.append(NSLayoutConstraint(item: okButton, attribute: .Right, relatedBy: .Equal, toItem: numberPlaceholderView, attribute: .Right, multiplier: 1, constant: -10))
        c.append(NSLayoutConstraint(item: okButton, attribute: .Baseline, relatedBy: .Equal, toItem: numberText, attribute: .Baseline, multiplier: 1, constant: 0))
        c.append(NSLayoutConstraint(item: okButton, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .Width, multiplier: 1, constant:40))
        
        c.append(NSLayoutConstraint(item: youNumberIsSafeText, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1, constant: 0))
        c.append(NSLayoutConstraint(item: youNumberIsSafeText, attribute: .Top, relatedBy: .Equal, toItem: numberPlaceholderView, attribute: .Bottom, multiplier: 1, constant: 20))
        c.append(NSLayoutConstraint(item: youNumberIsSafeText, attribute: .Width, relatedBy: .Equal, toItem: numberPlaceholderView, attribute: .Width, multiplier: 1, constant:0))
        
        c.append(NSLayoutConstraint(item: termsText, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1, constant: 0))
        c.append(NSLayoutConstraint(item: termsText, attribute: .Top, relatedBy: .Equal, toItem: numberPlaceholderView, attribute: .Bottom, multiplier: 1, constant: 20))
        c.append(NSLayoutConstraint(item: termsText, attribute: .Width, relatedBy: .Equal, toItem: numberPlaceholderView, attribute: .Width, multiplier: 1, constant:0))
        
        c.append(NSLayoutConstraint(item: activityIndicator, attribute: .CenterY, relatedBy: .Equal, toItem: okButton, attribute: .CenterY, multiplier: 1, constant:0))
        c.append(NSLayoutConstraint(item: activityIndicator, attribute: .CenterX, relatedBy: .Equal, toItem: okButton, attribute: .CenterX, multiplier: 1, constant:-5))
        
        self.customConstraints += c
        
        self.addConstraints(c)
        
    }
    
    override func setupWithModel(model:NumberInfo){
        super.setupWithModel(model)
        
        if let isoCountryCode = phoneIdModel.isoCountryCode{
            asYouTypeFomratter = NBAsYouTypeFormatter(regionCode: isoCountryCode)
        }else{
            asYouTypeFomratter = NBAsYouTypeFormatter(regionCode: phoneIdModel.defaultIsoCountryCode)
        }
        
        if let phoneNumberString = phoneIdModel.phoneNumber{
            numberText.text = asYouTypeFomratter.inputString(phoneNumberString);
        }
        
        if let phoneCountryCodeString = phoneIdModel.phoneCountryCode{
            prefixButton.setTitle(phoneCountryCodeString, forState: UIControlState.Normal)
        }else{
            phoneIdModel.phoneCountryCode = phoneIdModel.defaultCountryCode
            phoneIdModel.isoCountryCode = phoneIdModel.defaultIsoCountryCode
            prefixButton.setTitle(phoneIdModel.defaultCountryCode, forState: UIControlState.Normal)
        }
    }
    
    
    override func localizeAndApplyColorScheme(){
        
        super.localizeAndApplyColorScheme()
        
        accessText.attributedText = localizedStringAttributed("html-access.app.with.number") { (tmpResult) -> String in
            return String(format: tmpResult, self.phoneIdService.appName!)
        }
        
        okButton.setTitle(localizedString("button.title.ok"), forState: .Normal)
        okButton.accessibilityLabel = localizedString("accessibility.button.title.ok")
            
        
        numberText.attributedPlaceholder = localizedStringAttributed("html-placeholder.phone.number")
        numberText.accessibilityLabel = localizedString("accessibility.phone.number.input")
        
        youNumberIsSafeText.attributedText = localizedStringAttributed("html-your.number.is.safe")
        
        termsText.attributedText = localizedStringAttributed("html-label.terms.and.conditions") { (tmpResult) -> String in
            //TODO: replace terms and privacy policy with right refferences
            return String(format: tmpResult,"http://google.com", "http://yandex.ru" )
        }
        
        termsText.linkTextAttributes = [NSFontAttributeName: UIFont.systemFontOfSize(15),NSForegroundColorAttributeName:self.colorScheme.linkText]
        
        numberPlaceholderView.backgroundColor = colorScheme.defaultTextInputBackground
        
        prefixButton.setTitleColor(colorScheme.mainAccent, forState: .Normal)
        
        numberText.textColor = colorScheme.mainAccent
        
        okButton.setTitleColor(colorScheme.mainAccent, forState: .Normal)
        okButton.setTitleColor(colorScheme.disabledText, forState: .Disabled)
        
        activityIndicator.color = colorScheme.mainAccent
        self.needsUpdateConstraints()
    }
    
    // MARK: text field changes
    
    func textFieldDidChange(textField:UITextField) {
        youNumberIsSafeText.hidden = true
        termsText.hidden = false
        
        validatePhoneNumber()
    }
    
    func validatePhoneNumber() {
        activityIndicator.stopAnimating()
    
        numberText.text = asYouTypeFomratter.inputString(numberText.text)
        okButton.hidden = numberText.text!.isEmpty
        
        if (phoneIdModel.isValidNumber(numberText.text!)) {
            numberText.text = phoneIdModel.formatNumber(numberText.text!) as String
            okButton.enabled = true
        } else {
            okButton.enabled = false
        }
    }
    
    // MARK: Actions
    
    func okButtonTapped(sender:UIButton){
        self.phoneIdModel.phoneNumber = self.numberText.text
        
        if let delegate = delegate {
            okButton.hidden = true
            activityIndicator.startAnimating()
            delegate.phoneNumberWasAccepted(self.phoneIdModel)
        }
    }
    
    func countryCodeTapped(sender:UIButton){
        self.phoneIdModel.phoneNumber = self.numberText.text
        
        if let delegate = delegate {
            delegate.countryCodePickerTapped(self.phoneIdModel)
        }
    }
    
    override func closeButtonTapped(){
        self.delegate?.close()
    }
    
}


