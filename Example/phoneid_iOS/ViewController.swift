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
        
        //configure client
        phoneId.configureClient("TestPhoneId");
        
        
        // Handle authentication success
        phoneId.phoneIdAuthenticationSucceed = { (token) ->Void in
            self.tokensView.hidden = false
            self.tokenText.text = token.accessToken
            self.refreshTokenText.text = token.refreshToken
            
        }
        
        // Handle authentication fail
        phoneId.phoneIdAuthenticationFailed = { (error) ->Void in
            
            let alertController = UIAlertController(title:error.localizedDescription, message:error.localizedFailureReason, preferredStyle: .Alert)
            
            alertController.addAction(UIAlertAction(title:"Dismiss", style: .Cancel, handler:nil));
            self.presentViewController(alertController, animated: true, completion:nil)
        
        }
        
        //customize appearence
        //phoneId.componentFactory = CustomComponentFactory()
        
    }
    
    @IBAction func doLogout(sender: AnyObject) {
        phoneId.logout()
        self.tokensView.hidden = true
    }
    

    @IBAction func doRefreshToken(sender: AnyObject) {
        
        phoneId.refreshToken(){ (token, error) ->Void in
        
            self.tokensView.hidden = false
            if let token = token {
                self.tokenText.text = token.accessToken
                self.refreshTokenText.text = token.refreshToken
            } else if let error = error{
                print("\(error.localizedDescription), \(error.localizedFailureReason!)")
            }
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
