//
//  ResourcesLoadingExtensions.swift
//  PhoneIdSDK
//
//  Created by Alyona on 6/23/15.
//  Copyright © 2015 phoneId. All rights reserved.
//

import Foundation


extension NSBundle{
    class func phoneIdBundle() -> NSBundle{
        return NSBundle(forClass: PhoneIdLoginButton.self)
    }
}

extension UIImage {
    
    convenience init?(namedInPhoneId:String){
        let frameworkBundle = NSBundle.phoneIdBundle()
        self.init(named: namedInPhoneId, inBundle: frameworkBundle, compatibleWithTraitCollection: nil)
    }
    
}

extension UIStoryboard {
    
    convenience init?(namedInPhoneId:String){
        let frameworkBundle = NSBundle.phoneIdBundle()
        self.init(name: namedInPhoneId, bundle: frameworkBundle)

    }
    
}

