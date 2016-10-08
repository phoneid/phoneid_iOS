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
    var localizationBundle:Bundle! {get }
    var localizationTableName:String! {get }
    
}

open class ColorScheme : NSObject{
    // MARK: Common colors defining color scheme
    open var mainAccent:UIColor = UIColor(hex: 0x009688)
    open var extraAccent:UIColor = UIColor(hex: 0x00796B)
    open var lightText:UIColor = UIColor(hex: 0xFFFFFF)
    open var darkText:UIColor = UIColor(hex: 0x000000)
    open var disabledText:UIColor = UIColor(hex: 0xB0B0B0)
    open var inputBackground:UIColor = UIColor(hex: 0xFFFFFF)
    open var diabledBackground:UIColor = UIColor(hex: 0xEFEFF4)
    open var activityIndicator:UIColor = UIColor(hex: 0x203034).withAlphaComponent(0.75)
    
    open var success:UIColor = UIColor(hex: 0x037AFF)
    open var fail:UIColor = UIColor(hex: 0xD0021B)
    
    // MARK: Specific colors: phone.id button
    open var activityIndicatorInitial:UIColor!
    open var buttonSeparator:UIColor!
    
    // phone.id button background
    open var buttonDisabledBackground:UIColor!
    open var buttonNormalBackground:UIColor!
    open var buttonHighlightedBackground:UIColor!
    
    // phone.id button image
    open var buttonDisabledImage:UIColor!
    open var buttonNormalImage:UIColor!
    open var buttonHighlightedImage:UIColor!
    
    // phone.id button text
    open var buttonDisabledText:UIColor!
    open var buttonNormalText:UIColor!
    open var buttonHighlightedText:UIColor!
    
    // MARK: Specific colors: fullscreen mode
    open var mainViewBackground:UIColor!
    open var labelTopNoteText:UIColor!
    open var labelMidNoteText:UIColor!
    open var labelBottomNoteText:UIColor!
    open var labelBottomNoteLinkText:UIColor!
    open var headerBackground:UIColor!
    open var headerTitleText:UIColor!
    open var headerButtonText:UIColor!
    
    // MARK: Specific colors: related to number input
    open var activityIndicatorNumber:UIColor!
    open var buttonOKNormalText:UIColor!
    open var buttonOKHighlightedText:UIColor!
    open var buttonOKDisabledText:UIColor!
    open var inputPrefixText:UIColor!
    open var inputNumberText:UIColor!
    open var inputNumberPlaceholderText:UIColor!
    open var inputNumberBackground:UIColor!
    
    // MARK: Specific colors: related to code verification
    open var activityIndicatorCode:UIColor!
    open var inputCodeBackbuttonNormal:UIColor!
    open var inputCodeBackbuttonDisabled:UIColor!
    open var inputCodePlaceholder:UIColor!
    open var inputCodeText:UIColor!
    open var inputCodeBackground:UIColor!
    open var inputCodeFailIcon:UIColor!
    open var inputCodeSuccessIcon:UIColor!
    
    // MARK: Specific colors: related to country-code picker
    open var labelPrefixText:UIColor!
    open var labelCountryNameText:UIColor!
    open var labelPrefixBackground:UIColor!
    open var sectionIndexText:UIColor!
    
    // MARK: Specific colors: related to profile
    open var profileCommentSectionText:UIColor!
    open var profileCommentSectionBackground:UIColor!
    open var profileDataSectionTitleText:UIColor!
    open var profileDataSectionValueText:UIColor!
    open var profileDataSectionBackground:UIColor!
    open var profilePictureSectionBackground:UIColor!
    open var profilePictureBackground:UIColor!
    open var profileTopUsernameText:UIColor!
    open var profilePictureEditingHintText:UIColor!
    open var profileActivityIndicator:UIColor!
    
    override public init() {
        super.init()
        applyCommonColors()
    }
    
    open func applyCommonColors(){
        /// Colors of phone.id button
        activityIndicatorInitial = activityIndicator
        buttonSeparator = darkText.withAlphaComponent(0.12)
        
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
    func replaceNamedColors(_ input:String)->String
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
            if let color = ((self as AnyObject).value(forKeyPath: name) as? UIColor){
                let hexColor = color.hexString()
                result.replaceOccurrences(of: "$\(name)", with: hexColor, options:NSString.CompareOptions.literal, range: NSMakeRange(0, result.length))
            }
        }
        
        return result as String
    }
}


public extension Customizable{

    internal func localizedString(_ key:String, formatting:((String)->String)? = nil) ->String{

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

    internal func localizedStringAttributed(_ key:String, formatting:((String)->String)? = nil) ->NSAttributedString{
        let text = localizedString(key, formatting: formatting)
        let accessAttributedText = try! NSAttributedString(
            data: text.data(using: String.Encoding.unicode, allowLossyConversion: true)!,
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

