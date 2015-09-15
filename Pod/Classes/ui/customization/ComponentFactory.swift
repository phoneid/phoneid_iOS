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

public protocol ComponentFactory: NSObjectProtocol{
    
    func numberInputViewController() -> NumberInputViewController
    func countryCodePickerViewController(model: NumberInfo) -> CountryCodePickerViewController
    func verifyCodeViewController(model: NumberInfo) -> VerifyCodeViewController
    func editProfileViewController(model: UserInfo) -> EditProfileViewController
    
    func numberInputView(model: NumberInfo)->NumberInputView
    func countryCodePickerView(model: NumberInfo)->CountryCodePickerView
    func verifyCodeView(model: NumberInfo)->VerifyCodeView
    func editProfileView(model: UserInfo)->EditProfileView

    func colorScheme()->ColorScheme
    
    func localizationBundle()->NSBundle
    func localizationTableName()->String
    
    func defaultBackgroundImage()->UIImage
}

public class DefaultComponentFactory: NSObject, ComponentFactory {
    
    public func numberInputViewController() -> NumberInputViewController{
        let controller = NumberInputViewController()
        return controller
    }
    
    public func numberInputView(model: NumberInfo)->NumberInputView{
        let view = NumberInputView(model: model, scheme: self.colorScheme(), bundle: self.localizationBundle(), tableName: localizationTableName())
        return view
    }
    
    public func countryCodePickerViewController(model: NumberInfo) -> CountryCodePickerViewController{
        let controller = CountryCodePickerViewController(model: model)
        return controller
    }
    
    public func countryCodePickerView(model: NumberInfo)->CountryCodePickerView{
        let view = CountryCodePickerView(model:model, scheme: self.colorScheme(), bundle: self.localizationBundle(), tableName: localizationTableName())
        return view
    }
    
    public func verifyCodeViewController(model: NumberInfo) -> VerifyCodeViewController{
        let controller = VerifyCodeViewController(model: model)
        return controller
    }

    public func verifyCodeView(model: NumberInfo)->VerifyCodeView{
        let view = VerifyCodeView(model: model, scheme: self.colorScheme(), bundle: self.localizationBundle(), tableName: localizationTableName())
        return view
    }
    
    public func editProfileViewController(model: UserInfo) -> EditProfileViewController{
        let controller = EditProfileViewController(model: model)
        return controller
    }
    
    public func editProfileView(model: UserInfo)->EditProfileView{
        let view = EditProfileView(user:model, scheme: self.colorScheme(), bundle: self.localizationBundle(), tableName: localizationTableName())
        return view
    }
    
    public func colorScheme()->ColorScheme{
        let scheme = DefaultColorScheme()
        return scheme
    }
    
    public func localizationBundle()->NSBundle{
        let bundle = NSBundle.phoneIdBundle()
        return bundle
    }
    
    public func localizationTableName()->String{
        return "Localizable"
    }
    
    public func defaultBackgroundImage()->UIImage{
        return UIImage(namedInPhoneId:"background")!
    }
 
}

public protocol PhoneIdConsumer:NSObjectProtocol{
    var phoneIdService: PhoneIdService! {get}
    var phoneIdComponentFactory: ComponentFactory! {get}
}

public extension PhoneIdConsumer{
    var phoneIdService: PhoneIdService! { return PhoneIdService.sharedInstance}
    var phoneIdComponentFactory: ComponentFactory! { return phoneIdService.componentFactory}
}

