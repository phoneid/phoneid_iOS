//
//  CompactExampleViewController.swift
//  phoneid_iOS
//
//  Created by Alyona on 4/6/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit

import phoneid_iOS


class CompactExampleViewController: UIViewController {
    
    @IBOutlet weak var compactPhoneIdButton: CompactPhoneIdLoginButton!
    var details:DetailsViewController!
    
    @IBAction func dismiss(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        details.presetNumber.addTarget(self,
                                       action: #selector(CompactExampleViewController.presetNumberChanged(_:)),
                                       forControlEvents:.EditingChanged)
        
        details.switchUserPresetNumber.addTarget(self,
                                                 action: #selector(CompactExampleViewController.presetNumberSwitchChanged(_:)),
                                                 forControlEvents:.ValueChanged)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "details" {
            details = segue.destinationViewController as? DetailsViewController
        }
    }
    
    func presetNumberChanged(sender:UITextField){
        compactPhoneIdButton.phoneNumberE164 = details.switchUserPresetNumber.on ? sender.text : ""
    }
    
    func presetNumberSwitchChanged(sender:UISwitch){
        compactPhoneIdButton.phoneNumberE164 = sender.on ? details.presetNumber.text : ""
    }
}