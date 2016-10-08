//
//  LoginView.swift
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


public protocol LoginViewDelegate: NSObjectProtocol {
    func close()

    func goBack()

    func verifyCode(_ model: NumberInfo, code: String)

    func numberInputCompleted(_ model: NumberInfo)

}

internal enum LoginState {
    case numberInput
    case codeVerification
    case codeVerificationFail
    case codeVerificationSuccess
}

open class LoginView: PhoneIdBaseFullscreenView {

    fileprivate(set) var verifyCodeControl: VerifyCodeControl!
    fileprivate(set) var numberInputControl: NumberInputControl!

    fileprivate(set) var topText: UITextView!
    fileprivate(set) var midText: UITextView!
    fileprivate(set) var bottomText: UITextView!

    fileprivate var timer: Timer!
    fileprivate var textViewBottomConstraint: NSLayoutConstraint!

    internal weak var loginViewDelegate: LoginViewDelegate?

    override init(model: NumberInfo, scheme: ColorScheme, bundle: Bundle, tableName: String) {
        super.init(model: model, scheme: scheme, bundle: bundle, tableName: tableName)
    }

    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        timer?.invalidate()
        timer = nil
    }

    override func setupSubviews() {
        super.setupSubviews()

        topText = {
            let topText = UITextView()
            topText.backgroundColor = UIColor.clear
            topText.isEditable = false
            topText.isScrollEnabled = false
            return topText
        }()

        midText = {
            let midText = UITextView()
            midText.isEditable = false
            midText.isScrollEnabled = false
            midText.font = UIFont.systemFont(ofSize: 18)
            midText.backgroundColor = UIColor.clear
            return midText
        }()

        setupVerificationCodeControl()

        bottomText = {
            let bottomText = UITextView()
            bottomText.isEditable = false
            bottomText.isScrollEnabled = false
            bottomText.isHidden = true
            bottomText.backgroundColor = UIColor.clear
            return bottomText
        }()

        numberInputControl = NumberInputControl(model: phoneIdModel, scheme: colorScheme, bundle: localizationBundle, tableName: localizationTableName)

        numberInputControl.numberInputCompleted = {
            (numberInfo) -> Void in
            self.phoneIdModel = numberInfo
            self.loginViewDelegate?.numberInputCompleted(self.phoneIdModel)
        }

        self.backgroundView.isUserInteractionEnabled = true
        self.backgroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(UIResponder.resignFirstResponder)))

        let subviews: [UIView] = [verifyCodeControl, numberInputControl, topText, midText, bottomText]

        for (_, element) in subviews.enumerated() {
            element.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview(element)
        }
    }

    func setupVerificationCodeControl() {
        verifyCodeControl = VerifyCodeControl(model: phoneIdModel, scheme: colorScheme, bundle: localizationBundle, tableName: localizationTableName)

        verifyCodeControl.verificationCodeDidCahnge = {
            (code) -> Void in

            if (code.utf16.count == self.verifyCodeControl.maxVerificationCodeLength) {

                self.midText.attributedText = self.localizedStringAttributed("html-logging.in")

                if let delegate = self.loginViewDelegate {
                    delegate.verifyCode(self.phoneIdModel, code: code)
                }

            } else {
                self.phoneIdService.abortCall()
            }

        }

        verifyCodeControl.backButtonTapped = {
            [weak self] in
            self?.verifyCodeControl.resignFirstResponder()
            self?.loginViewDelegate?.goBack()
        }
    }

    override func setupLayout() {

        super.setupLayout()

        var c: [NSLayoutConstraint] = []

        c.append(NSLayoutConstraint(item: topText, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0))
        c.append(NSLayoutConstraint(item: topText, attribute: .top, relatedBy: .equal, toItem: self.headerBackgroundView, attribute: .bottom, multiplier: 1, constant: 20))
        c.append(NSLayoutConstraint(item: topText, attribute: .bottom, relatedBy: .equal, toItem: numberInputControl, attribute: .topMargin, multiplier: 1, constant: 0))
        c.append(NSLayoutConstraint(item: topText, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 0.8, constant: 0))

        c.append(NSLayoutConstraint(item: numberInputControl, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0))
        c.append(NSLayoutConstraint(item: numberInputControl, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 0.8, constant: 0))
        c.append(NSLayoutConstraint(item: numberInputControl, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 50))

        c.append(NSLayoutConstraint(item: verifyCodeControl, attribute: .centerX, relatedBy: .equal, toItem: numberInputControl, attribute: .centerX, multiplier: 1, constant: 0))
        c.append(NSLayoutConstraint(item: verifyCodeControl, attribute: .centerY, relatedBy: .equal, toItem: numberInputControl, attribute: .centerY, multiplier: 1, constant: 0))
        c.append(NSLayoutConstraint(item: verifyCodeControl, attribute: .width, relatedBy: .equal, toItem: numberInputControl, attribute: .width, multiplier: 1, constant: 0))
        c.append(NSLayoutConstraint(item: verifyCodeControl, attribute: .height, relatedBy: .equal, toItem: numberInputControl, attribute: .height, multiplier: 1, constant: 0))

        c.append(NSLayoutConstraint(item: midText, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0))
        c.append(NSLayoutConstraint(item: midText, attribute: .top, relatedBy: .equal, toItem: numberInputControl, attribute: .bottom, multiplier: 1, constant: 20))
        c.append(NSLayoutConstraint(item: midText, attribute: .width, relatedBy: .equal, toItem: numberInputControl, attribute: .width, multiplier: 1, constant: 0))

        c.append(NSLayoutConstraint(item: bottomText, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0))

        textViewBottomConstraint = NSLayoutConstraint(item: bottomText, attribute: .top, relatedBy: .equal, toItem: midText, attribute: .bottom, multiplier: 1, constant: 20)
        c.append(textViewBottomConstraint)

        c.append(NSLayoutConstraint(item: bottomText, attribute: .width, relatedBy: .equal, toItem: numberInputControl, attribute: .width, multiplier: 1, constant: 0))

        self.customConstraints += c

        self.addConstraints(c)

    }

    override func localizeAndApplyColorScheme() {

        super.localizeAndApplyColorScheme()
        titleLabel.attributedText = localizedStringAttributed("html-title.login")

        self.needsUpdateConstraints()
    }


    func switchToState(_ state: LoginState, completion: (() -> Void)? = nil) {

        self.numberInputControl.isHidden = state != .numberInput
        self.verifyCodeControl.isHidden = !self.numberInputControl.isHidden
        midText.isHidden = false
        timer?.invalidate()
        switch (state) {
        case .numberInput:
            indicateNumberInput()
            break
        case .codeVerification:
            indicateCodeVerification()
            break
        case .codeVerificationFail:
            indicateVerificationFail()
            break
        case .codeVerificationSuccess:
            indicateVerificationSuccess(completion)
            break
        }
    }

    func setupHintTimer() {

        let fireDate = Date(timeIntervalSinceNow: 30)
        timer = Timer(fireAt: fireDate, interval: 0, target: self, selector: #selector(LoginView.timerFired), userInfo: nil, repeats: false)
        RunLoop.main.add(timer!, forMode: RunLoopMode.defaultRunLoopMode)
        self.verifyCodeControl.setupHintTimer()

    }

    func indicateNumberInput() {
        numberInputControl.validatePhoneNumber()
        numberInputControl.becomeFirstResponder()
        topText.attributedText = localizedStringAttributed("html-access.app.with.number") {
            (tmpResult) -> String in
            return String(format: tmpResult, self.phoneIdService.appName!)
        }

        midText.attributedText = localizedStringAttributed("html-label.we.will.send.sms")
        bottomText.attributedText = localizedStringAttributed("html-label.terms.and.conditions")

        bottomText.linkTextAttributes = [NSFontAttributeName: UIFont.systemFont(ofSize: 15), NSForegroundColorAttributeName: colorScheme.labelBottomNoteLinkText]
        needsUpdateConstraints()
        bottomText.isHidden = false
    }

    func indicateCodeVerification() {
        verifyCodeControl.reset()
        verifyCodeControl.becomeFirstResponder()

        topText.attributedText = localizedStringAttributed("html-type.the.confirmation.code")
        midText.attributedText = nil
        midText.textColor = colorScheme.labelMidNoteText
        bottomText.isHidden = true
        setupHintTimer()
    }

    func indicateVerificationFail() {
        self.midText.attributedText = localizedStringAttributed("html-loggin.failed")
        verifyCodeControl.indicateVerificationFail()
    }

    func indicateVerificationSuccess(_ completion: (() -> Void)?) {
        self.midText.attributedText = localizedStringAttributed("html-logged.in")
        verifyCodeControl.indicateVerificationSuccess(completion)
    }

    func timerFired() {
        midText.attributedText = localizedStringAttributed("html-label.when.code.not.received")
    }


    override func closeButtonTapped() {
        loginViewDelegate?.close()
    }

    @discardableResult
    open override func resignFirstResponder() -> Bool {
        self.verifyCodeControl.resignFirstResponder()
        self.numberInputControl.resignFirstResponder()
        return super.resignFirstResponder()
    }
}
