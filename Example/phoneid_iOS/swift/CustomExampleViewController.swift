//
//  CustomExampleViewController.swift
//  phoneid_iOS
//
//  Created by Alyona on 4/6/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit

import phoneid_iOS


class CustomExampleViewController: UIViewController {

    
    // Use PhoneIdLoginWorkflowManager as alternative way to start login flow from your code
    let flowManager = PhoneIdLoginWorkflowManager()
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var customLoginButton: UIButton!
    
    var details:DetailsViewController!
    var phoneNumberE164:String?
    
    @IBAction func presentFromCustomButton(_ sender: AnyObject) {
    

        flowManager.startLoginFlow(initialPhoneNumerE164:phoneNumberE164,
                                   startAnimatingProgress: {self.activityIndicator.startAnimating()},
                                   stopAnimationProgress: {self.activityIndicator.stopAnimating()})
    }

    @IBAction func dismiss(_ sender: AnyObject) {
        
        self.dismiss(animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        details.presetNumber.addTarget(self,
                                       action: #selector(CustomExampleViewController.presetNumberChanged(_:)),
                                       for:.editingChanged)
        
        details.switchUserPresetNumber.addTarget(self,
                                                 action: #selector(CustomExampleViewController.presetNumberSwitchChanged(_:)),
                                                 for:.valueChanged)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "details" {
            details = segue.destination as? DetailsViewController
        }
    }
    
    @objc func presetNumberChanged(_ sender:UITextField){
        phoneNumberE164 = details.switchUserPresetNumber.isOn ? sender.text : ""
    }
    
    @objc func presetNumberSwitchChanged(_ sender:UISwitch){
        phoneNumberE164 = sender.isOn ? details.presetNumber.text : ""
    }
    
  
}
