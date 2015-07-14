//
//  PhoneIdLoginButton.swift
//  PhoneIdSDK
//
//  Created by Alyona on 7/1/15.
//  Copyright © 2015 phoneId. All rights reserved.
//

import Foundation


//TODO: add possibility to style differently depending on login/logout state

@IBDesignable public class PhoneIdLoginButton: UIButton, Customizable {
    
    public var colorScheme: ColorScheme!
    public var localizationBundle:NSBundle!
    public var localizationTableName:String!
    
    
    var phoneIdService: PhoneIdService! { return PhoneIdService.sharedInstance}
    var phoneIdComponentFactory: ComponentFactory! { return phoneIdService.componentFactory}
    
    var activityIndicator:UIActivityIndicatorView!
    
    // init from viewcontroller
    required override public init(frame: CGRect) {
        super.init(frame: frame)
        prep()
        initUI()
    }
    
    // init from interface builder
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        prep()
        initUI();
    }
    
    override public func prepareForInterfaceBuilder() {
        self.prep()
        initUI();
    }
    
    func prep(){
        localizationBundle = phoneIdComponentFactory.localizationBundle()
        localizationTableName = phoneIdComponentFactory.localizationTableName()
        colorScheme = phoneIdComponentFactory.colorScheme()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "doOnSuccessfulLogin", name: Notifications.VerificationSuccess, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "doOnlogout", name: Notifications.DidLogout, object: nil)
    }
    
    // TODO: respect logged in state when init UI
    func initUI() {
        let bgImage:UIImage = UIImage(namedInPhoneId: "phone")!
        
        setTitleColor(UIColor.whiteColor(), forState: .Normal)
        titleLabel?.font = UIFont.systemFontOfSize(20)
        
        setBackgroundImage(bgImage, forState:UIControlState.Normal)
        backgroundColor = colorScheme.mainAccent
        layer.cornerRadius = 3
        layer.masksToBounds = true
        
        activityIndicator = UIActivityIndicatorView()
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        addSubview(self.activityIndicator)
        
        addConstraint(NSLayoutConstraint(item: activityIndicator, attribute: .Right, relatedBy: .Equal, toItem: self, attribute: .Right, multiplier: 1, constant:-5))
        addConstraint(NSLayoutConstraint(item: activityIndicator, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1, constant:0))
        
        configureButton(phoneIdService.isLoggedIn)
        
    }
    
    func configureButton(isLoggedIn:Bool){
        self.removeTarget(self, action: nil, forControlEvents: .TouchUpInside)
        if(isLoggedIn){
            self.setTitle(localizedString("button.title.logged.in"), forState:UIControlState.Normal)
            self.addTarget(self, action:"loggedInTouched", forControlEvents: .TouchUpInside)
        }else{
            setTitle(localizedString("button.title.login.with.phone.id"), forState: .Normal)
            addTarget(self, action:"loginTouched", forControlEvents: .TouchUpInside)
        }
        
    }
    
    deinit{
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func loginTouched() {
        
        if(phoneIdService.clientId == nil){
            fatalError("Phone.id is not configured for use: clientId is not set. Please call configureClient(clientId) first")
        }
        
        
        if(phoneIdService.appName != nil){
            self.presentNumberInputController()
        }else{
            activityIndicator.startAnimating()
            phoneIdService.loadClients(phoneIdService.clientId!, completion: { [unowned self] (error) -> Void in
                
                self.activityIndicator.stopAnimating()
                
                if(error == nil){
                    self.presentNumberInputController()
                }else{
                    if(error != nil){
                        let alertController = UIAlertController(title:error?.localizedDescription, message:error?.localizedFailureReason, preferredStyle: .Alert)
                        
                        alertController.addAction(UIAlertAction(title:self.localizedString("button.title.dismiss"), style: .Cancel, handler:nil));
                        self.window?.rootViewController?.presentViewController(alertController, animated: true, completion:nil)
                    }
                }
                })
        }
    }
    
    
    private func loggedInTouched() {
        print("already logged in with phone id")
    }
    
    private func presentNumberInputController(){
        
        let controller = phoneIdComponentFactory.numberInputViewController()
        window?.rootViewController?.presentViewController(controller, animated: true, completion: nil)
    }
    
    // MARK: Notification handlers
    
    func doOnSuccessfulLogin() -> Void {
        configureButton(phoneIdService.isLoggedIn)
    }
    
    func doOnlogout() -> Void {
        configureButton(phoneIdService.isLoggedIn)
    }
    
    
}