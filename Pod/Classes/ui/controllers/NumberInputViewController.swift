//
//  NumberInputViewController.swift
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


public class NumberInputViewController: UIViewController, PhoneIdConsumer, NumberInputViewDelegate {
    
    public var phoneIdModel:NumberInfo!
    
    private var numberInputView:NumberInputView!
        {
        get {
            let result = self.view as? NumberInputView
            if(result == nil){
                fatalError("self.view expected to be kind of NumberInputView")
            }
            return result
        }
    }
    
    public init(){
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init(coder aDecoder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    public override func loadView() {
        let result = phoneIdComponentFactory.numberInputView(NumberInfo())
        result.delegate = self
        self.view = result
    }
    
    override public func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.numberInputView.numberInputControl.validatePhoneNumber()
                
        if(!phoneIdService.isLoggedIn){
            self.numberInputView.becomeFirstResponder()
        }
    }
    
    
    func finishPhoneIdWorkflow(success:Bool){

        self.dismissViewControllerAnimated(false, completion: nil)
        PhoneIdWindow.activePhoneIdWindow()?.close()
        self.callPhoneIdCompletion(success)
    }
    
    func callPhoneIdCompletion(success:Bool){
        if(success){
            print("PhoneId login finished")
            self.phoneIdService.phoneIdAuthenticationSucceed?(token: self.phoneIdService.token!)
        }else{
            print("PhoneId login cancelled")
            self.phoneIdService.phoneIdAuthenticationCancelled?()
        }
    }
    
    // MARK: NumberInputViewDelegate
    
    func numberInputCompleted(model: NumberInfo){
        self.phoneIdModel = model
        phoneIdService.requestAuthenticationCode(phoneIdModel, completion: {(error) -> Void in
            
            if(error == nil){
                let controller = self.phoneIdComponentFactory.verifyCodeViewController(model)
                controller.verifyCodeViewCompletionBlock = { [unowned self] (success:Bool)-> Void in
                    self.finishPhoneIdWorkflow(success)
                }
                self.presentViewController(controller, animated: true, completion: nil)
            }else{
                let bundle = self.phoneIdService.componentFactory.localizationBundle()
                let alert = UIAlertController(title: NSLocalizedString("alert.title.error", bundle: bundle, comment:"Error"), message: "\(error!.localizedDescription)", preferredStyle: UIAlertControllerStyle.Alert)
                
                alert.addAction(UIAlertAction(title: NSLocalizedString("alert.button.title.dismiss", bundle: bundle, comment:"Dismiss"), style: .Cancel, handler:nil))
                
                self.presentViewController(alert, animated: true, completion: nil)
            }
            });
    }
    
    func closeButtonTapped() {
        self.numberInputView.resignFirstResponder()
        self.dismissViewControllerAnimated(true, completion: nil)        
        self.callPhoneIdCompletion(false)
        PhoneIdWindow.activePhoneIdWindow()?.close()
    }
}



