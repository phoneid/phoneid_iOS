//
//  NumberInputControl.swift
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
import libPhoneNumber_iOS

class NumberInputControl: PhoneIdBaseView {
    
    private(set) var numberText:NumericTextField!
    private(set) var doneBarButton:UIBarButtonItem!
    private(set) var countryCodeBarButton:UIBarButtonItem!
    
    private(set) var okButton:UIButton!
    private(set) var prefixButton:UIButton!
    
    private(set) var numberPlaceholderView: UIView!
    private(set) var activityIndicator:UIActivityIndicatorView!
    private var asYouTypeFomratter:NBAsYouTypeFormatter!
    
    var numberDidChange: (()-> Void)?
    var numberInputCompleted: ((NumberInfo)-> Void)?
    
    override init(model:NumberInfo, scheme:ColorScheme, bundle:NSBundle, tableName:String){
        super.init(model: model, scheme:scheme, bundle:bundle, tableName:tableName)
    }
    
    required internal init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setupSubviews(){
        
        
        numberText = NumericTextField(maxLength: 15)
        numberText.keyboardType = .NumberPad
        numberText.addTarget(self, action:"textFieldDidChange:", forControlEvents:.EditingChanged)
        numberText.backgroundColor = UIColor.clearColor()
        
        setupKeyboardToolBar();
        
        numberPlaceholderView = UIView()
        numberPlaceholderView.layer.cornerRadius = 5
        
        okButton = UIButton()
        okButton.hidden = true
        okButton.addTarget(self, action: "okButtonTapped:", forControlEvents: .TouchUpInside)
        
        prefixButton = UIButton()
        prefixButton.titleLabel?.textAlignment = .Left
        prefixButton.addTarget(self, action: "countryCodeTapped:", forControlEvents: .TouchUpInside)
        
        activityIndicator=UIActivityIndicatorView()
        activityIndicator.activityIndicatorViewStyle = .WhiteLarge
        
        
        let subviews:[UIView] = [numberPlaceholderView, numberText, okButton, prefixButton, activityIndicator]
        
        for(_, element) in subviews.enumerate(){
            element.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview(element)
        }
    }
    
    override func setupLayout(){
        
        var c:[NSLayoutConstraint] = []
        
        
        c.append(NSLayoutConstraint(item: numberPlaceholderView, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1, constant: 0))
        c.append(NSLayoutConstraint(item: numberPlaceholderView, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1, constant: 0))
        c.append(NSLayoutConstraint(item: numberPlaceholderView, attribute: .Width, relatedBy: .Equal, toItem: self, attribute: .Width, multiplier: 1, constant: 0))
        c.append(NSLayoutConstraint(item: numberPlaceholderView, attribute: .Height, relatedBy: .Equal, toItem: self, attribute: .Height, multiplier: 1, constant: 0))
        
        c.append(NSLayoutConstraint(item: numberText, attribute: .Left, relatedBy: .Equal, toItem: prefixButton, attribute: .Right, multiplier: 1, constant: 5))
        c.append(NSLayoutConstraint(item: numberText, attribute: .Right, relatedBy: .Equal, toItem: okButton, attribute: .Left, multiplier: 1, constant: 0))
        c.append(NSLayoutConstraint(item: numberText, attribute: .CenterY, relatedBy: .Equal, toItem: numberPlaceholderView, attribute: .CenterY, multiplier: 1, constant: 0))
        
        c.append(NSLayoutConstraint(item: prefixButton, attribute: .Left, relatedBy: .Equal, toItem: numberPlaceholderView, attribute: .Left, multiplier: 1, constant: 2))
        c.append(NSLayoutConstraint(item: prefixButton, attribute: .Baseline, relatedBy: .Equal, toItem: numberText, attribute: .Baseline, multiplier: 1, constant: 0))
        c.append(NSLayoutConstraint(item: prefixButton, attribute: .Width, relatedBy: .Equal, toItem: self, attribute: .Height, multiplier: 1, constant:0))
        
        c.append(NSLayoutConstraint(item: okButton, attribute: .CenterX, relatedBy: .Equal, toItem: activityIndicator, attribute: .CenterX, multiplier: 1, constant: 0))
        c.append(NSLayoutConstraint(item: okButton, attribute: .CenterY, relatedBy: .Equal, toItem: activityIndicator, attribute: .CenterY, multiplier: 1, constant: 0))
        
        c.append(NSLayoutConstraint(item: activityIndicator, attribute: .CenterY, relatedBy: .Equal, toItem: numberPlaceholderView, attribute: .CenterY, multiplier: 1, constant:0))
        c.append(NSLayoutConstraint(item: activityIndicator, attribute: .Right, relatedBy: .Equal, toItem: numberPlaceholderView, attribute: .Right, multiplier: 1, constant:-5))
        
        self.addConstraints(c)
        
    }
    
    private func setupKeyboardToolBar(){
        let toolBar = UIToolbar(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, 44))
        
        countryCodeBarButton  = UIBarButtonItem(title: nil, style: .Plain, target: self, action: "countryCodeTapped:")
        doneBarButton = UIBarButtonItem(title: nil, style: .Plain, target: self, action: "okButtonTapped:")
        
        let space = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
        
        toolBar.items = [countryCodeBarButton, space, doneBarButton]
        
        numberText.inputAccessoryView = toolBar
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
        self.validatePhoneNumber()
    }
    
    override func localizeAndApplyColorScheme(){
        
        super.localizeAndApplyColorScheme()
        
        okButton.setTitle(localizedString("button.title.ok"), forState: .Normal)
        okButton.accessibilityLabel = localizedString("accessibility.button.title.ok")
        
        
        numberText.attributedPlaceholder = localizedStringAttributed("html-placeholder.phone.number")
        numberText.accessibilityLabel = localizedString("accessibility.phone.number.input")
        
        countryCodeBarButton.title = localizedString("button.title.change.country.code")
        countryCodeBarButton.accessibilityLabel = localizedString("accessibility.button.title.change.country.code")
        
        prefixButton.accessibilityLabel = localizedString("accessibility.button.title.change.country.code")
        
        doneBarButton.title = localizedString("button.title.done.keyboard")
        doneBarButton.accessibilityLabel = localizedString("accessibility.button.title.done.keyboard")
        
        numberPlaceholderView.backgroundColor = colorScheme.inputNumberBackground
        
        prefixButton.setTitleColor(colorScheme.inputPrefixText, forState: .Normal)
        
        numberText.textColor = colorScheme.inputNumberText
        
        okButton.setTitleColor(colorScheme.buttonOKNormalText, forState: .Normal)
        okButton.setTitleColor(colorScheme.buttonOKDisabledText, forState: .Disabled)
        
        activityIndicator.color = colorScheme.activityIndicatorNumber
        self.needsUpdateConstraints()
    }
    
    func validatePhoneNumber() {
        activityIndicator.stopAnimating()
        
        numberText.text = asYouTypeFomratter.inputString(numberText.text)
        okButton.hidden = numberText.text!.isEmpty
        
        if (phoneIdModel.isValidNumber(numberText.text!)) {
            numberText.text = phoneIdModel.formatNumber(numberText.text!) as String
            okButton.enabled = true
            doneBarButton.enabled = true
        } else {
            okButton.enabled = false
            doneBarButton.enabled = false
        }
    }
    
    func reset(){
        numberText.text=""
        validatePhoneNumber()
    }
    
    override func resignFirstResponder() -> Bool {
        return self.numberText.resignFirstResponder()
    }
    
    override func becomeFirstResponder() -> Bool {
        return self.numberText.becomeFirstResponder()
    }
    
    func textFieldDidChange(textField:UITextField) {
        numberDidChange?()
        validatePhoneNumber()
    }
    
    func okButtonTapped(sender:UIButton){
        self.phoneIdModel.phoneNumber = self.numberText.text
        
        okButton.hidden = true
        activityIndicator.startAnimating()
        numberInputCompleted?(self.phoneIdModel)
        
    }
    
    func countryCodeTapped(sender:UIButton){
        self.phoneIdModel.phoneNumber = self.numberText.text
        
        let controller = self.phoneIdComponentFactory.countryCodePickerViewController(self.phoneIdModel)
        
        controller.countryCodePickerCompletionBlock = { [unowned self] (model:NumberInfo)-> Void in
            self.phoneIdModel = model
            self.setupWithModel(model)
            self.becomeFirstResponder()
        }
        
        let presenter:UIViewController = PhoneIdWindow.currentPresenter()
        
        presenter.presentViewController(controller, animated: true){
            self.resignFirstResponder()
        }
        
    }
}
