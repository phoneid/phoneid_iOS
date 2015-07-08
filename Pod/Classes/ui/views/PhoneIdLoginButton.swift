//
//  PhoneIdLoginButton.swift
//  PhoneIdSDK
//
//  Created by Alyona on 7/1/15.
//  Copyright © 2015 phoneId. All rights reserved.
//

import Foundation


@IBDesignable public class PhoneIdLoginButton: UIButton, Customizable {

    public var colorScheme: ColorScheme!
    public var localizationBundle:NSBundle!
    public var localizationTableName:String!
    
    var phoneIdService: PhoneIdService! { return PhoneIdService.sharedInstance}
    var phoneIdComponentFactory: ComponentFactory! { return phoneIdService.componentFactory}
    
    // init from viewcontroller
    required override public init(frame: CGRect) {
        super.init(frame: frame)
        prep()
        initUI()
    }
    
    // init from interface builder
    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        prep()
        initUI();
    }
    
    func prep(){
        localizationBundle = phoneIdComponentFactory.localizationBundle()
        localizationTableName = phoneIdComponentFactory.localizationTableName()
        colorScheme = phoneIdComponentFactory.colorScheme()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "appNameUpdated", name: Notifications.UpdateAppName, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "PhoneIdAccessOk:", name: Notifications.LoginSuccess, object: nil)
    }
    
    func initUI() {
        let bgImage:UIImage = UIImage(namedInPhoneId: "phone")!
        self.setTitle(localizedString("button.title.login.with.phone.id"), forState: .Normal)
        self.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        self.titleLabel?.font = UIFont.systemFontOfSize(20)
        
        self.setBackgroundImage(bgImage, forState:UIControlState.Normal)
        self.addTarget(self, action:"loginTouched", forControlEvents: .TouchUpInside)
        
        self.backgroundColor = colorScheme.mainAccent
        
        self.layer.cornerRadius = 3
        self.layer.masksToBounds = true
    }
    
    deinit{
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func appNameUpdated(){
        self.userInteractionEnabled = true
    }
    
    func loginTouched() {
        
        if(phoneIdService.clientId == nil){
            fatalError("Phone.id is not configured for use: clientId is not set. Please call configureClient(clientId) first")
        }
        
        
        if(phoneIdService.appName != nil){
            self.presentNumberInputController()
        }else{
            phoneIdService.loadClients(phoneIdService.clientId!, completion: { [unowned self] (error) -> Void in
                if(error == nil){
                    self.presentNumberInputController()
                }else{
                    if(error != nil){
                        let alertController = UIAlertController(title:error?.localizedDescription, message:error?.localizedFailureReason, preferredStyle: .Alert)
                        
                        alertController.addAction(UIAlertAction(title: "Dismiss", style: .Cancel, handler:nil));
                        self.window?.rootViewController?.presentViewController(alertController, animated: true, completion:nil)
                    }
                }
            })
        }
    }
    
    private func presentNumberInputController(){
        let controller = phoneIdComponentFactory.numberInputViewController()
        window?.rootViewController?.presentViewController(controller, animated: true, completion: nil)
    }
    
    func loggedInTouched() {
        NSLog("already logged")
    }
    
    //TODO: complete refactoring of this control
    
    func PhoneIdAccessOk(notification:NSNotification) -> Void {
        self.setTitle(localizedString("button.title.logged.in"), forState:UIControlState.Normal)
        self.removeTarget(self, action:"loginTouched", forControlEvents: .TouchUpInside)
        self.addTarget(self, action:"loggedInTouched", forControlEvents: .TouchUpInside)
    }
    
    
}