//
//  ComponentFactory.swift
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

@objc public protocol ComponentFactory: NSObjectProtocol {


    func loginViewController() -> LoginViewController

    func countryCodePickerViewController(model: NumberInfo) -> CountryCodePickerViewController

    func editProfileViewController(model: UserInfo) -> EditProfileViewController

    func imageEditViewController(image: UIImage) -> ImageEditViewController

    func editUserNameViewController(model: UserInfo) -> UserNameViewController

    func loginView(model: NumberInfo) -> LoginView

    func countryCodePickerView(model: NumberInfo) -> CountryCodePickerView

    func editProfileView(model: UserInfo) -> EditProfileView

    func userNameView(model: String?) -> UserNameView

    var colorScheme:ColorScheme {get set}

    var localizationBundle: NSBundle {get set}

    var localizationTableName:String {get set}

    var defaultBackgroundImage:UIImage? {get set}
}

@objc public class DefaultComponentFactory: NSObject, ComponentFactory {

    public func loginViewController() -> LoginViewController {
        let controller = LoginViewController()
        return controller
    }

    public func loginView(model: NumberInfo) -> LoginView {
        let view = LoginView(model: model, scheme: self.colorScheme, bundle: self.localizationBundle, tableName: localizationTableName)
        return view
    }

    public func countryCodePickerViewController(model: NumberInfo) -> CountryCodePickerViewController {
        let controller = CountryCodePickerViewController(model: model)
        return controller
    }

    public func countryCodePickerView(model: NumberInfo) -> CountryCodePickerView {
        let view = CountryCodePickerView(model: model, scheme: self.colorScheme, bundle: self.localizationBundle, tableName: localizationTableName)
        return view
    }

    public func editProfileViewController(model: UserInfo) -> EditProfileViewController {
        let controller = EditProfileViewController(model: model)
        return controller
    }

    public func imageEditViewController(image: UIImage) -> ImageEditViewController {
        let controller = ImageEditViewController(image: image)
        return controller
    }

    public func editUserNameViewController(model: UserInfo) -> UserNameViewController {
        let controller = UserNameViewController(model: model)
        return controller
    }

    public func userNameView(model: String?) -> UserNameView {
        let view = UserNameView(userName: model, scheme: self.colorScheme, bundle: self.localizationBundle, tableName: localizationTableName)
        return view
    }

    public func editProfileView(model: UserInfo) -> EditProfileView {
        let view = EditProfileView(user: model, scheme: self.colorScheme, bundle: self.localizationBundle, tableName: localizationTableName)
        return view
    }

    public var colorScheme = ColorScheme()

    public var localizationBundle = NSBundle.phoneIdBundle()

    public var localizationTableName = "Localizable"

    public var defaultBackgroundImage = UIImage(namedInPhoneId: "background")

}

public protocol PhoneIdConsumer: NSObjectProtocol {
    var phoneIdService: PhoneIdService! { get }
    var phoneIdComponentFactory: ComponentFactory! { get }
}

public extension PhoneIdConsumer {
    var phoneIdService: PhoneIdService! {
        return PhoneIdService.sharedInstance
    }
    var phoneIdComponentFactory: ComponentFactory! {
        return phoneIdService.componentFactory
    }
}

