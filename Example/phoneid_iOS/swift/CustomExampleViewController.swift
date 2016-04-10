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
    @IBOutlet weak var loginDetails: UIView!
    
    @IBAction func presentFromCustomButton(sender: AnyObject) {
    

        flowManager.startLoginFlow(initialPhoneNumerE164:"+380678750502",
                                   startAnimatingProgress: {self.activityIndicator.startAnimating()},
                                   stopAnimationProgress: {self.activityIndicator.stopAnimating()})
    }

    @IBAction func dismiss(sender: AnyObject) {
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }

}