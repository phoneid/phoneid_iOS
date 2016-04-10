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


@IBDesignable public class PhoneIdLoginButton: UIControl, Customizable {

    public var colorScheme: ColorScheme!
    public var localizationBundle: NSBundle!
    public var localizationTableName: String!

    public var phoneNumberE164: String!

    public private(set) var imageView: UIImageView = {
        let image = UIImage(namedInPhoneId: "phone")!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        return UIImageView(image:image)
    }()
    
    public private(set) var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.textAlignment = .Center
        titleLabel.font = UIFont.systemFontOfSize(20)
        titleLabel.textColor = UIColor.whiteColor()
        titleLabel.text = "Login with phone.id"
        return titleLabel
    }()
    
    public private(set) var separatorView: UIView = {
        let separatorView = UIView()
        return separatorView
    }()
    
    public private(set) var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()

    private var gestureRecognizer: UITapGestureRecognizer!

    var phoneIdLoginFlowManager = PhoneIdLoginWorkflowManager()
    
    var phoneIdService: PhoneIdService! {
        return PhoneIdService.sharedInstance
    }
    
    var phoneIdComponentFactory: ComponentFactory! {
        return phoneIdService.componentFactory
    }

    private var titleColors: [UInt:UIColor] = [:];
    private var imageColors: [UInt:UIColor] = [:];
    private var backgroundColors: [UInt:UIColor] = [:];


    public func setTitleColor(color: UIColor?, forState state: UIControlState) {
        titleColors[state.rawValue] = color
        if (state == self.state) {
            titleLabel.textColor = color
        }
    }

    public func setImageColor(color: UIColor?, forState state: UIControlState) {
        imageColors[state.rawValue] = color
        if (state == self.state) {
            imageView.tintColor = color
        }
    }

    public func setBackgroundColor(color: UIColor?, forState state: UIControlState) {
        backgroundColors[state.rawValue] = color
        if (state == self.state) {
            backgroundColor = color
        }
    }

    override public var enabled: Bool {
        didSet {
            updateColors()
        }
    }
    override public var highlighted: Bool {
        didSet {
            updateColors()
        }
    }

    func setupDefaultColors() {
        separatorView.backgroundColor = colorScheme.buttonSeparator
        
        backgroundColors = [
                UIControlState.Normal.rawValue: colorScheme.buttonNormalBackground,
                UIControlState.Disabled.rawValue: colorScheme.buttonDisabledBackground,
                UIControlState.Highlighted.rawValue: colorScheme.buttonHighlightedBackground,
                UIControlState.Selected.rawValue: colorScheme.buttonNormalBackground
        ]
        imageColors = [
                UIControlState.Normal.rawValue: colorScheme.buttonNormalImage,
                UIControlState.Disabled.rawValue: colorScheme.buttonDisabledImage,
                UIControlState.Highlighted.rawValue: colorScheme.buttonHighlightedImage,
                UIControlState.Selected.rawValue: colorScheme.buttonNormalImage
        ]
        titleColors = [
                UIControlState.Normal.rawValue: colorScheme.buttonNormalText,
                UIControlState.Disabled.rawValue: colorScheme.buttonDisabledText,
                UIControlState.Highlighted.rawValue: colorScheme.buttonHighlightedText,
                UIControlState.Selected.rawValue: colorScheme.buttonNormalText
        ]

    }

    func updateColors() {

        var clearState: UIControlState = .Normal;
        if (self.state.contains(UIControlState.Disabled)) {
            clearState = UIControlState.Disabled
        } else if (self.state.contains(UIControlState.Highlighted)) {
            clearState = UIControlState.Highlighted
        }


        backgroundColor = backgroundColors[clearState.rawValue]
        imageView.tintColor = imageColors[clearState.rawValue]
        titleLabel.textColor = titleColors[clearState.rawValue]
        activityIndicator.color = colorScheme.activityIndicatorInitial
    }

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
        initUI(designtime:true)
    }

    func prep() {
        localizationBundle = phoneIdComponentFactory.localizationBundle
        localizationTableName = phoneIdComponentFactory.localizationTableName
        colorScheme = phoneIdComponentFactory.colorScheme
            
        let notificator = NSNotificationCenter.defaultCenter()
        notificator.addObserver(self, selector: #selector(PhoneIdLoginButton.doOnSuccessfulLogin), name: Notifications.VerificationSuccess, object: nil)
        notificator.addObserver(self, selector: #selector(PhoneIdLoginButton.doOnlogout), name: Notifications.DidLogout, object: nil)
    }

    func initUI(designtime designtime:Bool = false) {

        self.translatesAutoresizingMaskIntoConstraints = false
        
        layer.cornerRadius = 3
        layer.masksToBounds = true

        let subviews: [UIView] = [imageView, titleLabel, separatorView, activityIndicator]

        for (_, element) in subviews.enumerate() {
            element.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview(element)
        }

        setupLayout()

        if !designtime {
            configureButton(phoneIdService.isLoggedIn)
        }

        setupDefaultColors()

        updateColors()

    }

    func setupLayout() {

        let padding: CGFloat = 14

        addConstraint(NSLayoutConstraint(item: imageView, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: imageView, attribute: .Left, relatedBy: .Equal, toItem: self, attribute: .Left, multiplier: 1, constant: padding))
        addConstraint(NSLayoutConstraint(item: imageView, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .Width, multiplier: 1, constant: 20))
        addConstraint(NSLayoutConstraint(item: imageView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .Height, multiplier: 1, constant: 20))

        addConstraint(NSLayoutConstraint(item: separatorView, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .Width, multiplier: 1, constant: 1))
        addConstraint(NSLayoutConstraint(item: separatorView, attribute: .Height, relatedBy: .Equal, toItem: self, attribute: .Height, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: separatorView, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: separatorView, attribute: .Left, relatedBy: .Equal, toItem: imageView, attribute: .Right, multiplier: 1, constant: padding))

        addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .Left, relatedBy: .Equal, toItem: separatorView, attribute: .Left, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .Right, relatedBy: .Equal, toItem: activityIndicator, attribute: .Right, multiplier: 1, constant: 0))

        addConstraint(NSLayoutConstraint(item: activityIndicator, attribute: .Right, relatedBy: .Equal, toItem: self, attribute: .Right, multiplier: 1, constant: -7))
        addConstraint(NSLayoutConstraint(item: activityIndicator, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1, constant: 0))
    }

    func configureButton(isLoggedIn: Bool) {


        if let _ = gestureRecognizer {
            self.removeGestureRecognizer(gestureRecognizer)
        }

        let loginSelector = #selector(PhoneIdLoginButton.loginTouched)
        let logoutSelector = #selector(PhoneIdLoginButton.logoutTouched)
        gestureRecognizer = UITapGestureRecognizer(target: self, action: isLoggedIn ? logoutSelector : loginSelector)
        self.addGestureRecognizer(gestureRecognizer)

        if (isLoggedIn) {

            titleLabel.attributedText = localizedStringAttributed("html-button.title.logout")
            self.accessibilityLabel = localizedString("accessibility.button.title.logout")

        } else {
            titleLabel.attributedText = localizedStringAttributed("html-button.title.login.with.phone.id")
            self.accessibilityLabel = localizedString("accessibility.title.login.with.phone.id")
        }

    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    public override func intrinsicContentSize() -> CGSize {
        return CGSizeMake(UIViewNoIntrinsicMetric, 48)
    }

    override public class func requiresConstraintBasedLayout() -> Bool {
        return true
    }
    
    func loginTouched(){
       
        phoneIdLoginFlowManager.login(presentFromController:self.window!.rootViewController!
            , initialPhoneNumerE164:self.phoneNumberE164
            , lock: { _ in
                self.userInteractionEnabled = false
            }, unlock: { _ in
                self.userInteractionEnabled = true
            }, startAnimatingProgress: { _ in
                self.activityIndicator.startAnimating()
            }, stopAnimationProgress: { _ in
                self.activityIndicator.stopAnimating()
        })
    
    }

    func logoutTouched() {
        phoneIdService.logout()
    }
    
    // MARK: Notification handlers

    func doOnSuccessfulLogin() -> Void {
        configureButton(phoneIdService.isLoggedIn)
    }

    func doOnlogout() -> Void {
        configureButton(phoneIdService.isLoggedIn)
    }

}
