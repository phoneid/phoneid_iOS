//
//  VerifyCodeViewController.swift
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

public typealias VerifyCodeCompletionBlock = ((success:Bool)->Void)

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
        verifyCodeView.verifyCodeControl.becomeFirstResponder()
    }
    
    // MARK: CountryCodePickerViewDelegate
    
    func goBack() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func verifyCode(model:NumberInfo, code:String){
        phoneIdService.verifyAuthentication(code, info: model){[unowned self] (token, error) -> Void in
            
            if(error == nil){                
                self.verifyCodeView.indicateVerificationSuccess()
                self.verifyCodeViewCompletionBlock?(success: true)
                self.dismissViewControllerAnimated(true, completion: nil)
                PhoneIdWindow.activePhoneIdWindow()?.close()

            }else{
               self.verifyCodeView.indicateVerificationFail()
            }
            
        }
    }
    
    func close() {
        self.verifyCodeView.resignFirstResponder()
        self.dismissViewControllerAnimated(false, completion: nil)
        self.verifyCodeViewCompletionBlock?(success: false)
    }

}




