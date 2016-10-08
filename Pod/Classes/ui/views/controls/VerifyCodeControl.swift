//
//  VerifyCodeControl.swift
//
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

import UIKit

class VerifyCodeControl: PhoneIdBaseView {

    fileprivate(set) var placeholderView: UIView!
    fileprivate(set) var codeText: NumericTextField!
    fileprivate(set) var placeholderLabel: UILabel!
    fileprivate(set) var activityIndicator: UIActivityIndicatorView!
    fileprivate(set) var backButton: UIButton!
    fileprivate(set) var statusImage: UIImageView!

    var verificationCodeDidCahnge: ((_ code:String) -> Void)?
    var requestVoiceCall: (() -> Void)?
    var backButtonTapped: (() -> Void)?

    let maxVerificationCodeLength = 6
    fileprivate var timer: Timer!

    override func setupSubviews() {
        super.setupSubviews()

        codeText = {
            let codeText = NumericTextField(maxLength: maxVerificationCodeLength)
            codeText.keyboardType = .numberPad
            codeText.addTarget(self, action: #selector(VerifyCodeControl.textFieldDidChange(_:)), for: .editingChanged)
            codeText.backgroundColor = UIColor.clear
            return codeText
        }()

        placeholderLabel = {
            let placeholderLabel = UILabel()
            let attributedString: NSMutableAttributedString = NSMutableAttributedString(string: "______")
            placeholderLabel.attributedText = applyCodeFieldStyle(attributedString)
            return placeholderLabel
        }()

        activityIndicator = {
            activityIndicator = UIActivityIndicatorView()
            activityIndicator.activityIndicatorViewStyle = .whiteLarge
            return activityIndicator
        }()

        statusImage = UIImageView()

        placeholderView = {
            let placeholderView = UIView()
            placeholderView.layer.cornerRadius = 5
            return placeholderView
        }()

        backButton = {
            let backButton = UIButton()

            let backButtonImage = UIImage(namedInPhoneId: "compact-back")?.withRenderingMode(.alwaysTemplate)
            backButton.setImage(backButtonImage, for: UIControlState())

            backButton.addTarget(self, action: #selector(VerifyCodeControl.backTapped(_:)), for: .touchUpInside)
            backButton.tintColor = colorScheme.inputCodeBackbuttonNormal
            return backButton
        }()

        let subviews: [UIView] = [placeholderView, placeholderLabel, codeText, activityIndicator, backButton, statusImage]

        for (_, element) in subviews.enumerated() {
            element.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview(element)
        }

    }

    deinit {
        timer?.invalidate()
        timer = nil
    }

    override func setupLayout() {

        super.setupLayout()

        var c: [NSLayoutConstraint] = []

        c.append(NSLayoutConstraint(item: placeholderView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0))
        c.append(NSLayoutConstraint(item: placeholderView, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0))
        c.append(NSLayoutConstraint(item: placeholderView, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 1, constant: 0))
        c.append(NSLayoutConstraint(item: placeholderView, attribute: .height, relatedBy: .equal, toItem: self, attribute: .height, multiplier: 1, constant: 0))

        c.append(NSLayoutConstraint(item: placeholderLabel, attribute: .centerX, relatedBy: .equal, toItem: placeholderView, attribute: .centerX, multiplier: 1, constant: 0))
        c.append(NSLayoutConstraint(item: placeholderLabel, attribute: .centerY, relatedBy: .equal, toItem: placeholderView, attribute: .centerY, multiplier: 1, constant: 5))

        c.append(NSLayoutConstraint(item: backButton, attribute: .centerY, relatedBy: .equal, toItem: placeholderView, attribute: .centerY, multiplier: 1, constant: 0))
        c.append(NSLayoutConstraint(item: backButton, attribute: .left, relatedBy: .equal, toItem: placeholderView, attribute: .left, multiplier: 1, constant: 18))
        c.append(NSLayoutConstraint(item: backButton, attribute: .height, relatedBy: .equal, toItem: self, attribute: .height, multiplier: 1, constant: 0))

        c.append(NSLayoutConstraint(item: codeText, attribute: .centerX, relatedBy: .equal, toItem: placeholderLabel, attribute: .centerX, multiplier: 1, constant: 2))
        c.append(NSLayoutConstraint(item: codeText, attribute: .centerY, relatedBy: .equal, toItem: placeholderView, attribute: .centerY, multiplier: 1, constant: -2))
        c.append(NSLayoutConstraint(item: codeText, attribute: .width, relatedBy: .equal, toItem: placeholderLabel, attribute: .width, multiplier: 1, constant: 5))

        c.append(NSLayoutConstraint(item: activityIndicator, attribute: .centerY, relatedBy: .equal, toItem: placeholderView, attribute: .centerY, multiplier: 1, constant: 0))
        c.append(NSLayoutConstraint(item: activityIndicator, attribute: .right, relatedBy: .equal, toItem: placeholderView, attribute: .right, multiplier: 1, constant: -5))

        c.append(NSLayoutConstraint(item: statusImage, attribute: .centerX, relatedBy: .equal, toItem: activityIndicator, attribute: .centerX, multiplier: 1, constant: 0))
        c.append(NSLayoutConstraint(item: statusImage, attribute: .centerY, relatedBy: .equal, toItem: activityIndicator, attribute: .centerY, multiplier: 1, constant: 0))

        self.addConstraints(c)

    }

    override func localizeAndApplyColorScheme() {

        super.localizeAndApplyColorScheme()

        placeholderView.backgroundColor = colorScheme.inputCodeBackground
        codeText.textColor = colorScheme.inputCodeText
        codeText.accessibilityLabel = localizedString("accessibility.verification.input");
        backButton.accessibilityLabel = localizedString("accessibility.button.title.back");
        placeholderLabel.textColor = colorScheme.inputCodePlaceholder
        activityIndicator.color = colorScheme.activityIndicatorCode
        self.needsUpdateConstraints()
    }

    fileprivate func applyCodeFieldStyle(_ input: NSAttributedString) -> NSAttributedString {
        let attributedString: NSMutableAttributedString = NSMutableAttributedString(attributedString: input)
        let range: NSRange = NSMakeRange(0, attributedString.length)
        attributedString.addAttribute(NSKernAttributeName, value: 8, range: range)

        if (attributedString.length > 2) {
            let range: NSRange = NSMakeRange(2, 1)
            attributedString.addAttribute(NSKernAttributeName, value: 24, range: range)
        }

        attributedString.addAttribute(NSFontAttributeName, value: UIFont(name: "Menlo", size: 22)!, range: range)
        return attributedString
    }

    func textFieldDidChange(_ textField: UITextField) {

        textField.attributedText = applyCodeFieldStyle(textField.attributedText!)

        if (textField.text!.utf16.count == maxVerificationCodeLength) {

            activityIndicator.startAnimating()
            backButtonEnable(false)

        } else {

            activityIndicator.stopAnimating()
            phoneIdService.abortCall()
            statusImage.isHidden = true
            backButtonEnable(true)
        }

        self.verificationCodeDidCahnge?(textField.text!)

    }

    func backTapped(_ sender: UIButton) {
        backButtonTapped?()
    }

    func indicateVerificationFail() {
        activityIndicator.stopAnimating()
        statusImage.image = UIImage(namedInPhoneId: "icon-ko")?.withRenderingMode(.alwaysTemplate)
        statusImage.tintColor = colorScheme.fail
        statusImage.isHidden = false
        backButtonEnable(true)
    }

    func backButtonEnable(_ value: Bool) {
        backButton.isEnabled = value
        backButton.tintColor = value ? colorScheme.inputCodeBackbuttonNormal : colorScheme.inputCodeBackbuttonDisabled
    }

    func indicateVerificationSuccess(_ completion: (() -> Void)?) {

        activityIndicator.stopAnimating()
        statusImage.image = UIImage(namedInPhoneId: "icon-ok")?.withRenderingMode(.alwaysTemplate)
        statusImage.tintColor = colorScheme.success;
        statusImage.isHidden = false

        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: [], animations: {
            () -> Void in
            self.statusImage.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        }) {
            (_) -> Void in
            self.statusImage.transform = CGAffineTransform(scaleX: 1, y: 1)
            completion?()
        }

    }

    func reset() {
        codeText.text = ""
        codeText.inputAccessoryView = nil
        codeText.reloadInputViews()
        textFieldDidChange(codeText)
        timer?.invalidate()
    }

    @discardableResult
    override func resignFirstResponder() -> Bool {
        return codeText.resignFirstResponder()
    }

    @discardableResult 
    override func becomeFirstResponder() -> Bool {
        return codeText.becomeFirstResponder()
    }

    func setupHintTimer() {

        timer?.invalidate()
        let fireDate = Date(timeIntervalSinceNow: 30)
        timer = Timer(fireAt: fireDate, interval: 0, target: self, selector: #selector(VerifyCodeControl.timerFired), userInfo: nil, repeats: false)
        RunLoop.main.add(timer!, forMode: RunLoopMode.defaultRunLoopMode)

    }

    func timerFired() {
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 44))

        let callMeButton = UIBarButtonItem(title: localizedString("button.title.call.me"), style: .plain, target: self, action: #selector(VerifyCodeControl.callMeButtonTapped))

        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)

        toolBar.items = [space, callMeButton]
        codeText.resignFirstResponder()
        codeText.inputAccessoryView = toolBar
        codeText.becomeFirstResponder()
    }

    func callMeButtonTapped() {
        requestVoiceCall?()
    }

}
