//
//  NumberInputControl.swift
//  phoneid_iOS
//
//  Copyright 2015 Federico Pomi
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
import libPhoneNumber_iOS

class NumberInputControl: PhoneIdBaseView {

    fileprivate(set) var numberText: NumericTextField!
    fileprivate(set) var doneBarButton: UIBarButtonItem!
    fileprivate(set) var countryCodeBarButton: UIBarButtonItem!

    fileprivate(set) var okButton: UIButton!
    fileprivate(set) var prefixButton: UIButton!

    fileprivate(set) var numberPlaceholderView: UIView!
    fileprivate(set) var activityIndicator: UIActivityIndicatorView!
    fileprivate var asYouTypeFomratter: NBAsYouTypeFormatter!

    var numberDidChange: (() -> Void)?
    var numberInputCompleted: ((NumberInfo) -> Void)?

    override init(model: NumberInfo, scheme: ColorScheme, bundle: Bundle, tableName: String) {
        super.init(model: model, scheme: scheme, bundle: bundle, tableName: tableName)
    }

    required internal init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setupSubviews() {

        numberText = {
            let numberText = NumericTextField(maxLength: 15)
            numberText.keyboardType = .numberPad
            numberText.addTarget(self, action: #selector(NumberInputControl.textFieldDidChange(_:)), for: .editingChanged)
            numberText.backgroundColor = UIColor.clear
            return numberText
        }()

        setupKeyboardToolBar()

        numberPlaceholderView = {
            let numberPlaceholderView = UIView()
            numberPlaceholderView.layer.cornerRadius = 5
            return numberPlaceholderView
        }()

        okButton = {
            let okButton = UIButton()
            okButton.isHidden = true
            okButton.addTarget(self, action: #selector(NumberInputControl.okButtonTapped(_:)), for: .touchUpInside)
            return okButton
        }()

        prefixButton = {
            let prefixButton = UIButton()
            prefixButton.titleLabel?.textAlignment = .left
            prefixButton.addTarget(self, action: #selector(NumberInputControl.countryCodeTapped(_:)), for: .touchUpInside)
            return prefixButton
        }()

        activityIndicator = {
            let activityIndicator = UIActivityIndicatorView()
            activityIndicator.activityIndicatorViewStyle = .whiteLarge
            return activityIndicator
        }()


        let subviews: [UIView] = [numberPlaceholderView, numberText, okButton, prefixButton, activityIndicator]

        for (_, element) in subviews.enumerated() {
            element.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview(element)
        }
    }

    override func setupLayout() {

        var c: [NSLayoutConstraint] = []

        c.append(NSLayoutConstraint(item: numberPlaceholderView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0))
        c.append(NSLayoutConstraint(item: numberPlaceholderView, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0))
        c.append(NSLayoutConstraint(item: numberPlaceholderView, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 1, constant: 0))
        c.append(NSLayoutConstraint(item: numberPlaceholderView, attribute: .height, relatedBy: .equal, toItem: self, attribute: .height, multiplier: 1, constant: 0))

        c.append(NSLayoutConstraint(item: numberText, attribute: .left, relatedBy: .equal, toItem: prefixButton, attribute: .right, multiplier: 1, constant: 5))
        c.append(NSLayoutConstraint(item: numberText, attribute: .right, relatedBy: .equal, toItem: okButton, attribute: .left, multiplier: 1, constant: 0))
        c.append(NSLayoutConstraint(item: numberText, attribute: .centerY, relatedBy: .equal, toItem: numberPlaceholderView, attribute: .centerY, multiplier: 1, constant: 0))

        c.append(NSLayoutConstraint(item: prefixButton, attribute: .left, relatedBy: .equal, toItem: numberPlaceholderView, attribute: .left, multiplier: 1, constant: 2))
        c.append(NSLayoutConstraint(item: prefixButton, attribute: .lastBaseline, relatedBy: .equal, toItem: numberText, attribute: .lastBaseline, multiplier: 1, constant: 0))
        c.append(NSLayoutConstraint(item: prefixButton, attribute: .width, relatedBy: .equal, toItem: self, attribute: .height, multiplier: 1, constant: 0))

        c.append(NSLayoutConstraint(item: okButton, attribute: .centerX, relatedBy: .equal, toItem: activityIndicator, attribute: .centerX, multiplier: 1, constant: 0))
        c.append(NSLayoutConstraint(item: okButton, attribute: .centerY, relatedBy: .equal, toItem: activityIndicator, attribute: .centerY, multiplier: 1, constant: 0))

        c.append(NSLayoutConstraint(item: activityIndicator, attribute: .centerY, relatedBy: .equal, toItem: numberPlaceholderView, attribute: .centerY, multiplier: 1, constant: 0))
        c.append(NSLayoutConstraint(item: activityIndicator, attribute: .right, relatedBy: .equal, toItem: numberPlaceholderView, attribute: .right, multiplier: 1, constant: -5))

        self.addConstraints(c)

    }

    fileprivate func setupKeyboardToolBar() {
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 44))

        countryCodeBarButton = UIBarButtonItem(title: nil, style: .plain, target: self, action: #selector(NumberInputControl.countryCodeTapped(_:)))
        doneBarButton = UIBarButtonItem(title: nil, style: .plain, target: self, action: #selector(NumberInputControl.okButtonTapped(_:)))

        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)

        toolBar.items = [countryCodeBarButton, space, doneBarButton]

        numberText.inputAccessoryView = toolBar
    }

    override func setupWithModel(_ model: NumberInfo) {
        super.setupWithModel(model)

        if let isoCountryCode = phoneIdModel.isoCountryCode {
            asYouTypeFomratter = NBAsYouTypeFormatter(regionCode: isoCountryCode)
        } else {
            asYouTypeFomratter = NBAsYouTypeFormatter(regionCode: phoneIdModel.defaultIsoCountryCode)
        }

        if let phoneNumberString = phoneIdModel.phoneNumber {
            numberText.text = asYouTypeFomratter.inputString(phoneNumberString);
        }

        if let phoneCountryCodeString = phoneIdModel.phoneCountryCode {
            prefixButton.setTitle(phoneCountryCodeString, for: UIControlState())
        } else {
            phoneIdModel.phoneCountryCode = phoneIdModel.defaultCountryCode
            phoneIdModel.isoCountryCode = phoneIdModel.defaultIsoCountryCode
            prefixButton.setTitle(phoneIdModel.defaultCountryCode, for: UIControlState())
        }
        self.validatePhoneNumber()
    }

    override func localizeAndApplyColorScheme() {

        super.localizeAndApplyColorScheme()

        okButton.setTitle(localizedString("button.title.ok"), for: UIControlState())
        okButton.accessibilityLabel = localizedString("accessibility.button.title.ok")


        numberText.attributedPlaceholder = localizedStringAttributed("html-placeholder.phone.number")
        numberText.accessibilityLabel = localizedString("accessibility.phone.number.input")

        countryCodeBarButton.title = localizedString("button.title.change.country.code")
        countryCodeBarButton.accessibilityLabel = localizedString("accessibility.button.title.change.country.code")

        prefixButton.accessibilityLabel = localizedString("accessibility.button.title.change.country.code")

        doneBarButton.title = localizedString("button.title.done.keyboard")
        doneBarButton.accessibilityLabel = localizedString("accessibility.button.title.done.keyboard")

        numberPlaceholderView.backgroundColor = colorScheme.inputNumberBackground

        prefixButton.setTitleColor(colorScheme.inputPrefixText, for: UIControlState())

        numberText.textColor = colorScheme.inputNumberText

        okButton.setTitleColor(colorScheme.buttonOKNormalText, for: UIControlState())
        okButton.setTitleColor(colorScheme.buttonOKDisabledText, for: .disabled)

        activityIndicator.color = colorScheme.activityIndicatorNumber
        self.needsUpdateConstraints()
    }

    func validatePhoneNumber() {
        activityIndicator.stopAnimating()

        numberText.text = asYouTypeFomratter.inputString(numberText.text)
        okButton.isHidden = numberText.text!.isEmpty

        if (phoneIdModel.isValidNumber(numberText.text!)) {
            numberText.text = phoneIdModel.formatNumber(numberText.text!) as String
            okButton.isEnabled = true
            doneBarButton.isEnabled = true
        } else {
            okButton.isEnabled = false
            doneBarButton.isEnabled = false
        }
    }

    func reset() {
        numberText.text = ""
        validatePhoneNumber()
    }
    
    @discardableResult
    override func resignFirstResponder() -> Bool {
        return self.numberText.resignFirstResponder()
    }

    @discardableResult
    override func becomeFirstResponder() -> Bool {
        return self.numberText.becomeFirstResponder()
    }

    func textFieldDidChange(_ textField: UITextField) {
        numberDidChange?()
        validatePhoneNumber()
    }

    func okButtonTapped(_ sender: UIButton) {
        self.phoneIdModel.phoneNumber = self.numberText.text

        okButton.isHidden = true
        activityIndicator.startAnimating()
        numberInputCompleted?(self.phoneIdModel)

    }

    func countryCodeTapped(_ sender: UIButton) {
        self.phoneIdModel.phoneNumber = self.numberText.text

        let controller = self.phoneIdComponentFactory.countryCodePickerViewController(self.phoneIdModel)

        controller.countryCodePickerCompletionBlock = {
            [unowned self] (model: NumberInfo) -> Void in
            self.phoneIdModel = model
            self.setupWithModel(model)
            self.becomeFirstResponder()
        }

        let presenter: UIViewController = PhoneIdWindow.currentPresenter()

        presenter.present(controller, animated: true) {
            self.resignFirstResponder()
        }

    }
}
