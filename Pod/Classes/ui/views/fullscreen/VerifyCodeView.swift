//
//  VerifyCodeView.swift
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

protocol VerifyCodeViewViewDelegate:NSObjectProtocol{
    func verifyCode(model:NumberInfo, code:String)
    func goBack()
    func close()
}

public class VerifyCodeView: PhoneIdBaseFullscreenView, UITextFieldDelegate{
    
    internal weak var delegate:VerifyCodeViewViewDelegate?
    private(set) var hintText: UITextView!
    private(set) var statusText: UITextView!
    private(set) var verifyCodeControl:VerifyCodeControl!
    
    override init(model:NumberInfo, scheme:ColorScheme, bundle:NSBundle, tableName:String){
        super.init(model: model, scheme:scheme, bundle:bundle, tableName:tableName)
    }
    
    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setupSubviews(){
        super.setupSubviews()
        
        hintText = UITextView()
        hintText.backgroundColor = UIColor.clearColor()
        hintText.editable = false
        hintText.scrollEnabled = false
        
        statusText = UITextView()
        statusText.editable = false
        statusText.scrollEnabled = false
        statusText.font = UIFont.systemFontOfSize(18)
        
        statusText.backgroundColor = UIColor.clearColor()
        
        setupVerificationCodeControl()
        
        let subviews:[UIView] = [verifyCodeControl, hintText, statusText]
        
        for(_, element) in subviews.enumerate(){
            element.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview(element)
        }
        
        
    }
    
    func setupVerificationCodeControl(){
        verifyCodeControl = VerifyCodeControl(model: phoneIdModel, scheme:colorScheme, bundle:localizationBundle, tableName:localizationTableName)
        
        verifyCodeControl.verificationCodeDidCahnge = { (code)->Void in
            
            if (code.utf16.count == self.verifyCodeControl.maxVerificationCodeLength) {
                
                self.statusText.attributedText = self.localizedStringAttributed("html-logging.in")
                
                if let delegate = self.delegate {
                    delegate.verifyCode(self.phoneIdModel, code:code)
                }
                
            } else {
                self.statusText.text = ""
                self.phoneIdService.abortCall()
            }
            
        }
        
        verifyCodeControl.backButtonTapped = { [weak self] in
            self?.verifyCodeControl.resignFirstResponder()
            if let delegate = self?.delegate{
                delegate.goBack()
            }
        }
    }
    
    override func setupLayout(){
        
        super.setupLayout()
        
        var c:[NSLayoutConstraint] = []
        
        c.append(NSLayoutConstraint(item: hintText, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1, constant: 0))
        c.append(NSLayoutConstraint(item: hintText, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1, constant: 20))
        c.append(NSLayoutConstraint(item: hintText, attribute: .Bottom, relatedBy: .Equal, toItem: verifyCodeControl, attribute: .Top, multiplier: 1, constant: 0))
        c.append(NSLayoutConstraint(item: hintText, attribute: .Width, relatedBy: .Equal, toItem: self, attribute: .Width, multiplier: 0.8, constant: 0))
        
        c.append(NSLayoutConstraint(item: verifyCodeControl, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1, constant: 0))
        c.append(NSLayoutConstraint(item: verifyCodeControl, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .Width, multiplier: 1, constant: 290))
        c.append(NSLayoutConstraint(item: verifyCodeControl, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .Height, multiplier: 1, constant: 50))
        
        c.append(NSLayoutConstraint(item: statusText, attribute: .Top, relatedBy: .Equal, toItem: verifyCodeControl, attribute: .Bottom, multiplier: 1, constant: 10))
        c.append(NSLayoutConstraint(item: statusText, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1, constant: 0))
        c.append(NSLayoutConstraint(item: statusText, attribute: .Width, relatedBy: .Equal, toItem: self, attribute: .Width, multiplier: 0.85, constant: 0))
        
        self.customConstraints += c
        
        self.addConstraints(c)
        
    }
    
    override func localizeAndApplyColorScheme(){
        
        super.localizeAndApplyColorScheme()
        hintText.attributedText = localizedStringAttributed("html-type.the.confirmation.code")
        statusText.textColor = colorScheme.normalText
        self.needsUpdateConstraints()
    }
    
    override func closeButtonTapped(){
        self.resignFirstResponder()
        self.delegate?.close()
    }
    
    override public func resignFirstResponder() -> Bool {
        return  self.verifyCodeControl.resignFirstResponder()
    }
    
    func indicateVerificationFail(){
        statusText.attributedText = localizedStringAttributed("html-loggin.failed")
        verifyCodeControl.indicateVerificationFail()
    }
    
    func indicateVerificationSuccess(completion:(()->Void)?){
        statusText.attributedText = localizedStringAttributed("html-logged.in")
        verifyCodeControl.indicateVerificationSuccess(completion)
    }
    
    
}