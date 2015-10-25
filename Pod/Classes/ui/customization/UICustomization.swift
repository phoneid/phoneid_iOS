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
    var colorScheme: ColorScheme! {get }
    var localizationBundle:NSBundle! {get }
    var localizationTableName:String! {get }
    
}

public class ColorScheme : NSObject{
    // MARK: Common colors defining color scheme
    public var mainAccent:UIColor = UIColor(hex: 0x009688)
    public var extraAccent:UIColor = UIColor(hex: 0x00796B)
    public var lightText:UIColor = UIColor(hex: 0xFFFFFF)
    public var darkText:UIColor = UIColor(hex: 0x000000)
    public var disabledText:UIColor = UIColor(hex: 0xB0B0B0)
    public var inputBackground:UIColor = UIColor(hex: 0xFFFFFF)
    public var diabledBackground:UIColor = UIColor(hex: 0xEFEFF4)
    public var activityIndicator:UIColor = UIColor(hex: 0x203034).colorWithAlphaComponent(0.75)
    
    public var success:UIColor = UIColor(hex: 0x037AFF)
    public var fail:UIColor = UIColor(hex: 0xD0021B)
    
    // MARK: Specific colors: phone.id button
    public var activityIndicatorInitial:UIColor!
    public var buttonSeparator:UIColor!
    
    // phone.id button background
    public var buttonDisabledBackground:UIColor!
    public var buttonNormalBackground:UIColor!
    public var buttonHighlightedBackground:UIColor!
    
    // phone.id button image
    public var buttonDisabledImage:UIColor!
    public var buttonNormalImage:UIColor!
    public var buttonHighlightedImage:UIColor!
    
    // phone.id button text
    public var buttonDisabledText:UIColor!
    public var buttonNormalText:UIColor!
    public var buttonHighlightedText:UIColor!
    
    // MARK: Specific colors: fullscreen mode
    public var mainViewBackground:UIColor!
    public var labelTopNoteText:UIColor!
    public var labelMidNoteText:UIColor!
    public var labelBottomNoteText:UIColor!
    public var labelBottomNoteLinkText:UIColor!
    public var headerBackground:UIColor!
    public var headerTitleText:UIColor!
    public var headerButtonText:UIColor!
    
    // MARK: Specific colors: related to number input
    public var activityIndicatorNumber:UIColor!
    public var buttonOKNormalText:UIColor!
    public var buttonOKHighlightedText:UIColor!
    public var buttonOKDisabledText:UIColor!
    public var inputPrefixText:UIColor!
    public var inputNumberText:UIColor!
    public var inputNumberPlaceholderText:UIColor!
    public var inputNumberBackground:UIColor!
    
    // MARK: Specific colors: related to code verification
    public var activityIndicatorCode:UIColor!
    public var inputCodeBackbuttonNormal:UIColor!
    public var inputCodeBackbuttonDisabled:UIColor!
    public var inputCodePlaceholder:UIColor!
    public var inputCodeText:UIColor!
    public var inputCodeBackground:UIColor!
    public var inputCodeFailIcon:UIColor!
    public var inputCodeSuccessIcon:UIColor!
    
    // MARK: Specific colors: related to country-code picker
    public var labelPrefixText:UIColor!
    public var labelCountryNameText:UIColor!
    public var labelPrefixBackground:UIColor!
    public var sectionIndexText:UIColor!
    
    // MARK: Specific colors: related to profile
    public var profileCommentSectionText:UIColor!
    public var profileCommentSectionBackground:UIColor!
    public var profileDataSectionTitleText:UIColor!
    public var profileDataSectionValueText:UIColor!
    public var profileDataSectionBackground:UIColor!
    public var profilePictureSectionBackground:UIColor!
    public var profilePictureBackground:UIColor!
    public var profileTopUsernameText:UIColor!
    public var profilePictureEditingHintText:UIColor!
    public var profileActivityIndicator:UIColor!
    
    override public init() {
        super.init()
        applyCommonColors()
    }
    
    public func applyCommonColors(){
        /// Colors of phone.id button
        activityIndicatorInitial = activityIndicator
        buttonSeparator = darkText.colorWithAlphaComponent(0.12)
        
        buttonDisabledBackground = diabledBackground
        buttonNormalBackground = mainAccent
        buttonHighlightedBackground = extraAccent
        
        buttonDisabledImage = disabledText
        buttonNormalImage = lightText
        buttonHighlightedImage = disabledText
        
        buttonDisabledText = disabledText
        buttonNormalText = lightText
        buttonHighlightedText = disabledText
        
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
        buttonOKHighlightedText = extraAccent
        buttonOKDisabledText = disabledText
        inputPrefixText = mainAccent
        inputNumberText = darkText
        inputNumberPlaceholderText = disabledText
        inputNumberBackground = inputBackground
        
        /// Colors of verification code input
        activityIndicatorCode = activityIndicator
        inputCodeBackbuttonNormal = mainAccent
        inputCodeBackbuttonDisabled = disabledText
        inputCodePlaceholder = mainAccent
        inputCodeText = darkText
        inputCodeBackground = inputBackground
        inputCodeFailIcon = fail
        inputCodeSuccessIcon = success
        
        /// Colors of country-code picker
        labelPrefixText = lightText
        labelCountryNameText = darkText
        labelPrefixBackground = mainAccent
        sectionIndexText = mainAccent
        
        /// Colors of profile
        profileCommentSectionText = darkText
        profileCommentSectionBackground = diabledBackground
        profileDataSectionTitleText = darkText
        profileDataSectionValueText = disabledText
        profileDataSectionBackground = inputBackground
        profilePictureSectionBackground = mainAccent
        profilePictureBackground = inputBackground
        profileTopUsernameText = lightText
        profilePictureEditingHintText = darkText
        profileActivityIndicator = activityIndicator
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

public extension UIColor {
    public convenience init(red: Int, green: Int, blue: Int) {
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    public convenience init(hex:Int) {
        self.init(red:(hex >> 16) & 0xff, green:(hex >> 8) & 0xff, blue:hex & 0xff)
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

