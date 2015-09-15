//
//  UICustomization.swift
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

public protocol Customizable: NSObjectProtocol{
    var colorScheme: ColorScheme! {get set}
    var localizationBundle:NSBundle! {get set}
    var localizationTableName:String! {get set}

}

public extension Customizable{

    internal func localizedString(key:String, formatting:((String)->String)? = nil) ->String{
        
        var result = NSLocalizedString(key, tableName: localizationTableName , bundle: localizationBundle, comment:key)
        
        // TODO: this is actually not a part of localization. 
        // However text-formatting appeared to be tightly coupled with text-content.
        // Need more graceful solution
        result = self.colorScheme.replaceNamedColors(result)
        
        if let formatting = formatting{
            result = formatting(result)
        }
        return result
    }
    
    internal func localizedStringAttributed(key:String, formatting:((String)->String)? = nil) ->NSAttributedString{
        let text = localizedString(key, formatting: formatting)
        let accessAttributedText = try! NSAttributedString(
            data: text.dataUsingEncoding(NSUnicodeStringEncoding, allowLossyConversion: true)!,
            options: [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType],
            documentAttributes: nil)
        return accessAttributedText
    }

}

public protocol ColorScheme: NSObjectProtocol{
    var mainAccent:UIColor {get set}
    var placeholderText:UIColor {get set}
    var disabledText:UIColor {get set}
    var selectedText:UIColor {get set}
    var normalText:UIColor {get set}
    var linkText:UIColor {get set}
    var buttonTextColor:UIColor {get set}
    var defaultTextInputBackground:UIColor {get set}
    var avatarBackground:UIColor {get set}
    
}

public class DefaultColorScheme : NSObject, ColorScheme{
    public var mainAccent:UIColor = UIColor(netHex: 0x19586E)
    public var placeholderText:UIColor = UIColor(netHex: 0xC8C8CD)
    public var disabledText:UIColor = UIColor(netHex: 0xC8C8CD)
    public var selectedText:UIColor = UIColor(netHex: 0x000000)
    public var normalText:UIColor = UIColor(netHex: 0xC8C8CD)
    public var buttonTextColor:UIColor = UIColor(netHex: 0xffffff)
    public var linkText:UIColor = UIColor(netHex: 0x133E6B)
    public var defaultTextInputBackground:UIColor = UIColor(netHex: 0xffffff)
    public var avatarBackground:UIColor = UIColor(netHex: 0xC8C8CD)
}

public extension ColorScheme {
    func replaceNamedColors(input:String)->String
    {
        let result:NSMutableString = input.mutableCopy() as! NSMutableString
        
        let members = Mirror(reflecting: self).children
        var names = [String]()
        for (name,_) in members
        {
            if name == "super"{continue}
            names.append(name!)
        }
        
        for name in names{
            if let color = ((self as AnyObject).valueForKeyPath(name) as? UIColor){
                let hexColor = color.hexString()
                result.replaceOccurrencesOfString("$\(name)", withString: hexColor, options:NSStringCompareOptions.LiteralSearch, range: NSMakeRange(0, result.length))
            }
        }
        
        return result as String
    }
}

public extension UIColor {
    public convenience init(red: Int, green: Int, blue: Int) {
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    public convenience init(netHex:Int) {
        self.init(red:(netHex >> 16) & 0xff, green:(netHex >> 8) & 0xff, blue:netHex & 0xff)
    }
    
    public func hexString() -> String {
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var a:CGFloat = 0
        
        getRed(&r, green: &g, blue: &b, alpha: &a)
        
        let rgb:Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
        
        return String(format:"#%06x", rgb)
    }
}

