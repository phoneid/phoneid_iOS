//
//  VerifyCodeViewController.swift
//  PhoneIdSDK
//
//  Created by Alyona on 7/2/15.
//  Copyright © 2015 phoneId. All rights reserved.
//

import Foundation

public typealias VerifyCodeCompletionBlock = (()->Void)

public class VerifyCodeViewController: UIViewController, PhoneIdConsumer, VerifyCodeViewViewDelegate{
    public var phoneIdModel:NumberInfo!

    public var verifyCodeViewCompletionBlock:VerifyCodeCompletionBlock?
    
    private var verifyCodeView:VerifyCodeView!
        {
        get {
            let result = self.view as? VerifyCodeView
            if(result == nil){
                fatalError("self.view expected to be kind of VerifyCodeView")
            }
            return result
        }
    }
    
    public init(model: NumberInfo){
        super.init(nibName: nil, bundle: nil)
        self.phoneIdModel = model
    }
    
    required public init(coder aDecoder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    public override func loadView() {
        let result = phoneIdComponentFactory.verifyCodeView(self.phoneIdModel)
        result.delegate = self
        self.view = result
    }
    
    public override func viewDidAppear(animated: Bool) {
        
        super.viewDidAppear(animated)
        verifyCodeView.codeText.becomeFirstResponder()
    }
    
    // MARK: CountryCodePickerViewDelegate
    
    public func goBack() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    public func verifyCode(model:NumberInfo, code:String){
        phoneIdService.verifyAuthentication(code, info: model){ (token, error) -> Void in
            if(error == nil){
                self.verifyCodeView.indicateVerificationSuccess()
                if let completion = self.verifyCodeViewCompletionBlock{
                    completion()
                    
                    self.dismissViewControllerAnimated(true, completion: nil)
  
                }
            }else{
               self.verifyCodeView.indicateVerificationFail()
            }
            
        }
    }

}