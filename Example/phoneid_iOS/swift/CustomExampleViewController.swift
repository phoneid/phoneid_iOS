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
    
    @IBAction func presentFromCustomButton(sender: AnyObject) {
    

        flowManager.startLoginFlow(initialPhoneNumerE164:phoneNumberE164,
                                   startAnimatingProgress: {self.activityIndicator.startAnimating()},
                                   stopAnimationProgress: {self.activityIndicator.stopAnimating()})
    }

    @IBAction func dismiss(sender: AnyObject) {
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        details.presetNumber.addTarget(self,
                                       action: #selector(CustomExampleViewController.presetNumberChanged(_:)),
                                       forControlEvents:.EditingChanged)
        
        details.switchUserPresetNumber.addTarget(self,
                                                 action: #selector(CustomExampleViewController.presetNumberSwitchChanged(_:)),
                                                 forControlEvents:.ValueChanged)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "details" {
            details = segue.destinationViewController as? DetailsViewController
        }
    }
    
    func presetNumberChanged(sender:UITextField){
        phoneNumberE164 = details.switchUserPresetNumber.on ? sender.text : ""
    }
    
    func presetNumberSwitchChanged(sender:UISwitch){
        phoneNumberE164 = sender.on ? details.presetNumber.text : ""
    }
    
  
}