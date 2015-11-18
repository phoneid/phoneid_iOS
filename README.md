# phoneid_iOS
[![Build Status](https://travis-ci.org/phoneid/phoneid_iOS.svg)](https://travis-ci.org/phoneid/phoneid_iOS)
[![Version](https://cocoapod-badges.herokuapp.com/v/phoneid_iOS/badge.png)](http://cocoapods.org/pods/phoneid_iOS)
[![Platform](https://cocoapod-badges.herokuapp.com/p/phoneid_iOS/badge.png)](http://cocoapods.org/pods/phoneid_iOS)
[![License](http://img.shields.io/:license-apache-blue.svg)](http://www.apache.org/licenses/LICENSE-2.0.html)

# Overview

**phoneid_iOS** is lightweight and easy-to-use library for iOS 8 (written in Swift). It provides service to login users by phone number with verification code. See [Fullscreen mode](http://i284.photobucket.com/albums/ll39/streamlet10/out_zpsiocqf1g4.gif), [Compact mode](http://i284.photobucket.com/albums/ll39/streamlet10/out_zpseck5shrk.gif)


## Usage

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

iOS 8, iOS 9

## Installation

phoneid_iOS is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
use_frameworks!
pod "phoneid_iOS"
```

## Table Of Contents
- [Quick Start](#quick-start) 
 - [Configure phoneid client](#1-configure-phoneid-client) 
 - [Integrate phoneid button](#2-integrate-phoneid-button) 
 - [Callbacks](#3-callbacks) 
- [UI Customization](#ui-customization) 
- [User Profile](#user-profile)
- [Upload Contacts](#upload-contacts)
- [Author](#author)
- [License](#license)

## Quick Start

#### 1. Configure phoneid client:
If your app is not yet registered with PhoneId and has a client ID, you should create it on [developer.phone.id](http://developer.phone.id/)

In order to start work with phoneid SDK you should configure it with your client ID (replace "TestPhoneId" with your client ID):

#####Swift
```swift
import phoneid_iOS

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

//......
func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
       
        //configure client
        PhoneIdService.sharedInstance.configureClient("TestPhoneId");
        return true
    }
    
}
//.....

```

#####Objective-C
```Objective-C
#import "phoneid_iOS-Swift.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // configure phone.id
    [[PhoneIdService sharedInstance] configureClient:@"TestPhoneId" autorefresh:YES];
    
    return YES;
}
@end
```

PhoneIdService.sharedInstance - returns a singleton instance of PhoneIdService.

#### 2. Integrate phoneid button:
**PhoneIdLoginButton** is a UIView's subclass in the iOS SDK that allows users to log in and log out. It tracks the user's login state and automatically displays the appropriate message, **Log in** or **Log out**: 

Put UIView to your view controller in the storyboard and change it's class to **“PhoneIdLoginButton”**. Pay attention that module of this button will be changed automatically to “phoneid_iOS”. This is correct, don’t change this value:

![integration](http://i284.photobucket.com/albums/ll39/streamlet10/Screenshot%202015-10-25%2021.17.26_zpsrtgdj7hk.png)

Note, you can use **CompactPhoneIdLoginButton** instead of **PhoneIdLoginButton**

After this step integration is almost completed. 

#### 3. Callbacks:

In order to be notified about interesting events like successfull login, logout, or some error happened, etc. you can set appropriate handlers on PhoneIdService.sharedInstance. Here is list if available handlers:

---
**phoneIdAuthenticationSucceed** - Here you can get authentication token info after user has successfully logged in
######Swift
```swift
PhoneIdService.sharedInstance.phoneIdAuthenticationSucceed = { (token) ->Void in
 
}
```
######Objective-C
```Objective-C
[PhoneIdService sharedInstance].phoneIdAuthenticationSucceed = ^(TokenInfo* token){

};
```
---
**phoneIdAuthenticationCancelled** - phoneId SDK calls this block when user taps close button during authentication workflow
######Swift
```swift
 PhoneIdService.sharedInstance.phoneIdAuthenticationCancelled = {
 
}
```  
######Objective-C
```Objective-C
[PhoneIdService sharedInstance].phoneIdAuthenticationCancelled = ^{
        
};
```
---
**phoneIdAuthenticationRefreshed** - phoneid SDK calls this block every time when token refreshed
######Swift
```swift
PhoneIdService.sharedInstance.phoneIdAuthenticationRefreshed = { (token) ->Void in

}
``` 
######Objective-C
```Objective-C
[PhoneIdService sharedInstance].phoneIdAuthenticationRefreshed = ^(TokenInfo* token){

};
``` 
---
**phoneIdWorkflowErrorHappened** - phoneid SDK calls this block whenever error happened
######Swift
```swift
PhoneIdService.sharedInstance.phoneIdWorkflowErrorHappened = { (error) ->Void in
    print(error.localizedDescription)
} 
``` 
######Objective-C
```Objective-C
[PhoneIdService sharedInstance].phoneIdWorkflowErrorHappened = ^(NSError* error){
    NSLog(@"%@", error.localizedDescription);
};
``` 
---
**phoneIdDidLogout** - phoneid SDK calls this block on logout
######Swift
```swift
PhoneIdService.sharedInstance.phoneIdDidLogout = {

}
``` 
######Objective-C
```Objective-C
[PhoneIdService sharedInstance].phoneIdDidLogout = ^{
        
};
``` 



## UI Customization

Color scheme of phone.id UI can be easily customized.
This can be achieved via ColorScheme object. ColorScheme object defines set of named colors used inside of phone.id.

All fields of ColorScheme objects are UIColor's. 
This fields are separated on two groups: common colors and specific colors.

Common colors are used to define main color theme of phone.id UI and provide default values for specific colors.
Common colors never user directly inside of phone.id, they only provide default values for specific color fields.

This separation was done in order to to provide more flexible way of theming:
You can change only main colors - and there is no need to change every UI control color, however,
if you need to set specific colors for some UI controls you can override default values.

You can see detailed mapping of fields of ColorScheme to colors of UI controls here 
[![guide](https://github.com/phoneid/phoneid_iOS/blob/master/phone.id_theming_guide.pdf)](https://github.com/phoneid/phoneid_iOS/blob/master/phone.id_theming_guide.pdf)

Phone.id SDK provides customization point via the componentFactory property of PhoneIdService instance.
The customization of colors&background can be done in two steps:

1) Create your own instance of component factory and setup colorScheme with colors you like:
######Swift
```swift
    func customComponentFactory() -> ComponentFactory{
        
        let factory:ComponentFactory = DefaultComponentFactory()
        factory.colorScheme = ColorScheme()
        
        // You can change main colors
        factory.colorScheme.mainAccent = UIColor(hex: 0xAABB44)
        factory.colorScheme.extraAccent = UIColor(hex: 0x886655)
        factory.colorScheme.success = UIColor(hex: 0x91C1CC)
        factory.colorScheme.fail = UIColor(hex: 0xD4556A)
        factory.colorScheme.inputBackground = UIColor(hex: 0xEEEEDD).colorWithAlphaComponent(0.6)
        
        factory.colorScheme .applyCommonColors()
        
        // But also, if some of main colors don't fit to your color solution,
        // you can specify your own colors for certain UI element:
        
        factory.colorScheme.buttonHighlightedImage = UIColor(hex: 0x778230)
        factory.colorScheme.buttonHighlightedText = UIColor(hex: 0x778230)
        factory.colorScheme.buttonHighlightedBackground = UIColor(hex: 0xBBC86A)
        
        factory.defaultBackgroundImage = UIImage(named:"background")!
        
        return factory
    
    }
``` 
######Objective-C
```Objective-C
- (id<ComponentFactory>)customComponentFactory{

    id<ComponentFactory> factory = [[DefaultComponentFactory alloc] init];
    
    ColorScheme* colorScheme = [[ColorScheme alloc] init];
    colorScheme.mainAccent = [[UIColor alloc] initWithHex:0xAABB44];
    colorScheme.extraAccent = [[UIColor alloc] initWithHex:0x886655];
    colorScheme.success = [[UIColor alloc] initWithHex:0x91C1CC];
    colorScheme.fail = [[UIColor alloc] initWithHex:0xD4556A];
    
    colorScheme.inputBackground = [[[UIColor alloc] initWithHex:0xEEEEDD] colorWithAlphaComponent:0.6];
    [colorScheme applyCommonColors];
    
    colorScheme.buttonHighlightedImage = [[UIColor alloc] initWithHex: 0x778230];
    colorScheme.buttonHighlightedText = [[UIColor alloc] initWithHex: 0x778230];
    colorScheme.buttonHighlightedBackground = [[UIColor alloc] initWithHex: 0xBBC86A];
    factory.defaultBackgroundImage = [UIImage imageNamed:@"background"];
    factory.colorScheme = colorScheme;
    
    return factory;
}
``` 


2) set your own component factory to phoneid service, as early as possible, preferable in didFinishLaunchingWithOptions:
######Swift
```swift
    func application(application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
            
            // configure phone.id
            PhoneIdService.sharedInstance.configureClient("TestPhoneId");
            
            // UI theming
            PhoneIdService.sharedInstance.componentFactory = customComponentFactory()
            return true
    }
``` 

######Objective-C
```Objective-C
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // configure phone.id
    [[PhoneIdService sharedInstance] configureClient:@"TestPhoneId" autorefresh:YES];
    
    // UI theming
    [PhoneIdService sharedInstance].componentFactory = [self customComponentFactory];
    
    return YES;
}
``` 

[Example of customization](http://i284.photobucket.com/albums/ll39/streamlet10/Screenshot%202015-10-25%2021.51.43_zpszpmapuvo.png)

## User Profile
Phone.id SDK provides User Profile management. 

In order to request user's profile call to loadMyProfile method of PhoneIdService. 
User can also edit her profile: setup screen name, profile picture, and date of birth. 
The component factory provides profile editing UI for you, see example below:
 
######Swift
```swift
   // load user profile
   PhoneIdService.sharedInstance.loadMyProfile{ (userInfo, e) -> Void in

       if let user = userInfo{
       
           // present user editing profile UI
           let profileController = PhoneIdService.sharedInstance.componentFactory.editProfileViewController(user)
           self.presentViewController(profileController, animated: true, completion: nil)
       }
   }
``` 

######Objective-C
```Objective-C
    // load user profile
    [[PhoneIdService sharedInstance] loadUserProfile: ^(UserInfo* userInfo, NSError* e){
        
        if (userInfo){
            // present user editing profile UI
            UIViewController* profileController = [[PhoneIdService sharedInstance].componentFactory editProfileViewController: userInfo];
            [self presentViewController:profileController animated:YES completion:nil];
        }
        
    }];
``` 

User profile pictures are uploaded to s3.amazon.com which does not copmletely supports requirements of [Apple App transport security](https://developer.apple.com/library/prerelease/ios/technotes/App-Transport-Security-Technote/index.html) yet ([more details](http://stackoverflow.com/questions/32500655/ios-9-app-download-from-amazon-s3-ssl-error-tls-1-2-support)). So in order to make it workable following snippet need to be added into application's Info.plist

######Info.plist
```XML
    <key>NSAppTransportSecurity</key>
    <dict>
        <key>NSExceptionDomains</key>
        <dict>
            <key>s3.amazonaws.com</key>
            <dict>
                <key>NSExceptionRequiresForwardSecrecy</key>
                <false/>
            </dict>
        </dict>
    </dict>
``` 

## Upload Contacts

Phone numbers from user's address book are stored on Phone.id servers and used to build the Social Graph. You can upload user's address book using following call:

######Swift
```swift
    PhoneIdService.sharedInstance.uploadContacts() { (numberOfUpdatedContacts, error) -> Void in
 
    }
``` 

######Objective-C
```Objective-C
   [[PhoneIdService sharedInstance] uploadContacts:^(NSInteger numberOfContacts, NSError * error) {

   }];
``` 

If user's address book was not changed since last upload, method will not reupload the book once more.

## <a name="#author">Author</a>

Federico Pomi, federico@pomi.net

## <a name="#license">License</a>  

phoneid_iOS is available under the Apache License Version 2.0. See the LICENSE file for more info.
