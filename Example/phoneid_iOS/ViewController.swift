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
        
        
        phoneId.configureClient("TestPhoneId");
        
        phoneId.phoneIdAuthenticationCompletion = { (token) ->Void in
            self.tokensView.hidden = false
            self.tokenText.text = token.accessToken
            self.refreshTokenText.text = token.refreshToken
            
        }
        
        //for customization uncomment code below
        //phoneId.componentFactory = CustomComponentFactory()
        
    }
    
    @IBAction func doLogout(sender: AnyObject) {
        phoneId.logout()
        self.tokensView.hidden = true
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
