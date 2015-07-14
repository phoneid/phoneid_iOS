//
//  ViewController.swift
//  PhoneIdClient
//
//  Created by Alyona on 07/07/2015.
//  Copyright (c) 2015 Alyona. All rights reserved.
//

import UIKit

import UIKit
import phoneid_iOS

class ViewController: UIViewController {
    
    @IBOutlet weak var tokensView: UIView!
    @IBOutlet weak var tokenText: UITextField!
    @IBOutlet weak var refreshTokenText: UITextField!
    
    
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
