//
//  ViewController.swift
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

import UIKit
import phoneid_iOS

class ViewController: UIViewController {
    
    @IBOutlet weak var tokensView: UIView!
    @IBOutlet weak var tokenText: UITextField!
    @IBOutlet weak var refreshTokenText: UITextField!
    
    @IBOutlet weak var phoneIdButton: PhoneIdLoginButton!
    @IBOutlet weak var compactPhoneIdButton: CompactPhoneIdLoginButton!
    
    let phoneId: PhoneIdService = PhoneIdService.sharedInstance;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateTokenInfoView()
        
        // Handle authentication success
        phoneId.phoneIdAuthenticationSucceed = { (token) ->Void in
            self.updateTokenInfoView()
        }
        
        // SDK calls this block whenever error happened
        phoneId.phoneIdWorkflowErrorHappened = { (error) ->Void in
            print(error.localizedDescription)
        }
        
        // SDK calls this block when user taps close button
        phoneId.phoneIdAuthenticationCancelled = {
            
            let alertController = UIAlertController(title:nil, message:"phone.id authentication has been cancelled", preferredStyle: .Alert)
            
            alertController.addAction(UIAlertAction(title:"Dismiss", style: .Cancel, handler:nil));
            self.presentViewController(alertController, animated: true, completion:nil)
        }
        
        // SDK calls this block every time when token refreshed
        phoneId.phoneIdAuthenticationRefreshed = { (token) ->Void in
            self.updateTokenInfoView()
        }
        
        // SDK calls this block on logout
        phoneId.phoneIdDidLogout = { (token) ->Void in
            self.updateTokenInfoView()
        }
        
        
        //customize appearence
        //phoneId.componentFactory = CustomComponentFactory()
        
    }
    
    func updateTokenInfoView(){
        self.tokensView.hidden = !phoneId.isLoggedIn
        if let token = phoneId.token {
            self.tokenText.text = token.accessToken
            self.refreshTokenText.text = token.refreshToken
        }
    }
    
    @IBAction func uploadContactsTapped(sender: UIButton) {
        phoneId.uploadContacts() { (numberOfUpdatedContacts, error) -> Void in
            
            var alertController:UIAlertController!
            
            if let error = error {
                alertController = UIAlertController(title:error.localizedDescription, message:error.localizedFailureReason, preferredStyle: .Alert)
            }else{
                alertController = UIAlertController(title:"Number of updated contacts", message:"\(numberOfUpdatedContacts)", preferredStyle: .Alert)
            }
       
            alertController.addAction(UIAlertAction(title:"Dismiss", style: .Cancel, handler:nil));
            self.presentViewController(alertController, animated: true, completion:nil)
            
        }
    }
    
    @IBAction func switchCompactMode(sender: UISwitch) {
        
        phoneIdButton.hidden = sender.on
        compactPhoneIdButton.hidden = !sender.on
    }
   
    
}

// customization point
class CustomComponentFactory:DefaultComponentFactory{
    
    override func defaultBackgroundImage()->UIImage{
        return UIImage(named:"background")!
    }
    
    override func colorScheme()->ColorScheme{
        let scheme = super.colorScheme()
        scheme.mainAccent = UIColor(netHex: 0x357AAE)
        scheme.selectedText = UIColor(netHex: 0x4192C7)
        scheme.linkText = UIColor(netHex: 0x4192C7)
        return scheme
    }
}
