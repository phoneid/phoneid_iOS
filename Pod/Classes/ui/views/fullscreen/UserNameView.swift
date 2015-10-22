//
//  UserNameView.swift
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
import UIKit

public protocol UserNameViewDelegate: NSObjectProtocol {
    func close()

    func save()
}

public class UserNameView: PhoneIdBaseFullscreenView, UITextFieldDelegate {


    private(set) var userNameLabel: UILabel!
    private(set) var userNameField: UITextField!
    private(set) var noteLabel: UILabel!
    private(set) var saveButton: UIButton!

    var containerView: UIView!
    internal weak var delegate: UserNameViewDelegate?

    var containerTopConstraint: NSLayoutConstraint!

    override public init(frame: CGRect) {
        super.init(frame: frame)
    }

    convenience init(userName: String?, scheme: ColorScheme, bundle: NSBundle, tableName: String) {

        self.init(frame: CGRectZero)

        colorScheme = scheme
        localizationBundle = bundle
        localizationTableName = tableName

        doOnInit()

        userNameField.text = userName
    }

    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func doOnInit() {
        setupSubviews()

        setupLayout()

        localizeAndApplyColorScheme()
    }

    internal override func setupSubviews() {

        super.setupSubviews()

        containerView = UIView()

        userNameLabel = {
            let label = UILabel()
            label.font = UIFont.boldSystemFontOfSize(17)
            label.numberOfLines = 1
            label.textColor = self.colorScheme.profileDataSectionTitleText
            label.setContentHuggingPriority(1000, forAxis: UILayoutConstraintAxis.Horizontal)
            return label
        }()


        userNameField = {
            let textField = UITextField()
            textField.delegate = self
            textField.textColor = self.colorScheme.profileDataSectionValueText
            return textField

        }()


        noteLabel = {
            let note = UILabel()
            note.numberOfLines = 0
            return note
        }()

        saveButton = {
            let saveButton = UIButton()
            saveButton.titleLabel?.textAlignment = .Left
            saveButton.addTarget(self, action: "saveTapped", forControlEvents: .TouchUpInside)
            return saveButton
        }()

        let subviews: [UIView] = [containerView, userNameLabel, userNameField, noteLabel, saveButton]
        for (_, element) in subviews.enumerate() {
            element.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview(element)
        }
    }

    override func setupLayout() {

        super.setupLayout()

        var c: [NSLayoutConstraint] = []

        c.append(NSLayoutConstraint(item: containerView, attribute: .Width, relatedBy: .Equal, toItem: self, attribute: .Width, multiplier: 1, constant: 0))
        c.append(NSLayoutConstraint(item: containerView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 44))
        c.append(NSLayoutConstraint(item: containerView, attribute: .Leading, relatedBy: .Equal, toItem: self, attribute: .Leading, multiplier: 1, constant: 0))
        c.append(NSLayoutConstraint(item: containerView, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1, constant: 74))

        c.append(NSLayoutConstraint(item: userNameLabel, attribute: .Leading, relatedBy: .Equal, toItem: self.containerView, attribute: .Leading, multiplier: 1, constant: 16))
        c.append(NSLayoutConstraint(item: userNameLabel, attribute: .CenterY, relatedBy: .Equal, toItem: self.containerView, attribute: .CenterY, multiplier: 1, constant: 0))

        c.append(NSLayoutConstraint(item: userNameField, attribute: .Left, relatedBy: .Equal, toItem: userNameLabel, attribute: .Right, multiplier: 1, constant: 10))
        c.append(NSLayoutConstraint(item: userNameField, attribute: .Right, relatedBy: .Equal, toItem: self.containerView, attribute: .Right, multiplier: 1, constant: -16))
        c.append(NSLayoutConstraint(item: userNameField, attribute: .Baseline, relatedBy: .Equal, toItem: self.userNameLabel, attribute: .Baseline, multiplier: 1, constant: 0))

        c.append(NSLayoutConstraint(item: noteLabel, attribute: .Leading, relatedBy: .Equal, toItem: self, attribute: .Leading, multiplier: 1, constant: 16))
        c.append(NSLayoutConstraint(item: noteLabel, attribute: .Trailing, relatedBy: .Equal, toItem: self, attribute: .Trailing, multiplier: 1, constant: -16))
        c.append(NSLayoutConstraint(item: noteLabel, attribute: .Top, relatedBy: .Equal, toItem: self.containerView, attribute: .Bottom, multiplier: 1, constant: 10))

        c.append(NSLayoutConstraint(item: saveButton, attribute: .CenterY, relatedBy: .Equal, toItem: titleLabel, attribute: .CenterY, multiplier: 1, constant: 0))
        c.append(NSLayoutConstraint(item: saveButton, attribute: .Right, relatedBy: .Equal, toItem: self, attribute: .Right, multiplier: 1, constant: -10))
        self.addConstraints(c)

    }

    override func localizeAndApplyColorScheme() {
        super.localizeAndApplyColorScheme()
        titleLabel.text = localizedString("title.public.profile")
        userNameLabel.text = localizedString("profile.name.placeholder")
        noteLabel.text = localizedString("profile.hint.about.name")
        containerView.backgroundColor = self.colorScheme.profileDataSectionBackground
        saveButton.setTitle(localizedString("button.title.done.keyboard"), forState: .Normal)

        titleLabel.text = localizedString("title.public.profile")
        titleLabel.textColor = self.colorScheme.headerTitleText
        titleLabel.textAlignment = .Center
        self.backgroundView.image = nil
        self.backgroundView.backgroundColor = self.colorScheme.profileCommentSectionBackground

    }

    // MARK: UITextFieldDelegate

    public func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange,
                          replacementString string: String) -> Bool {
        let maxLength = 512
        let currentString: NSString = textField.text!
        let newString: NSString =
        currentString.stringByReplacingCharactersInRange(range, withString: string)
        return newString.length <= maxLength
    }

    override func closeButtonTapped() {
        delegate?.close()
    }

    func saveTapped() {
        delegate?.save()
    }
}