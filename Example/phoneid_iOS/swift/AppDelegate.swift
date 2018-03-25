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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
            
            // configure phone.id
           // PhoneIdService.sharedInstance.configureClient("TestPhoneId");
        
           PhoneIdService.sharedInstance.configureClient("68e61b8767e6f9793eb6f03f16e185005bfa87c4");
        
            // UI theming
            // PhoneIdService.sharedInstance.componentFactory = customComponentFactory()
            return true
    }
    
    func customComponentFactory() -> ComponentFactory{
        
        let factory:ComponentFactory = DefaultComponentFactory()
        factory.colorScheme = ColorScheme()
        
        // You can change main colors
        factory.colorScheme.mainAccent = UIColor(hex: 0xAABB44)
        factory.colorScheme.extraAccent = UIColor(hex: 0x886655)
        factory.colorScheme.success = UIColor(hex: 0x91C1CC)
        factory.colorScheme.fail = UIColor(hex: 0xD4556A)
        factory.colorScheme.inputBackground = UIColor(hex: 0xEEEEDD).withAlphaComponent(0.6)
        
        factory.colorScheme .applyCommonColors()
        
        // But also, if some of main colors don't fit to your color solution,
        // you can specify your own colors for certain UI element:
        
        factory.colorScheme.buttonHighlightedImage = UIColor(hex: 0x778230)
        factory.colorScheme.buttonHighlightedText = UIColor(hex: 0x778230)
        factory.colorScheme.buttonHighlightedBackground = UIColor(hex: 0xBBC86A)
        
        factory.defaultBackgroundImage = UIImage(named:"background")!
        
        return factory
    
    }
}

