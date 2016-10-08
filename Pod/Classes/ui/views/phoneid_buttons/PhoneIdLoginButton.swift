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


@IBDesignable open class PhoneIdLoginButton: UIControl, Customizable {

    open var colorScheme: ColorScheme!
    open var localizationBundle: Bundle!
    open var localizationTableName: String!

    open var phoneNumberE164: String!

    open fileprivate(set) var imageView: UIImageView = {
        let image = UIImage(namedInPhoneId: "phone")!.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        return UIImageView(image:image)
    }()
    
    open fileprivate(set) var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.systemFont(ofSize: 20)
        titleLabel.textColor = UIColor.white
        titleLabel.text = "Login with phone.id"
        return titleLabel
    }()
    
    open fileprivate(set) var separatorView: UIView = {
        let separatorView = UIView()
        return separatorView
    }()
    
    open fileprivate(set) var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()

    fileprivate var gestureRecognizer: UITapGestureRecognizer!

    var phoneIdLoginFlowManager = PhoneIdLoginWorkflowManager()
    
    var phoneIdService: PhoneIdService! {
        return PhoneIdService.sharedInstance
    }
    
    var phoneIdComponentFactory: ComponentFactory! {
        return phoneIdService.componentFactory
    }

    fileprivate var titleColors: [UInt:UIColor] = [:];
    fileprivate var imageColors: [UInt:UIColor] = [:];
    fileprivate var backgroundColors: [UInt:UIColor] = [:];


    open func setTitleColor(_ color: UIColor?, forState state: UIControlState) {
        titleColors[state.rawValue] = color
        if (state == self.state) {
            titleLabel.textColor = color
        }
    }

    open func setImageColor(_ color: UIColor?, forState state: UIControlState) {
        imageColors[state.rawValue] = color
        if (state == self.state) {
            imageView.tintColor = color
        }
    }

    open func setBackgroundColor(_ color: UIColor?, forState state: UIControlState) {
        backgroundColors[state.rawValue] = color
        if (state == self.state) {
            backgroundColor = color
        }
    }

    override open var isEnabled: Bool {
        didSet {
            updateColors()
        }
    }
    override open var isHighlighted: Bool {
        didSet {
            updateColors()
        }
    }

    func setupDefaultColors() {
        separatorView.backgroundColor = colorScheme.buttonSeparator
        
        backgroundColors = [
                UIControlState().rawValue: colorScheme.buttonNormalBackground,
                UIControlState.disabled.rawValue: colorScheme.buttonDisabledBackground,
                UIControlState.highlighted.rawValue: colorScheme.buttonHighlightedBackground,
                UIControlState.selected.rawValue: colorScheme.buttonNormalBackground
        ]
        imageColors = [
                UIControlState().rawValue: colorScheme.buttonNormalImage,
                UIControlState.disabled.rawValue: colorScheme.buttonDisabledImage,
                UIControlState.highlighted.rawValue: colorScheme.buttonHighlightedImage,
                UIControlState.selected.rawValue: colorScheme.buttonNormalImage
        ]
        titleColors = [
                UIControlState().rawValue: colorScheme.buttonNormalText,
                UIControlState.disabled.rawValue: colorScheme.buttonDisabledText,
                UIControlState.highlighted.rawValue: colorScheme.buttonHighlightedText,
                UIControlState.selected.rawValue: colorScheme.buttonNormalText
        ]

    }

    func updateColors() {

        var clearState: UIControlState = UIControlState();
        if (self.state.contains(UIControlState.disabled)) {
            clearState = UIControlState.disabled
        } else if (self.state.contains(UIControlState.highlighted)) {
            clearState = UIControlState.highlighted
        }


        backgroundColor = backgroundColors[clearState.rawValue]
        imageView.tintColor = imageColors[clearState.rawValue]
        titleLabel.textColor = titleColors[clearState.rawValue]
        activityIndicator.color = colorScheme.activityIndicatorInitial
    }


    init(frame: CGRect, designtime:Bool) {
        super.init(frame: frame)
        prep()
        initUI(designtime:designtime)
    }

    init?(coder aDecoder: NSCoder, designtime:Bool) {
        super.init(coder: aDecoder)
        prep()
        initUI(designtime:designtime)
    }
    
    // init from viewcontroller
    required override public convenience init(frame: CGRect) {
        self.init(frame:frame, designtime:false)
    }

    // init from interface builder
    required public convenience init?(coder aDecoder: NSCoder) {
        self.init(coder:aDecoder, designtime:false)
    }

    override open func prepareForInterfaceBuilder() {
        self.prep()
        initUI(designtime:true)
    }

    func prep() {
        localizationBundle = phoneIdComponentFactory.localizationBundle
        localizationTableName = phoneIdComponentFactory.localizationTableName
        colorScheme = phoneIdComponentFactory.colorScheme
            
        let notificator = NotificationCenter.default
        notificator.addObserver(self, selector: #selector(PhoneIdLoginButton.doOnSuccessfulLogin), name: NSNotification.Name(rawValue: Notifications.VerificationSuccess), object: nil)
        notificator.addObserver(self, selector: #selector(PhoneIdLoginButton.doOnlogout), name: NSNotification.Name(rawValue: Notifications.DidLogout), object: nil)
    }

    func initUI(designtime:Bool) {

        self.translatesAutoresizingMaskIntoConstraints = false
        
        layer.cornerRadius = 3
        layer.masksToBounds = true

        let subviews: [UIView] = [imageView, titleLabel, separatorView, activityIndicator]

        for (_, element) in subviews.enumerated() {
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

        addConstraint(NSLayoutConstraint(item: imageView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: imageView, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: padding))
        addConstraint(NSLayoutConstraint(item: imageView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: 20))
        addConstraint(NSLayoutConstraint(item: imageView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 20))

        addConstraint(NSLayoutConstraint(item: separatorView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: 1))
        addConstraint(NSLayoutConstraint(item: separatorView, attribute: .height, relatedBy: .equal, toItem: self, attribute: .height, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: separatorView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: separatorView, attribute: .left, relatedBy: .equal, toItem: imageView, attribute: .right, multiplier: 1, constant: padding))

        addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .left, relatedBy: .equal, toItem: separatorView, attribute: .left, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .right, relatedBy: .equal, toItem: activityIndicator, attribute: .right, multiplier: 1, constant: 0))

        addConstraint(NSLayoutConstraint(item: activityIndicator, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1, constant: -7))
        addConstraint(NSLayoutConstraint(item: activityIndicator, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
    }

    func configureButton(_ isLoggedIn: Bool) {


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
        NotificationCenter.default.removeObserver(self)
    }

    open override var intrinsicContentSize : CGSize {
        return CGSize(width: 280, height: 48)
    }

    override open class var requiresConstraintBasedLayout : Bool {
        return true
    }
    
    func loginTouched(){
       
        phoneIdLoginFlowManager.login(presentFromController:self.window!.rootViewController!
            , initialPhoneNumerE164:self.phoneNumberE164
            , lock: { _ in
                self.isUserInteractionEnabled = false
            }, unlock: { _ in
                self.isUserInteractionEnabled = true
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
