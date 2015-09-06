//
//  PhoneIdWindow.swift
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

class PhoneIdWindow: UIWindow {
    
    weak var previousKeyWindow:UIWindow?
 
    class func activePhoneIdWindow() -> PhoneIdWindow? {
        return UIApplication.sharedApplication().keyWindow as? PhoneIdWindow
    }
    
    class func currentPresenter() -> UIViewController {
        if PhoneIdWindow.activePhoneIdWindow() == nil {
            PhoneIdWindow().makeActive()
        }
        let presenter:UIViewController = PhoneIdWindow.activePhoneIdWindow()!.currentPresenter()!
        return presenter
    }
    
    func close(){
        self.resignFirstResponder()
        UIView.animateWithDuration(0.3, animations: {  () -> Void in
                self.alpha = 0
            
            }) { (Bool) -> Void in
                self.removeFromSuperview()
                self.previousKeyWindow?.makeKeyAndVisible()
        }

    }
    
    func makeActive() {
        
        self.backgroundColor = UIColor.clearColor()
        
        self.windowLevel = UIWindowLevelAlert
        
        self.rootViewController = UIViewController()
        
        self.makeKeyAndVisible()
        
    }
    
    func currentPresenter() -> UIViewController? {
    
        var presenter:UIViewController?
        
        if let window = PhoneIdWindow.activePhoneIdWindow() {
         
            if let presentedViewController = window.rootViewController!.presentedViewController {
                presenter =  presentedViewController
            }else{
                presenter = window.rootViewController
            }
        }
        
        return presenter
    }
    
}

