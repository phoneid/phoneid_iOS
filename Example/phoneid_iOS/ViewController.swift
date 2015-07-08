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
    
    let phoneId: PhoneIdService = PhoneIdService.sharedInstance;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        phoneId.configureClient("TestPhoneId");
        
        phoneId.phoneIdAuthenticationCompletion = { (token) ->Void in
            
            NSLog("accessToken: %@, refreshToken: %@", token.accessToken!, token.refreshToken!);
            
            let alertController = UIAlertController(title: "Phone.id Login OK", message: "accessToken: \(token.accessToken!)\n refreshToken: \(token.refreshToken!)", preferredStyle: .Alert)
            
            alertController.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler:nil));
            
            self.presentViewController(alertController, animated: true, completion:nil)
            
        }
        
        //for customization uncomment code below
        //phoneId.componentFactory = CustomComponentFactory()
        
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
