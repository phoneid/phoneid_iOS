//
//  DetailsViewController.swift
//  phoneid_iOS
//
//  Created by Alyona on 4/6/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import Foundation

import UIKit

import phoneid_iOS



class DetailsViewController: UIViewController {
    
    @IBOutlet weak var tokensView: UIView!
    @IBOutlet weak var tokenText: UITextField!
    @IBOutlet weak var refreshTokenText: UITextField!
    @IBOutlet weak var presetNumber: UITextField!
    
    @IBOutlet weak var switchUserPresetNumber: UISwitch!
    @IBOutlet weak var switchDebugContactsUpload: UISwitch!

    let phoneId: PhoneIdService = PhoneIdService.sharedInstance
  
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateTokenInfoView()
        
        // Handle authentication success
        phoneId.phoneIdAuthenticationSucceed = { [unowned self] (token) ->Void in
            self.updateTokenInfoView()
        }        
        
        // Track changes of country code
        phoneId.phoneIdWorkflowCountryCodeSelected = { countryCode in
            print("country code changed to \(countryCode)")
        }
        
        // Notifies number input completed and will be sent to phone.id server
        phoneId.phoneIdWorkflowNumberInputCompleted = { numberInfo in
            print("phone number input completed \(numberInfo.e164Format())")
        }
        
        // Notifies that verification code input completed and will be sent to phone.id server
        phoneId.phoneIdWorkflowVerificationCodeInputCompleted = { code in
            print("verification input completed \(code)")
        }
        
        // SDK calls this block whenever error happened
        phoneId.phoneIdWorkflowErrorHappened = { (error) ->Void in
            print(error.localizedDescription)
        }
        
        // SDK calls this block when user taps close button
        phoneId.phoneIdAuthenticationCancelled = { [unowned self] in
            
            let alertController = UIAlertController(title:nil, message:"phone.id authentication has been cancelled", preferredStyle: .Alert)
            
            alertController.addAction(UIAlertAction(title:"Dismiss", style: .Cancel, handler:nil));
            self.parentViewController!.presentViewController(alertController, animated: true, completion:nil)
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
        let uploadInDebugMode = switchDebugContactsUpload.on
        phoneId.uploadContacts(debugMode:uploadInDebugMode) { (numberOfUpdatedContacts, error) -> Void in
            
            var alertController:UIAlertController!
            
            if let error = error {
                alertController = UIAlertController(title:error.localizedDescription, message:error.localizedFailureReason, preferredStyle: .Alert)
            }else{
                alertController = UIAlertController(title:"Number of updated contacts", message:"\(numberOfUpdatedContacts)", preferredStyle: .Alert)
            }
            
            alertController.addAction(UIAlertAction(title:"Dismiss", style: .Cancel, handler:nil));
            self.parentViewController!.presentViewController(alertController, animated: true, completion:nil)
            
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
}