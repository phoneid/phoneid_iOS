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


    public private(set) var imageView: UIImageView!
    public private(set) var titleLabel: UILabel!
    public private(set) var separatorView: UIView!
    public private(set) var activityIndicator: UIActivityIndicatorView!

    private var gestureRecognizer: UITapGestureRecognizer!


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
            titleLabel?.textColor = color
        }
    }

    public func setImageColor(color: UIColor?, forState state: UIControlState) {
        imageColors[state.rawValue] = color
        if (state == self.state) {
            imageView?.tintColor = color
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
        initUI()
    }

    func prep() {
        localizationBundle = phoneIdComponentFactory.localizationBundle
        localizationTableName = phoneIdComponentFactory.localizationTableName
        colorScheme = phoneIdComponentFactory.colorScheme

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "doOnSuccessfulLogin", name: Notifications.VerificationSuccess, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "doOnlogout", name: Notifications.DidLogout, object: nil)
    }

    func initUI() {

        self.translatesAutoresizingMaskIntoConstraints = false

        self.accessibilityActivate()

        imageView = UIImageView(image: UIImage(namedInPhoneId: "phone")!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate))

        titleLabel = UILabel()
        separatorView = UIView()
        separatorView.backgroundColor = colorScheme.buttonSeparator

        titleLabel.font = UIFont.systemFontOfSize(20)

        layer.cornerRadius = 3
        layer.masksToBounds = true

        activityIndicator = UIActivityIndicatorView()

        let subviews: [UIView] = [imageView, titleLabel, separatorView, activityIndicator]

        for (_, element) in subviews.enumerate() {
            element.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview(element)
        }

        setupLayout()

        configureButton(phoneIdService.isLoggedIn)

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


        if ((gestureRecognizer) != nil) {
            self.removeGestureRecognizer(gestureRecognizer)
        }

        gestureRecognizer = UITapGestureRecognizer(target: self, action: isLoggedIn ? "logoutTouched" : "loginTouched")
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


    func loginTouched() {

        self.userInteractionEnabled = false

        if (phoneIdService.clientId == nil) {
            fatalError("Phone.id is not configured for use: clientId is not set. Please call configureClient(clientId) first")
        }


        if (phoneIdService.appName != nil) {
            self.presentLoginViewController()
            self.userInteractionEnabled = true
        } else {
            activityIndicator.startAnimating()
            phoneIdService.loadClients(phoneIdService.clientId!, completion: {
                (error) -> Void in

                self.activityIndicator.stopAnimating()

                if (error == nil) {
                    self.presentLoginViewController()
                } else {
                    if (error != nil) {
                        let alertController = UIAlertController(title: error?.localizedDescription, message: error?.localizedFailureReason, preferredStyle: .Alert)

                        alertController.addAction(UIAlertAction(title: self.localizedString("alert.button.title.dismiss"), style: .Cancel, handler: nil));
                        self.window?.rootViewController?.presentViewController(alertController, animated: true, completion: nil)
                    }
                }
                self.userInteractionEnabled = true
            })
        }

    }


    func logoutTouched() {
        phoneIdService.logout()
    }

    private func presentLoginViewController() {

        let controller = phoneIdComponentFactory.loginViewController()

        let navigation = UINavigationController(rootViewController: controller)
        navigation.navigationBar.hidden = true

        if let phoneNumberE164 = phoneNumberE164 {
            controller.phoneIdModel = NumberInfo(numberE164: phoneNumberE164)
        }


        let phoneIdWindow = PhoneIdWindow()

        phoneIdWindow.makeActive()

        phoneIdWindow.rootViewController?.presentViewController(navigation, animated: true, completion: nil)

    }

    // MARK: Notification handlers

    func doOnSuccessfulLogin() -> Void {
        configureButton(phoneIdService.isLoggedIn)
    }

    func doOnlogout() -> Void {
        configureButton(phoneIdService.isLoggedIn)
    }

}