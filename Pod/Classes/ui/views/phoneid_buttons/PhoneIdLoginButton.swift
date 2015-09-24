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


@IBDesignable public class PhoneIdLoginButton: UIView, Customizable {
    
    public var colorScheme: ColorScheme!
    public var localizationBundle:NSBundle!
    public var localizationTableName:String!
    
    private(set) var imageView:UIImageView!
    private(set) var titleLabel:UILabel!
    private(set) var separatorView:UIView!
    
    private var gestureRecognizer:UITapGestureRecognizer!
    
    
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
        initUI()
    }
    
    override public func prepareForInterfaceBuilder() {
        self.prep()
        initUI()
    }
    
    func prep(){
        localizationBundle = phoneIdComponentFactory.localizationBundle()
        localizationTableName = phoneIdComponentFactory.localizationTableName()
        colorScheme = phoneIdComponentFactory.colorScheme()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "doOnSuccessfulLogin", name: Notifications.VerificationSuccess, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "doOnlogout", name: Notifications.DidLogout, object: nil)
    }
    
    func initUI() {
        //let bgImage:UIImage = UIImage(namedInPhoneId: "phone")!
        self.translatesAutoresizingMaskIntoConstraints = false
        
        self.accessibilityActivate()
        
        imageView = UIImageView(image: UIImage(namedInPhoneId: "phone")!)
        titleLabel = UILabel()
        separatorView = UIView()
        separatorView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.12)
        
        titleLabel.textColor = UIColor.whiteColor()
        titleLabel.font = UIFont.systemFontOfSize(20)
        
        backgroundColor = colorScheme.mainAccent
        layer.cornerRadius = 3
        layer.masksToBounds = true
        
        activityIndicator = UIActivityIndicatorView()
        
        let subviews:[UIView] = [imageView, titleLabel, separatorView, activityIndicator]
        
        for(_, element) in subviews.enumerate(){
            element.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview(element)
        }
        
        setupLayout()
        
        configureButton(phoneIdService.isLoggedIn)
        
    }
    
    func setupLayout(){
        
        let padding:CGFloat = 14
        
        addConstraint(NSLayoutConstraint(item: imageView, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1, constant:0))
        addConstraint(NSLayoutConstraint(item: imageView, attribute: .Left, relatedBy: .Equal, toItem: self, attribute: .Left, multiplier: 1, constant:padding))
        addConstraint(NSLayoutConstraint(item: imageView, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .Width, multiplier: 1, constant:20))
        addConstraint(NSLayoutConstraint(item: imageView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .Height, multiplier: 1, constant:20))
        
        addConstraint(NSLayoutConstraint(item: separatorView, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .Width, multiplier: 1, constant:1))
        addConstraint(NSLayoutConstraint(item: separatorView, attribute: .Height, relatedBy: .Equal, toItem: self, attribute: .Height, multiplier: 1, constant:0))
        addConstraint(NSLayoutConstraint(item: separatorView, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1, constant:0))
        addConstraint(NSLayoutConstraint(item: separatorView, attribute: .Left, relatedBy: .Equal, toItem: imageView, attribute: .Right, multiplier: 1, constant:padding))
        
        addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .Left, relatedBy: .Equal, toItem: separatorView, attribute: .Left, multiplier: 1, constant:0))
        addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1, constant:0))
        addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .Right, relatedBy: .Equal, toItem: activityIndicator, attribute: .Right, multiplier: 1, constant:0))
        
        addConstraint(NSLayoutConstraint(item: activityIndicator, attribute: .Right, relatedBy: .Equal, toItem: self, attribute: .Right, multiplier: 1, constant:-7))
        addConstraint(NSLayoutConstraint(item: activityIndicator, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1, constant:0))
    }
    
    func configureButton(isLoggedIn:Bool){
        
        
        if((gestureRecognizer) != nil) {
            self.removeGestureRecognizer(gestureRecognizer)
        }
        
        gestureRecognizer = UITapGestureRecognizer(target: self, action: isLoggedIn ? "logoutTouched" : "loginTouched")
        self.addGestureRecognizer(gestureRecognizer)
        
        if(isLoggedIn){
            
            titleLabel.attributedText = localizedStringAttributed("html-button.title.logout")
            self.accessibilityLabel = localizedString("accessibility.button.title.logout")
            
        }else{
            titleLabel.attributedText = localizedStringAttributed("html-button.title.login.with.phone.id")
            self.accessibilityLabel = localizedString("accessibility.title.login.with.phone.id")
            
        }
        
    }
    
    deinit{
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    
    public override func intrinsicContentSize() -> CGSize {
        return CGSizeMake(UIViewNoIntrinsicMetric, 48)
    }
    
    override public class func requiresConstraintBasedLayout() -> Bool {
        return true
    }
    
    
    func loginTouched() {
        
        indicateTap(false)
        
        self.userInteractionEnabled = false
        
        if(phoneIdService.clientId == nil){
            fatalError("Phone.id is not configured for use: clientId is not set. Please call configureClient(clientId) first")
        }
        
        
        if(phoneIdService.appName != nil){
            self.presentNumberInputController()
            self.userInteractionEnabled = true
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
                self.userInteractionEnabled = true
            })
        }
        
    }
    
    
    func logoutTouched() {
        indicateTap(false)
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
    
    override public func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        indicateTap(true)
    }
    
    public override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        indicateTap(false)
    }
    
    func indicateTap(pressed:Bool){
        titleLabel.textColor = UIColor.whiteColor().colorWithAlphaComponent(pressed ? 0.7 : 1)
    }
    
}