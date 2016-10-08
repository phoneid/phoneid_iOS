//
//  PhoneIdBaseView.swift
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

open class PhoneIdBaseView: UIView, Customizable, PhoneIdConsumer {

    open var phoneIdModel: NumberInfo!
    open var colorScheme: ColorScheme!
    open var localizationBundle: Bundle!
    open var localizationTableName: String!

    init(model: NumberInfo, scheme: ColorScheme, bundle: Bundle, tableName: String) {

        super.init(frame: CGRect.zero)

        phoneIdModel = model
        colorScheme = scheme
        localizationBundle = bundle
        localizationTableName = tableName

        doOnInit()
    }

    override public init(frame: CGRect) {
        super.init(frame: frame)
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func doOnInit() {
        setupSubviews()
        setupLayout()
        setupWithModel(self.phoneIdModel)
        localizeAndApplyColorScheme()
    }

    func setupSubviews() {

    }

    func setupLayout() {

    }

    func setupWithModel(_ model: NumberInfo) {
        self.phoneIdModel = model
    }

    func localizeAndApplyColorScheme() {

    }

    func closeButtonTapped() {

    }

}

open class PhoneIdBaseFullscreenView: PhoneIdBaseView {

    fileprivate(set) var closeButton: UIButton!
    fileprivate(set) var titleLabel: UILabel!
    fileprivate(set) var headerBackgroundView: UIView!
    fileprivate(set) var backgroundView: UIImageView!

    func backgroundImage() -> UIImage? {
        return phoneIdComponentFactory.defaultBackgroundImage
    }

    var customConstraints: [NSLayoutConstraint] = []

    override init(model: NumberInfo, scheme: ColorScheme, bundle: Bundle, tableName: String) {
        super.init(model: model, scheme: scheme, bundle: bundle, tableName: tableName)
    }

    override public init(frame: CGRect) {
        super.init(frame: frame)
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }


    override func setupSubviews() {
        backgroundView = UIImageView()
        headerBackgroundView = UIView()
        closeButton = UIButton(type: .system)

        closeButton.addTarget(self, action: #selector(PhoneIdBaseView.closeButtonTapped), for: .touchUpInside)

        titleLabel = UILabel()

        let views = [backgroundView, headerBackgroundView, closeButton, titleLabel]
        for view in views {
            view?.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview(view!)
        }

    }

    override func setupLayout() {
        self.removeConstraints(self.customConstraints)
        self.customConstraints = []

        var c: [NSLayoutConstraint] = []

        c.append(NSLayoutConstraint(item: titleLabel, attribute: .centerY, relatedBy: .equal, toItem: headerBackgroundView, attribute: .centerY, multiplier: 1, constant: 10))
        c.append(NSLayoutConstraint(item: titleLabel, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0))
        c.append(NSLayoutConstraint(item: titleLabel, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 0.8, constant: 0))

        c.append(NSLayoutConstraint(item: headerBackgroundView, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 1, constant: 0))
        c.append(NSLayoutConstraint(item: headerBackgroundView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 64))
        c.append(NSLayoutConstraint(item: headerBackgroundView, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0))
        c.append(NSLayoutConstraint(item: headerBackgroundView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0))

        c.append(NSLayoutConstraint(item: backgroundView, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 1, constant: 0))
        c.append(NSLayoutConstraint(item: backgroundView, attribute: .height, relatedBy: .equal, toItem: self, attribute: .height, multiplier: 1, constant: 0))
        c.append(NSLayoutConstraint(item: backgroundView, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0))
        c.append(NSLayoutConstraint(item: backgroundView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))

        c.append(NSLayoutConstraint(item: closeButton, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: 10))
        c.append(NSLayoutConstraint(item: closeButton, attribute: .lastBaseline, relatedBy: .equal, toItem: titleLabel, attribute: .lastBaseline, multiplier: 1, constant: 0))

        self.customConstraints = c
        self.addConstraints(c)
    }

    override func localizeAndApplyColorScheme() {
        super.localizeAndApplyColorScheme()
        closeButton.tintColor = colorScheme.headerButtonText
        closeButton.accessibilityLabel = localizedString("accessibility.button.title.cancel")
        closeButton.setTitle(localizedString("button.title.cancel"), for: UIControlState())
        headerBackgroundView.backgroundColor = colorScheme.headerBackground
        backgroundView.backgroundColor = colorScheme.mainViewBackground
        backgroundView.image = backgroundImage()
    }

}
