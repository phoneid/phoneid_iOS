//
//  NumberInputView.swift
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


import Foundation
import libPhoneNumber_iOS

protocol NumberInputViewDelegate:NSObjectProtocol{
    func numberInputCompleted(model: NumberInfo)
    func closeButtonTapped()
}

public class NumberInputView: PhoneIdBaseFullscreenView{
    
    private(set) var numberInputControl: NumberInputControl!
    private(set) var accessText: UITextView!

    private(set) var youNumberIsSafeText: UITextView!
    private(set) var termsText: UITextView!

    weak var delegate:NumberInputViewDelegate?

    override init(model:NumberInfo, scheme:ColorScheme, bundle:NSBundle, tableName:String){
        super.init(model: model, scheme:scheme, bundle:bundle, tableName:tableName)
    }
    
    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setupSubviews(){
        super.setupSubviews()
        
        accessText = UITextView()
        accessText.backgroundColor = UIColor.clearColor()
        accessText.editable = false
        accessText.scrollEnabled = false
    
        youNumberIsSafeText = UITextView()
        youNumberIsSafeText.editable = false
        youNumberIsSafeText.scrollEnabled = false
        youNumberIsSafeText.backgroundColor = UIColor.clearColor()
        
        termsText = UITextView()
        termsText.editable = false
        termsText.scrollEnabled = false
        termsText.hidden = true
        termsText.backgroundColor = UIColor.clearColor()
 
        numberInputControl = NumberInputControl(model: phoneIdModel, scheme:colorScheme, bundle:localizationBundle, tableName:localizationTableName)
        
        numberInputControl.numberDidChange = { [weak self] in
            self?.youNumberIsSafeText.hidden = true
            self?.termsText.hidden = false
        }
        
        numberInputControl.numberInputCompleted = {(numberInfo)-> Void in
            self.phoneIdModel = numberInfo
            self.delegate?.numberInputCompleted(self.phoneIdModel)
        }
        
        let subviews:[UIView] = [accessText, youNumberIsSafeText, termsText, numberInputControl]
        
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
        c.append(NSLayoutConstraint(item: accessText, attribute: .Bottom, relatedBy: .Equal, toItem: numberInputControl, attribute: .TopMargin, multiplier: 1, constant: 0))
        c.append(NSLayoutConstraint(item: accessText, attribute: .Width, relatedBy: .Equal, toItem: self, attribute: .Width, multiplier: 0.8, constant: 0))
        
        c.append(NSLayoutConstraint(item: numberInputControl, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1, constant: 0))
        c.append(NSLayoutConstraint(item: numberInputControl, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .Width, multiplier: 1, constant: 290))
        c.append(NSLayoutConstraint(item: numberInputControl, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .Height, multiplier: 1, constant: 50))
        
        c.append(NSLayoutConstraint(item: youNumberIsSafeText, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1, constant: 0))
        c.append(NSLayoutConstraint(item: youNumberIsSafeText, attribute: .Top, relatedBy: .Equal, toItem: numberInputControl, attribute: .Bottom, multiplier: 1, constant: 20))
        c.append(NSLayoutConstraint(item: youNumberIsSafeText, attribute: .Width, relatedBy: .Equal, toItem: numberInputControl, attribute: .Width, multiplier: 1, constant:0))
        
        c.append(NSLayoutConstraint(item: termsText, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1, constant: 0))
        c.append(NSLayoutConstraint(item: termsText, attribute: .Top, relatedBy: .Equal, toItem: numberInputControl, attribute: .Bottom, multiplier: 1, constant: 20))
        c.append(NSLayoutConstraint(item: termsText, attribute: .Width, relatedBy: .Equal, toItem: numberInputControl, attribute: .Width, multiplier: 1, constant:0))
        
        self.customConstraints += c
        
        self.addConstraints(c)
        
    }
    
    override func localizeAndApplyColorScheme(){
        
        super.localizeAndApplyColorScheme()
        
        accessText.attributedText = localizedStringAttributed("html-access.app.with.number") { (tmpResult) -> String in
            return String(format: tmpResult, self.phoneIdService.appName!)
        }

        youNumberIsSafeText.attributedText = localizedStringAttributed("html-your.number.is.safe")
        
        termsText.attributedText = localizedStringAttributed("html-label.terms.and.conditions") { (tmpResult) -> String in
            //TODO: replace terms and privacy policy with right refferences
            return String(format: tmpResult,"http://google.com", "http://yandex.ru" )
        }
        
        termsText.linkTextAttributes = [NSFontAttributeName: UIFont.systemFontOfSize(15),NSForegroundColorAttributeName:self.colorScheme.linkText]
        self.needsUpdateConstraints()
    }

    // MARK: Actions
        
    override func closeButtonTapped(){
        self.resignFirstResponder()
        self.delegate?.closeButtonTapped()
    }
    
    override public func resignFirstResponder() -> Bool {
        return self.numberInputControl.resignFirstResponder()
    }
    
    override public func becomeFirstResponder() -> Bool {
        return self.numberInputControl.becomeFirstResponder()
    }
    
}


