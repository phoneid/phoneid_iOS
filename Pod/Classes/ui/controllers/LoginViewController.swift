//
//  LoginViewController.swift
//  Pods
//
//  Created by Alyona on 10/3/15.
//
//

import UIKit

public class LoginViewController: UIViewController, PhoneIdConsumer, LoginViewDelegate {

    private var loginView:LoginView!
        {
        get {
            let result = self.view as? LoginView
            if(result == nil){
                fatalError("self.view expected to be kind of NumberInputView")
            }
            return result
        }
    }
    
    lazy private var phoneIdModel:NumberInfo = {
        let result = NumberInfo()
        return result
    }()
    
    public init(){
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init(coder aDecoder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    public override func loadView() {
        let result = phoneIdComponentFactory.loginView(self.phoneIdModel)
        result.loginViewDelegate = self
      
        self.view = result
        self.loginView.switchToState(.NumberInput)
    }
    
    public func numberInputCompleted(model: NumberInfo){
        self.phoneIdModel = model
        phoneIdService.requestAuthenticationCode(phoneIdModel, completion: {(error) -> Void in
            
            if(error == nil){
                self.loginView.switchToState(.CodeVerification)
            }else{
                let bundle = self.phoneIdService.componentFactory.localizationBundle()
                let alert = UIAlertController(title: NSLocalizedString("alert.title.error", bundle: bundle, comment:"Error"), message: "\(error!.localizedDescription)", preferredStyle: UIAlertControllerStyle.Alert)
                
                alert.addAction(UIAlertAction(title: NSLocalizedString("alert.button.title.dismiss", bundle: bundle, comment:"Dismiss"), style: .Cancel, handler:nil))
                
                self.presentViewController(alert, animated: false, completion: nil)
            }
        });
    }
    
    public func goBack() {
        self.loginView.switchToState(.NumberInput)
    }
    
    public func verifyCode(model:NumberInfo, code:String){
        phoneIdService.verifyAuthentication(code, info: model){[unowned self] (token, error) -> Void in
            
            if(error == nil){
                self.loginView.switchToState(.CodeVerificationSuccess){
                    self.callPhoneIdCompletion(true)
                    self.dismissViewControllerAnimated(true, completion: nil)
                    PhoneIdWindow.activePhoneIdWindow()?.close()
                }
                
            }else{
                self.loginView.switchToState(.CodeVerificationFail)
            }
            
        }
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

    
    public func close() {
        self.loginView.resignFirstResponder()
        self.dismissViewControllerAnimated(true, completion: nil)
        self.callPhoneIdCompletion(false)
        PhoneIdWindow.activePhoneIdWindow()?.close()
    }
}
