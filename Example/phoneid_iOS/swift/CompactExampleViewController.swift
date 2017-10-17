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
    
    @IBAction func dismiss(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        details.presetNumber.addTarget(self,
                                       action: #selector(CompactExampleViewController.presetNumberChanged(_:)),
                                       for:.editingChanged)
        
        details.switchUserPresetNumber.addTarget(self,
                                                 action: #selector(CompactExampleViewController.presetNumberSwitchChanged(_:)),
                                                 for:.valueChanged)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "details" {
            details = segue.destination as? DetailsViewController
        }
    }
    
    @objc func presetNumberChanged(_ sender:UITextField){
        compactPhoneIdButton.phoneNumberE164 = details.switchUserPresetNumber.isOn ? sender.text : ""
    }
    
    @objc func presetNumberSwitchChanged(_ sender:UISwitch){
        compactPhoneIdButton.phoneNumberE164 = sender.isOn ? details.presetNumber.text : ""
    }
}
