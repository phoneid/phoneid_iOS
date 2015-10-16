//
//  UserNameView.swift
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
import UIKit

public class UserNameView: PhoneIdBaseFullscreenView, UITextFieldDelegate {
    
    
    private(set) var userNameLabel: UILabel!
    private(set) var userNameField: UITextField!
    private(set) var noteLabel: UILabel!
    
    var containerView: UIView!
    
    var containerTopConstraint: NSLayoutConstraint!
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    convenience init(userName:String?, scheme:ColorScheme, bundle:NSBundle, tableName:String){
        
        self.init(frame:CGRectZero)
        
        colorScheme = scheme
        localizationBundle = bundle
        localizationTableName = tableName
        
        doOnInit()
        
        userNameField.text = userName
    }
    
    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func doOnInit(){
        setupSubviews()
        
        setupLayout()
        
        localizeAndApplyColorScheme()
    }
    
    internal override func setupSubviews(){

        super.setupSubviews()
        
        containerView = UIView()
        
        userNameLabel = {
            let label = UILabel()
            label.sizeToFit()
            label.numberOfLines = 1
            return label
            }()
        
        
        userNameField = {
            let textField = UITextField()
            textField.delegate = self
            return textField
            
            }()
        
        
        noteLabel = {
            let note = UILabel()
            note.numberOfLines = 0
            return note
            }()
        
        let subviews:[UIView] = [containerView, userNameLabel, userNameField, noteLabel]
        for(_, element) in subviews.enumerate(){
            element.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview(element)
        }
    }
    
    override func setupLayout(){
        
        super.setupLayout()
        
        var c:[NSLayoutConstraint] = []
        
        c.append(NSLayoutConstraint(item: containerView, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Width, multiplier: 1, constant: 0))
        c.append(NSLayoutConstraint(item: containerView, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 44))
        c.append(NSLayoutConstraint(item: containerView, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Leading, multiplier: 1, constant: 0))
        c.append(NSLayoutConstraint(item: containerView, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 74))
        
        c.append(NSLayoutConstraint(item: userNameLabel, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: self.containerView, attribute: NSLayoutAttribute.Height, multiplier: 1, constant: 0))
        c.append(NSLayoutConstraint(item: userNameLabel, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 80))
        c.append(NSLayoutConstraint(item: userNameLabel, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: self.containerView, attribute: NSLayoutAttribute.Leading, multiplier: 1, constant: 10))
        c.append(NSLayoutConstraint(item: userNameLabel, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: self.containerView, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 0))
        
        c.append(NSLayoutConstraint(item: userNameField, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: self.containerView, attribute: NSLayoutAttribute.Height, multiplier: 1, constant: 0))
        c.append(NSLayoutConstraint(item: userNameField, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: self.userNameLabel, attribute: NSLayoutAttribute.Trailing, multiplier: 1, constant: 10))
        c.append(NSLayoutConstraint(item: userNameField, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Trailing, multiplier: 1, constant: -10))
        c.append(NSLayoutConstraint(item: userNameField, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: self.containerView, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 0))
        
        
        c.append(NSLayoutConstraint(item: noteLabel, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Leading, multiplier: 1, constant: 20))
        c.append(NSLayoutConstraint(item: noteLabel, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Trailing, multiplier: 1, constant: -20))
        c.append(NSLayoutConstraint(item: noteLabel, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: self.containerView, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 10))
        
        self.addConstraints(c)
        
    }
    
    override func localizeAndApplyColorScheme() {
        super.localizeAndApplyColorScheme()
        
        userNameLabel.text = localizedString("title.public.profile")
        noteLabel.text = localizedString("profile.hint.about.name")
        
        self.backgroundColor = self.colorScheme.profileCommentSectionBackground
        //self.userNameField.text = self.colorScheme.profileDataSectionBackground
        
    }
    
    // MARK: UITextFieldDelegate
    
    public func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange,
        replacementString string: String) -> Bool
    {
        let maxLength = 512
        let currentString: NSString = textField.text!
        let newString: NSString =
        currentString.stringByReplacingCharactersInRange(range, withString: string)
        return newString.length <= maxLength
    }
}