//
//  ViewController.swift
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



import UIKit

import UIKit
import phoneid_iOS

class ViewController: UIViewController {
    
    @IBOutlet weak var tokensView: UIView!
    @IBOutlet weak var tokenText: UITextField!
    @IBOutlet weak var refreshTokenText: UITextField!
    @IBOutlet weak var presetNumber: UITextField!
    
    @IBOutlet weak var phoneIdButton: PhoneIdLoginButton!
    @IBOutlet weak var compactPhoneIdButton: CompactPhoneIdLoginButton!
    
    let phoneId: PhoneIdService = PhoneIdService.sharedInstance;
    var usePresetNumber:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateTokenInfoView()
        
        // Handle authentication success
        phoneId.phoneIdAuthenticationSucceed = { [unowned self] (token) ->Void in
            self.updateTokenInfoView()
        }
        
        // SDK calls this block whenever error happened
        phoneId.phoneIdWorkflowErrorHappened = { (error) ->Void in
            print(error.localizedDescription)
        }
        
        // SDK calls this block when user taps close button
        phoneId.phoneIdAuthenticationCancelled = { [unowned self] in
            
            let alertController = UIAlertController(title:nil, message:"phone.id authentication has been cancelled", preferredStyle: .Alert)
            
            alertController.addAction(UIAlertAction(title:"Dismiss", style: .Cancel, handler:nil));
            self.presentViewController(alertController, animated: true, completion:nil)
        }
        
        // SDK calls this block every time when token refreshed
        phoneId.phoneIdAuthenticationRefreshed = {  [unowned self] (token) ->Void in
            self.updateTokenInfoView()
        }
        
        // SDK calls this block on logout
        phoneId.phoneIdDidLogout = {  [unowned self] () ->Void in
            self.updateTokenInfoView()
        } 
        
    }
    
    func updateTokenInfoView(){
        self.tokensView.hidden = !phoneId.isLoggedIn
        if let token = phoneId.token {
            self.tokenText.text = token.accessToken
            self.refreshTokenText.text = token.refreshToken
        }
    }
    
    @IBAction func uploadContactsTapped(sender: UIButton) {
        phoneId.uploadContacts(debugMode:true) { (numberOfUpdatedContacts, error) -> Void in
            
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
    
    @IBAction func editProfileTapped(sender: AnyObject) {
    
        phoneId.loadMyProfile{ (userInfo, e) -> Void in

            if let user = userInfo{
                let profileController = self.phoneId.componentFactory.editProfileViewController(user)
                self.presentViewController(profileController, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func switchCompactMode(sender: UISwitch) {
        
        phoneIdButton.hidden = sender.on
        phoneIdButton.userInteractionEnabled = !phoneIdButton.hidden
        compactPhoneIdButton.hidden = !sender.on
        compactPhoneIdButton.userInteractionEnabled = !compactPhoneIdButton.hidden
    }
   
    @IBAction func switchPresetNumber(sender: UISwitch) {

        if(sender.on){
            phoneIdButton.phoneNumberE164 = presetNumber.text
            compactPhoneIdButton.phoneNumberE164 = presetNumber.text
        }else{
            phoneIdButton.phoneNumberE164 = nil
            compactPhoneIdButton.phoneNumberE164 = nil
        }
    }
    
}

