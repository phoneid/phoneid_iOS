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

public class ColorScheme : NSObject{
    public var mainAccent:UIColor = UIColor(netHex: 0x009688)
    public var extraAccent:UIColor = UIColor(netHex: 0x00796B)
    public var lightText:UIColor = UIColor(netHex: 0xFFFFFF)
    public var darkText:UIColor = UIColor(netHex: 0x000000)
    public var disabledText:UIColor = UIColor(netHex: 0xB0B0B0)
    public var inputBackground:UIColor = UIColor(netHex: 0xFFFFFF)
    public var lightBackground:UIColor = UIColor(netHex: 0xEFEFF4)
    public var activityIndicator:UIColor = UIColor(netHex: 0x203034).colorWithAlphaComponent(0.75)
    
    public var success:UIColor = UIColor(netHex: 0x037AFF)
    public var fail:UIColor = UIColor(netHex: 0xD0021B)
    
    /// Colors of phone.id button
    public var activityIndicatorInitial:UIColor!
    public var buttonSeparator:UIColor!
    
    public var buttonDisabledBackground:UIColor!
    public var buttonNormalBackground:UIColor!
    public var buttonHightlightedBackground:UIColor!
    
    public var buttonDisabledImage:UIColor!
    public var buttonNormalImage:UIColor!
    public var buttonHightlightedImage:UIColor!
    
    public var buttonDisabledText:UIColor!
    public var buttonNormalText:UIColor!
    public var buttonHightlightedText:UIColor!
    
    /// Colors common for fullscreen mode
    public var mainViewBackground:UIColor!
    public var labelTopNoteText:UIColor!
    public var labelMidNoteText:UIColor!
    public var labelBottomNoteText:UIColor!
    public var labelBottomNoteLinkText:UIColor!
    public var headerBackground:UIColor!
    public var headerTitleText:UIColor!
    public var headerButtonText:UIColor!
   
    
    /// Colors of number input
    public var activityIndicatorNumber:UIColor!
    public var buttonOKNormalText:UIColor!
    public var buttonOKHightlightedText:UIColor!
    public var buttonOKDisabledText:UIColor!
    public var inputPrefixText:UIColor!
    public var inputNumberText:UIColor!
    public var inputNumberPlaceholderText:UIColor!
    public var inputNumberBackground:UIColor!
    
    /// Colors of verification code input
    public var activityIndicatorCode:UIColor!
    public var inputCodeBackbutton:UIColor!
    public var inputCodePlaceholder:UIColor!
    public var inputCodeText:UIColor!
    public var inputCodeBackground:UIColor!
    public var inputCodeFailIcon:UIColor!
    public var inputCodeSuccessIcon:UIColor!
    
    /// Colors of country-code picker
    public var labelPrefixText:UIColor!
    public var labelPrefixBackground:UIColor!
    public var sectionIndexText:UIColor!
    
    /// Colors of profile
    public var profileCommentSectionText:UIColor!
    public var profileCommentSectionBackground:UIColor!
    public var profileDataSectionBackground:UIColor!
    public var profilePictureSectionBackground:UIColor!
    public var profilePictureBackground:UIColor!
    
    override init() {
        super.init()
        applyDefaultColors()
    }
    
    public func applyDefaultColors(){
        /// Colors of phone.id button
        activityIndicatorInitial = activityIndicator
        buttonSeparator = darkText.colorWithAlphaComponent(0.12)
        
        buttonDisabledBackground = lightBackground
        buttonNormalBackground = mainAccent
        buttonHightlightedBackground = extraAccent
        
        buttonDisabledImage = disabledText
        buttonNormalImage = lightText
        buttonHightlightedImage = disabledText
        
        buttonDisabledText = disabledText
        buttonNormalText = lightText
        buttonHightlightedText = disabledText
        
        /// Colors common for fullscreen mode
        mainViewBackground = mainAccent
        labelTopNoteText = lightText
        labelMidNoteText = lightText
        labelBottomNoteText = darkText
        labelBottomNoteLinkText = darkText
        headerBackground = extraAccent
        headerTitleText = lightText
        headerButtonText = lightText
        
        /// Colors of number input
        activityIndicatorNumber = activityIndicator
        buttonOKNormalText = mainAccent
        buttonOKHightlightedText = extraAccent
        buttonOKDisabledText = disabledText
        inputPrefixText = mainAccent
        inputNumberText = darkText
        inputNumberPlaceholderText = disabledText
        inputNumberBackground = inputBackground
        
        /// Colors of verification code input
        activityIndicatorCode = activityIndicator
        inputCodeBackbutton = mainAccent
        inputCodePlaceholder = mainAccent
        inputCodeText = darkText
        inputCodeBackground = inputBackground
        inputCodeFailIcon = fail
        inputCodeSuccessIcon = success
        
        /// Colors of country-code picker
        labelPrefixText = lightText
        labelPrefixBackground = mainAccent
        sectionIndexText = mainAccent
        
        /// Colors of profile
        profileCommentSectionText = darkText
        profileCommentSectionBackground = lightBackground
        profileDataSectionBackground = inputBackground
        profilePictureSectionBackground = mainAccent
        profilePictureBackground = inputBackground
    
    }
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

