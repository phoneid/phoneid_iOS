//
//  DefaultComponentFactory.swift
//  PhoneIdSDK
//
//  Created by Alyona on 7/1/15.
//  Copyright © 2015 phoneId. All rights reserved.
//

import Foundation

public protocol ComponentFactory: NSObjectProtocol{
    
    func numberInputViewController() -> NumberInputViewController
    func countryCodePickerViewController(model: NumberInfo) -> CountryCodePickerViewController
    func verifyCodeViewController(model: NumberInfo) -> VerifyCodeViewController
    
    func numberInputView(model: NumberInfo)->NumberInputView
    func countryCodePickerView(model: NumberInfo)->CountryCodePickerView
    func verifyCodeView(model: NumberInfo)->VerifyCodeView

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
    var phoneIdModel: NumberInfo! { set get}
}

public extension PhoneIdConsumer{
    var phoneIdService: PhoneIdService! { return PhoneIdService.sharedInstance}
    var phoneIdComponentFactory: ComponentFactory! { return phoneIdService.componentFactory}
}

