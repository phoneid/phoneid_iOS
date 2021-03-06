//
//  PhoneIdLoginWorkflowManager.swift
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


open class PhoneIdLoginWorkflowManager:NSObject, Customizable {
    
    @objc open var colorScheme: ColorScheme!
    @objc open var localizationBundle: Bundle!
    @objc open var localizationTableName: String!
    
    var phoneIdService: PhoneIdService
    var phoneIdComponentFactory: ComponentFactory
    
    @objc public override init() {
        
        phoneIdService = PhoneIdService.sharedInstance
        phoneIdComponentFactory = phoneIdService.componentFactory
        
        super.init()
        prep()
    }
    
    @objc public init(phoneIdService _phoneIdService:PhoneIdService, phoneIdComponentFactory _phoneIdComponentFactory:ComponentFactory){
        
        phoneIdService = _phoneIdService
        phoneIdComponentFactory = _phoneIdComponentFactory
        
        super.init()
        prep()
    }    
    
    @objc open func startLoginFlow(_ presentFromController:UIViewController? = nil,
                               initialPhoneNumerE164:String? = nil,
                               startAnimatingProgress:(()->())? = nil,
                               stopAnimationProgress:(()->())? = nil){
        
        login(presentFromController:presentFromController,
              initialPhoneNumerE164:initialPhoneNumerE164,
              lock:nil,
              unlock:nil,
              startAnimatingProgress: startAnimatingProgress,
              stopAnimationProgress: stopAnimationProgress)
        
    }
    
    
    func prep() {
        localizationBundle = phoneIdComponentFactory.localizationBundle
        localizationTableName = phoneIdComponentFactory.localizationTableName
        colorScheme = phoneIdComponentFactory.colorScheme
    }
    
    func login(presentFromController controller:UIViewController?,
                                     initialPhoneNumerE164:String?,
                                     lock:(()->())?,
                                     unlock:(()->())?,
                                     startAnimatingProgress:(()->(Void))?,
                                     stopAnimationProgress:(()->())?){
        
        lock?()
        if (phoneIdService.clientId == nil) {
            fatalError("Phone.id is not configured for use: clientId is not set. Please call configureClient(clientId) first")
        }
        
        if (phoneIdService.appName != nil) {
            self.presentLoginViewController(initialPhoneNumerE164, presentingViewController:self.presentingController())
            unlock?()
        } else {
            startAnimatingProgress?()
            
            phoneIdService.loadClients(phoneIdService.clientId!, completion: { [weak self] (error) -> Void in
                
                guard let me = self else {return}
                
                stopAnimationProgress?()
                
                let presenter = me.presentingController()
                
                if (error == nil) {
                    me.presentLoginViewController(initialPhoneNumerE164, presentingViewController:presenter)
                } else {
                    let alertController = UIAlertController(title: error?.localizedDescription, message: error?.localizedFailureReason, preferredStyle: .alert)
                    
                    alertController.addAction(UIAlertAction(title: me.localizedString("alert.button.title.dismiss"), style: .cancel, handler: nil));
                    presenter.present(alertController, animated: true, completion: nil)
                }
                unlock?()
                })
        }
        
    }
    
    fileprivate func presentingController() -> UIViewController{

        let phoneIdWindow = PhoneIdWindow()
        phoneIdWindow.makeActive()
        let  presentingController = phoneIdWindow.rootViewController!
        
        return presentingController
    }
    
    fileprivate func presentLoginViewController(_ phoneNumberE164:String?, presentingViewController:UIViewController) {
        
        let controller = phoneIdComponentFactory.loginViewController()
        
        let navigation = UINavigationController(rootViewController: controller)
        navigation.navigationBar.isHidden = true
        
        if let phoneNumberE164 = phoneNumberE164 {
            controller.phoneIdModel = NumberInfo(numberE164: phoneNumberE164)
        }
        
        presentingViewController.present(navigation, animated: true, completion: nil)
        
    }
}
