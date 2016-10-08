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
 
    @IBAction func dismiss(_ sender: AnyObject) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        details.presetNumber.addTarget(self,
                                       action: #selector(StandardExampleViewController.presetNumberChanged(_:)),
                                       for:.editingChanged)
        
        details.switchUserPresetNumber.addTarget(self,
                                                 action: #selector(StandardExampleViewController.presetNumberSwitchChanged(_:)),
                                                 for:.valueChanged)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "details" {
            details = segue.destination as? DetailsViewController
        }
    }
    
    func presetNumberChanged(_ sender:UITextField){
        phoneIdButton.phoneNumberE164 = details.switchUserPresetNumber.isOn ? sender.text : ""
    }
    
    func presetNumberSwitchChanged(_ sender:UISwitch){
        phoneIdButton.phoneNumberE164 = sender.isOn ? details.presetNumber.text : ""
    }
}
