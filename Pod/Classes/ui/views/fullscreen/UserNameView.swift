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

open class UserNameView: PhoneIdBaseFullscreenView, UITextFieldDelegate {


    fileprivate(set) var userNameLabel: UILabel!
    fileprivate(set) var userNameField: UITextField!
    fileprivate(set) var noteLabel: UILabel!
    fileprivate(set) var saveButton: UIButton!

    var containerView: UIView!
    internal weak var delegate: UserNameViewDelegate?

    var containerTopConstraint: NSLayoutConstraint!

    override public init(frame: CGRect) {
        super.init(frame: frame)
    }

    convenience init(userName: String?, scheme: ColorScheme, bundle: Bundle, tableName: String) {

        self.init(frame: CGRect.zero)

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
            label.font = UIFont.boldSystemFont(ofSize: 17)
            label.numberOfLines = 1
            label.textColor = self.colorScheme.profileDataSectionTitleText
            label.setContentHuggingPriority(1000, for: UILayoutConstraintAxis.horizontal)
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
            saveButton.titleLabel?.textAlignment = .left
            saveButton.addTarget(self, action: #selector(UserNameView.saveTapped), for: .touchUpInside)
            return saveButton
        }()

        let subviews: [UIView] = [containerView, userNameLabel, userNameField, noteLabel, saveButton]
        for (_, element) in subviews.enumerated() {
            element.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview(element)
        }
    }

    override func setupLayout() {

        super.setupLayout()

        var c: [NSLayoutConstraint] = []

        c.append(NSLayoutConstraint(item: containerView, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 1, constant: 0))
        c.append(NSLayoutConstraint(item: containerView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 44))
        c.append(NSLayoutConstraint(item: containerView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 0))
        c.append(NSLayoutConstraint(item: containerView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 74))

        c.append(NSLayoutConstraint(item: userNameLabel, attribute: .leading, relatedBy: .equal, toItem: self.containerView, attribute: .leading, multiplier: 1, constant: 16))
        c.append(NSLayoutConstraint(item: userNameLabel, attribute: .centerY, relatedBy: .equal, toItem: self.containerView, attribute: .centerY, multiplier: 1, constant: 0))

        c.append(NSLayoutConstraint(item: userNameField, attribute: .left, relatedBy: .equal, toItem: userNameLabel, attribute: .right, multiplier: 1, constant: 10))
        c.append(NSLayoutConstraint(item: userNameField, attribute: .right, relatedBy: .equal, toItem: self.containerView, attribute: .right, multiplier: 1, constant: -16))
        c.append(NSLayoutConstraint(item: userNameField, attribute: .lastBaseline, relatedBy: .equal, toItem: self.userNameLabel, attribute: .lastBaseline, multiplier: 1, constant: 0))

        c.append(NSLayoutConstraint(item: noteLabel, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 16))
        c.append(NSLayoutConstraint(item: noteLabel, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: -16))
        c.append(NSLayoutConstraint(item: noteLabel, attribute: .top, relatedBy: .equal, toItem: self.containerView, attribute: .bottom, multiplier: 1, constant: 10))

        c.append(NSLayoutConstraint(item: saveButton, attribute: .centerY, relatedBy: .equal, toItem: titleLabel, attribute: .centerY, multiplier: 1, constant: 0))
        c.append(NSLayoutConstraint(item: saveButton, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1, constant: -10))
        self.addConstraints(c)

    }

    override func localizeAndApplyColorScheme() {
        super.localizeAndApplyColorScheme()
        titleLabel.text = localizedString("title.public.profile")
        userNameLabel.text = localizedString("profile.name.placeholder")
        noteLabel.text = localizedString("profile.hint.about.name")
        containerView.backgroundColor = self.colorScheme.profileDataSectionBackground
        saveButton.setTitle(localizedString("button.title.done.keyboard"), for: UIControlState())

        titleLabel.text = localizedString("title.public.profile")
        titleLabel.textColor = self.colorScheme.headerTitleText
        titleLabel.textAlignment = .center
        self.backgroundView.image = nil
        self.backgroundView.backgroundColor = self.colorScheme.profileCommentSectionBackground

    }

    // MARK: UITextFieldDelegate

    open func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange,
                          replacementString string: String) -> Bool {
        let maxLength = 512
        let currentString: NSString = textField.text! as NSString
        let newString: NSString =
        currentString.replacingCharacters(in: range, with: string) as NSString
        return newString.length <= maxLength
    }

    override func closeButtonTapped() {
        delegate?.close()
    }

    func saveTapped() {
        delegate?.save()
    }
}
