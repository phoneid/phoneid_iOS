//
//  StandardExampleViewController.swift
//  phoneid_iOS
//
//  Created by Alyona on 4/6/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit

import phoneid_iOS


class StandardExampleViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var phoneIdButton: PhoneIdLoginButton!
    
    var details:DetailsViewController!
 
    @IBAction func dismiss(sender: AnyObject) {
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        details.presetNumber.addTarget(self,
                                       action: #selector(StandardExampleViewController.presetNumberChanged(_:)),
                                       forControlEvents:.EditingChanged)
        
        details.switchUserPresetNumber.addTarget(self,
                                                 action: #selector(StandardExampleViewController.presetNumberSwitchChanged(_:)),
                                                 forControlEvents:.ValueChanged)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "details" {
            details = segue.destinationViewController as? DetailsViewController
        }
    }
    
    func presetNumberChanged(sender:UITextField){
        phoneIdButton.phoneNumberE164 = details.switchUserPresetNumber.on ? sender.text : ""
    }
    
    func presetNumberSwitchChanged(sender:UISwitch){
        phoneIdButton.phoneNumberE164 = sender.on ? details.presetNumber.text : ""
    }
}