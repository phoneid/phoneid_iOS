# phoneid_iOS

[![CI Status](http://img.shields.io/travis/Alyona/phoneid_iOS.svg?style=flat)](https://travis-ci.org/Alyona/phoneid_iOS)
[![Version](https://img.shields.io/cocoapods/v/phoneid_iOS.svg?style=flat)](http://cocoapods.org/pods/phoneid_iOS)
[![License](https://img.shields.io/cocoapods/l/phoneid_iOS.svg?style=flat)](http://cocoapods.org/pods/phoneid_iOS)
[![Platform](https://img.shields.io/cocoapods/p/phoneid_iOS.svg?style=flat)](http://cocoapods.org/pods/phoneid_iOS)

# Overview

**phoneid_iOS** is lightweight and easy-to-use library for iOS 8 (written in Swift). It provides service to login users by phone number with verification code, demo <a href="http://www.youtube.com/watch?feature=player_embedded&v=-U1M-CVJlvE
" target="_blank"><img src="http://vid284.photobucket.com/albums/ll39/streamlet10/iphoneid_iOS_zpsflhnnzjn.mp4" 
alt="video" width="320" height="445" border="10" /></a>

![phoneId](http://i284.photobucket.com/albums/ll39/streamlet10/1_zpsfhg0caoi.png).
![phoneId](http://i284.photobucket.com/albums/ll39/streamlet10/2_zpsgvy29hzs.png).
![phoneId](http://i284.photobucket.com/albums/ll39/streamlet10/3_zpsbrwjecjj.png).
![phoneId](http://i284.photobucket.com/albums/ll39/streamlet10/4_zpsogzpnbkj.png)


## Usage

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

iOS 8

## Installation

phoneid_iOS is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
use_frameworks!
pod "phoneid_iOS", :git => 'https://github.com/fedepo/phoneid_iOS.git'
```

## Quick Start

#### 1. Configure phoneid client:
If your app is not yet registered with PhoneId and has a client ID, you should create it on [developer.phone.id](http://developer.phone.id/)

In order to start work with phoneid SDK you should configure it with your client ID:

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

PhoneIdService.sharedInstance - returns a singleton instance of PhoneIdService.
Don't forget to import phoneid_iOS before refer to PhoneIdService.

#### 2. Integrate phoneid button:
**PhoneIdLoginButton** is a UIButton subclass in the iOS SDK that allows users to log in and log out. It tracks the user's login state and automatically displays the appropriate message, **Log in** or **Log out**: 

Put UIButton to your view controller in the storyboard and change it's class to “PhoneIdLoginButton”. Pay attention that module of this button will be changed automatically to “phoneid_iOS”. This is correct, don’t change this value:

![integration](http://i284.photobucket.com/albums/ll39/streamlet10/phoneid_iOS_pic1_zpshn09fx42.jpg)

After this step integration is almost completed. 

#### 3. Callbacks

In order to be notified about interesting events like successfull login, logout, or some error happened, etc. you can set appropriate handlers on PhoneIdService.sharedInstance

Here is list if available handlers:

* phoneIdAuthenticationSucceed - Here you can get authentication token info after user has successfully logged in
```swift
PhoneIdService.sharedInstance.phoneIdAuthenticationSucceed = { (token) ->Void in
 
}
```        
* phoneIdAuthenticationCancelled - phoneId SDK calls this block when user taps close button during authentication workflow
```swift
 PhoneIdService.sharedInstance.phoneIdAuthenticationCancelled = {
 
}
```  
* phoneIdAuthenticationRefreshed - phoneid SDK calls this block every time when token refreshed
```swift
PhoneIdService.sharedInstance.phoneIdAuthenticationRefreshed = { (token) ->Void in

}
``` 

* phoneIdWorkflowErrorHappened - phoneid SDK calls this block whenever error happened
```swift
PhoneIdService.sharedInstance.phoneIdWorkflowErrorHappened = { (error) ->Void in
    print(error.localizedDescription)
} 
``` 

* phoneIdDidLogout - phoneid SDK calls this block on logout
```swift
PhoneIdService.sharedInstance.phoneIdDidLogout = { (token) ->Void in

}
``` 

## UI Customization

// TODO:

## Author

Federico Pomi, federico@pomi.net

## License

phoneid_iOS is available under the Apache License Version 2.0. See the LICENSE file for more info.
