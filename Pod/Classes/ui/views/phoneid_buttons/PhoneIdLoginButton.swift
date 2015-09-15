//
//  PhoneIdLoginButton.swift
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



import Foundation


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
    
    func initUI() {
        let bgImage:UIImage = UIImage(namedInPhoneId: "phone")!
        
        self.accessibilityActivate()
        
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
            setAttributedTitle(localizedStringAttributed("html-button.title.logout"), forState:UIControlState.Normal)
            self.accessibilityLabel = localizedString("accessibility.button.title.logout")
            addTarget(self, action:"logoutTouched", forControlEvents: .TouchUpInside)
        }else{
            setAttributedTitle(localizedStringAttributed("html-button.title.login.with.phone.id"), forState: .Normal)
            self.accessibilityLabel = localizedString("accessibility.title.login.with.phone.id")
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
            phoneIdService.loadClients(phoneIdService.clientId!, completion: {(error) -> Void in
                
                self.activityIndicator.stopAnimating()
                
                if(error == nil){
                    self.presentNumberInputController()
                }else{
                    if(error != nil){
                        let alertController = UIAlertController(title:error?.localizedDescription, message:error?.localizedFailureReason, preferredStyle: .Alert)
                        
                        alertController.addAction(UIAlertAction(title:self.localizedString("alert.button.title.dismiss"), style: .Cancel, handler:nil));
                        self.window?.rootViewController?.presentViewController(alertController, animated: true, completion:nil)
                    }
                }
                })
        }
    }
    
    
    func logoutTouched() {
        phoneIdService.logout()
    }
    
    private func presentNumberInputController(){
        
        let controller = phoneIdComponentFactory.numberInputViewController()
        
        let phoneIdWindow = PhoneIdWindow()
        
        phoneIdWindow.makeActive()
        
        phoneIdWindow.rootViewController?.presentViewController(controller, animated: true, completion: nil)
        
  }
    
    // MARK: Notification handlers
    
    func doOnSuccessfulLogin() -> Void {
        configureButton(phoneIdService.isLoggedIn)
    }
    
    func doOnlogout() -> Void {
        configureButton(phoneIdService.isLoggedIn)
    }
    
    
}