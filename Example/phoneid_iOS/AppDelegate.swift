//
//  AppDelegate.swift
//  phoneid_iOS
//
//  Copyright 2015 phone.id - 73 knots, Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//



import UIKit
import phoneid_iOS

class CustomComponentFactory:DefaultComponentFactory{
    
    override func defaultBackgroundImage()->UIImage?{
        return UIImage(named:"background")!
    }
    
    override func colorScheme()->ColorScheme{
        let scheme = super.colorScheme()
        
        // You can change main colors
        scheme.mainAccent = UIColor(hex: 0xAABB44)
        scheme.extraAccent = UIColor(hex: 0x886655)
        scheme.success = UIColor(hex: 0x91C1CC)
        scheme.fail = UIColor(hex: 0xD4556A)
        scheme.inputBackground = UIColor(hex: 0xEEEEDD).colorWithAlphaComponent(0.6)
        
        scheme.applyCommonColors()
        
        // But also, if some of main colors don't fit to your color solution,
        // you can specify your own colors for certain UI element:

        scheme.buttonHightlightedImage = UIColor(hex: 0x778230)
        scheme.buttonHightlightedText = UIColor(hex: 0x778230)
        scheme.buttonHightlightedBackground = UIColor(hex: 0xBBC86A)
        
        return scheme
    }
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        // configure phone.id
            
        // unkomment to see UI theming
        // PhoneIdService.sharedInstance.componentFactory = CustomComponentFactory()
        
        PhoneIdService.sharedInstance.configureClient("TestPhoneId");
        return true
    }
}

