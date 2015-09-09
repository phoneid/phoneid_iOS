# phoneid_iOS
[![Version](https://cocoapod-badges.herokuapp.com/v/phoneid_iOS/badge.png)](http://cocoapods.org/pods/phoneid_iOS)
[![Platform](https://cocoapod-badges.herokuapp.com/p/phoneid_iOS/badge.png)](http://cocoapods.org/pods/phoneid_iOS)
[![License](https://img.shields.io/cocoapods/l/phoneid_iOS.svg)](http://cocoapods.org/pods/phoneid_iOS)

# Overview

**phoneid_iOS** is lightweight and easy-to-use library for iOS 8 (written in Swift). It provides service to login users by phone number with verification code, demo <a href="http://www.youtube.com/watch?feature=player_embedded&v=-U1M-CVJlvE
" target="_blank"><img src="http://vid284.photobucket.com/albums/ll39/streamlet10/iphoneid_iOS_zpsflhnnzjn.mp4" 
alt="video" width="320" height="445" border="10" /></a>

**Fullscreen mode:**

![phoneId](http://i284.photobucket.com/albums/ll39/streamlet10/1_zpsfhg0caoi.png).
![phoneId](http://i284.photobucket.com/albums/ll39/streamlet10/2_zpsgvy29hzs.png).
![phoneId](http://i284.photobucket.com/albums/ll39/streamlet10/3_zpsbrwjecjj.png).
![phoneId](http://i284.photobucket.com/albums/ll39/streamlet10/4_zpsogzpnbkj.png)

**Compact mode:**
![phoneId](http://i284.photobucket.com/albums/ll39/streamlet10/1_zpsc28ojsg8.png).
![phoneId](http://i284.photobucket.com/albums/ll39/streamlet10/2_zpsnapr9ry8.png).
![phoneId](http://i284.photobucket.com/albums/ll39/streamlet10/3_zpsqaissydp.png).
![phoneId](http://i284.photobucket.com/albums/ll39/streamlet10/4_zpsbxmrdjkf.png).
![phoneId](http://i284.photobucket.com/albums/ll39/streamlet10/5_zpsnfqnwncb.png).
![phoneId](http://i284.photobucket.com/albums/ll39/streamlet10/6_zpsf2w6rvpz.png).



## Usage

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

iOS 8,

## Installation

phoneid_iOS is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
use_frameworks!
pod "phoneid_iOS"
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

Put UIButton to your view controller in the storyboard and change it's class to **“PhoneIdLoginButton”**. Pay attention that module of this button will be changed automatically to “phoneid_iOS”. This is correct, don’t change this value:

![integration](http://i284.photobucket.com/albums/ll39/streamlet10/phoneid_iOS_pic1_zpshn09fx42.jpg)

Note, you can use **CompactPhoneIdLoginButton** instead of **PhoneIdLoginButton**

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
You can easily customize colors and background of phone.id UI.

Phone.id SDK provides customization point via the componentFactory property of PhoneIdService instance.
In customize colors&background can be done in two steps:

1) implement your own component factory (or inherit from DefaultComponentFactory) and override methods with your settings:
```swift
class CustomComponentFactory:DefaultComponentFactory{
    
    override func defaultBackgroundImage()->UIImage{
        return UIImage(named:"background")!
    }
    
    override func colorScheme()->ColorScheme{
        let scheme = super.colorScheme()
        scheme.mainAccent = UIColor(netHex: 0x357AAE)
        scheme.selectedText = UIColor(netHex: 0x4192C7)
        scheme.linkText = UIColor(netHex: 0x4192C7)
        return scheme
    }
}
``` 

2) set your own component factory to phoneid service:
```swift
PhoneIdService.sharedInstance.componentFactory = CustomComponentFactory()
``` 

Cutomization results:

![phoneId](http://i284.photobucket.com/albums/ll39/streamlet10/Simulator%20Screen%20Shot%20Jul%2021%202015%203.31.50%20PM_zpslriy7l9s.png).
![phoneId](http://i284.photobucket.com/albums/ll39/streamlet10/Simulator%20Screen%20Shot%20Jul%2021%202015%203.31.59%20PM_zpsmtu7ng62.png)

## Author

Federico Pomi, federico@pomi.net

## License

phoneid_iOS is available under the Apache License Version 2.0. See the LICENSE file for more info.
