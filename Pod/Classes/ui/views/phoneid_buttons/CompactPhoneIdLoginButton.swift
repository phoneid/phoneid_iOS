//
//  CompactPhoneIdLoginButton.swift
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

@IBDesignable public class CompactPhoneIdLoginButton: PhoneIdLoginButton{
    
    private(set) var numberInputControl: NumberInputControl!
    private(set) var verifyCodeControl:VerifyCodeControl!
    var phoneIdModel:NumberInfo!
    
    override func initUI(){
        super.initUI()
        
        phoneIdModel = NumberInfo()
        
        setupNumberInputControl()
        setupVerificationCodeControl()
        
        let subviews = [numberInputControl, verifyCodeControl]
        
        for subview in subviews {
            subview.translatesAutoresizingMaskIntoConstraints = false
            addSubview(subview)
            addConstraint(NSLayoutConstraint(item: subview, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1, constant:0))
            addConstraint(NSLayoutConstraint(item: subview, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1, constant:0))
            addConstraint(NSLayoutConstraint(item: subview, attribute: .Width, relatedBy: .Equal, toItem: self, attribute: .Width, multiplier: 1, constant:0))
            addConstraint(NSLayoutConstraint(item: subview, attribute: .Height, relatedBy: .Equal, toItem: self, attribute: .Height, multiplier: 1, constant:0))
            subview.hidden = true
        }
        
    }
    
    override func configureButton(isLoggedIn:Bool){
        
        super.configureButton(isLoggedIn)
        
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
        
    }
    
    func setupNumberInputControl() {
        
        numberInputControl = NumberInputControl(model: phoneIdModel, scheme:colorScheme, bundle:localizationBundle, tableName:localizationTableName)
        
        numberInputControl.numberInputCompleted = {(numberInfo)-> Void in
            self.phoneIdModel = numberInfo
            self.verifyCodeControl.phoneIdModel = numberInfo
            self.requestAuthentication()
        }
        
    }
    
    func setupVerificationCodeControl() {
        
        verifyCodeControl = VerifyCodeControl(model: phoneIdModel, scheme: colorScheme, bundle: localizationBundle, tableName:self.localizationTableName)
        
        verifyCodeControl.verificationCodeDidCahnge = { (code)->Void in
            
            if (code.utf16.count == self.verifyCodeControl.maxVerificationCodeLength) {
                
                self.phoneIdService.verifyAuthentication(code, info: self.phoneIdModel){ (token, error) -> Void in
                    
                    if(error == nil){
                        self.verifyCodeControl.indicateVerificationSuccess()
                        print("PhoneId login finished")
                        self.phoneIdService.phoneIdAuthenticationSucceed?(token: self.phoneIdService.token!)
                    }else{
                        print("PhoneId login cancelled")
                        self.verifyCodeControl.indicateVerificationFail()
                    }
                    
                }
                
            } else {
                self.phoneIdService.abortCall()
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
    }
    
    override func loginTouched() {
        
        numberInputControl.hidden = false
        numberInputControl.becomeFirstResponder()
        
    }
    
    func requestAuthentication(){
        
        phoneIdService.requestAuthenticationCode(self.phoneIdModel, completion: { [unowned self] (error) -> Void in
            
            if(error == nil){
                
                self.numberInputControl.hidden = true
                
                self.verifyCodeControl.hidden = false
                self.verifyCodeControl.becomeFirstResponder()
                
            }else{
                let bundle = self.phoneIdService.componentFactory.localizationBundle()
                let alert = UIAlertController(title: NSLocalizedString("alert.title.error", bundle: bundle, comment:"Error"), message: "\(error!.localizedDescription)", preferredStyle: UIAlertControllerStyle.Alert)
                
                alert.addAction(UIAlertAction(title: NSLocalizedString("alert.button.title.dismiss", bundle: bundle, comment:"Dismiss"), style: .Cancel, handler:nil))
                
                let presenter:UIViewController = PhoneIdWindow.currentPresenter()
                presenter.presentViewController(alert, animated: true, completion: nil)
            }
            });
    }
    
    
}
