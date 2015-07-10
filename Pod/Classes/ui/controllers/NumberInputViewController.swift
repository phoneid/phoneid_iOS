//
//  NumberInputViewController.swift
//  PhoneIdSDK
//
//  Created by Alyona on 7/1/15.
//  Copyright © 2015 phoneId. All rights reserved.
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
        self.numberInputView.validatePhoneNumber()
    }
    
    // MARK: NumberInputViewDelegate
    func phoneNumberWasAccepted(model: NumberInfo){
        self.phoneIdModel = model
        phoneIdService.requestAuthenticationCode(phoneIdModel, completion: { [unowned self] (error) -> Void in
            
            if(error == nil){
                let controller = self.phoneIdComponentFactory.verifyCodeViewController(model)
                controller.verifyCodeViewCompletionBlock = { (success:Bool)-> Void in
                    self.finishPhoneIdWorkflow(success)
                }
                self.presentViewController(controller, animated: true, completion: nil)
            }else{
                let bundle = self.phoneIdService.componentFactory.localizationBundle()
                let alert = UIAlertController(title: NSLocalizedString("message.title.error", bundle: bundle, comment:"Error"), message: "\(error!.localizedDescription)", preferredStyle: UIAlertControllerStyle.Alert)
                
                alert.addAction(UIAlertAction(title: NSLocalizedString("button.title.dismiss", bundle: bundle, comment:"Dismiss"), style: .Cancel, handler:nil))
                
                self.presentViewController(alert, animated: true, completion: nil)
            }
            });
    }
    
    func countryCodePickerTapped(model: NumberInfo){
        
        self.phoneIdModel = model
        let controller = self.phoneIdComponentFactory.countryCodePickerViewController(model)
        
        controller.countryCodePickerCompletionBlock = { [unowned self] (model:NumberInfo)-> Void in
            
            self.phoneIdModel = model
            self.numberInputView.setupWithModel(model)
            
        }
        self.presentViewController(controller, animated: true, completion: nil)
    }
    
    func finishPhoneIdWorkflow(success:Bool){
        
        self.dismissWithCompletion { () -> Void in
            
            if(success){
                print("PhoneId login finished")
                self.phoneIdService.phoneIdAuthenticationSucceed?(token: self.phoneIdService.token!)
            }else{
                print("PhoneId login cancelled")
                self.phoneIdService.phoneIdAuthenticationCancelled?()
            }
        
        }
    }
    
    func close() {
        self.finishPhoneIdWorkflow(false)
    }
}



