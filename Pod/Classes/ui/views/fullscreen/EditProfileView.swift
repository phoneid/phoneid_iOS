//
//  EditProfileView.swift
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

protocol EditProfileViewDelegate:NSObjectProtocol{
    func changePhotoButtonTapped()
    func closeButtonTapped()
    func saveButtonTapped(userInfo:UserInfo)
}

public class EditProfileView: PhoneIdBaseFullscreenView {
    
    
    weak var delegate:EditProfileViewDelegate?
    
    private(set) var avatarView: WebImageView!
    private(set) var nameText: UITextField!
    private(set) var birthdayText: UITextField!
    
    private(set) var hintLabel:UILabel!
    private(set) var editButton: UIButton!
    private(set) var profileVisibilityHintLabel:UILabel!
    
    private(set) var profileView: UIView!
    
    private(set) var datePicker:UIDatePicker!
    private(set) var doneBarButton:UIBarButtonItem!
    
    public var userInfo:UserInfo!
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    convenience init(user:UserInfo, scheme:ColorScheme, bundle:NSBundle, tableName:String){
        
        self.init(frame:CGRectZero)
        userInfo = user
        colorScheme = scheme
        localizationBundle = bundle
        localizationTableName = tableName
        
        doOnInit()
    }
    
    override func doOnInit(){
        setupSubviews()
        setupLayout()
        setupWithUser(self.userInfo)
        localizeAndApplyColorScheme()
    }
    
    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupWithUser(user:UserInfo){
        self.nameText.text = user.screenName
        self.avatarView.downloadImage(user.imageURL)
        self.datePicker.date = user.dateOfBirth ?? NSDate()
    }
    
    override func setupSubviews(){
        super.setupSubviews()
        
        profileView = UIView();
        profileView.backgroundColor = UIColor.whiteColor()
        
        avatarView = WebImageView()
        avatarView.contentMode = .ScaleAspectFit
        
        nameText = UITextField()
        nameText.autocapitalizationType = .Words
        nameText.enabled = false
        
        profileVisibilityHintLabel = UILabel();
        profileVisibilityHintLabel.numberOfLines = 0
        
        hintLabel = UILabel()
        hintLabel.numberOfLines = 0
        hintLabel.alpha = 0
        
        birthdayText = UITextField()
        birthdayText.enabled = false
        
        editButton = UIButton()
        editButton.titleLabel?.textAlignment = .Left
        editButton.addTarget(self, action: "editTapped", forControlEvents: .TouchUpInside)
        
        
        let subviews:[UIView] = [titleLabel, profileView, avatarView, nameText, birthdayText, editButton, hintLabel, profileVisibilityHintLabel]
        
        for(_, element) in subviews.enumerate(){
            element.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview(element)
        }
        let layer = avatarView.layer;
        layer.masksToBounds = true
        layer.cornerRadius = 50
        
        avatarView.userInteractionEnabled = true
        avatarView.backgroundColor = colorScheme.avatarBackground
        
        datePicker = UIDatePicker()
        datePicker.datePickerMode = .Date
        datePicker.addTarget(self, action: Selector("datePickerChanged:"), forControlEvents: UIControlEvents.ValueChanged)
        self.birthdayText.inputView = datePicker
        
        let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
        let currentDate = NSDate()
        let comps = NSDateComponents()
        comps.year = -8
        datePicker.maximumDate = calendar!.dateByAddingComponents(comps, toDate:currentDate, options:[]);
        
        comps.year = -120
        datePicker.minimumDate = calendar!.dateByAddingComponents(comps, toDate:currentDate, options:[]);
        
        avatarView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "changePhotoTapped"))

        closeButton.bringSubviewToFront(self.subviews.first!)
        
        setupKeyboardToolBar()
    }
    
    override func setupLayout(){
        
        super.setupLayout()
        
        var c:[NSLayoutConstraint] = []        
        
        c.append(NSLayoutConstraint(item: profileView, attribute: .Top, relatedBy: .Equal, toItem: self.headerBackgroundView, attribute: .Bottom, multiplier: 1, constant: 0))
        c.append(NSLayoutConstraint(item: profileView, attribute: .Width, relatedBy: .Equal, toItem: self, attribute: .Width, multiplier: 1, constant: 0))
        c.append(NSLayoutConstraint(item: profileView, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1, constant: 0))
        c.append(NSLayoutConstraint(item: profileView, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1, constant: 0))
        
        c.append(NSLayoutConstraint(item: avatarView, attribute: .Top, relatedBy: .Equal, toItem: profileView, attribute: .Top, multiplier: 1, constant: 20))
        c.append(NSLayoutConstraint(item: avatarView, attribute: .Left, relatedBy: .Equal, toItem: profileView, attribute: .Left, multiplier: 1, constant: 20))
        
        c.append(NSLayoutConstraint(item: avatarView, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .Width, multiplier: 1, constant: 100))
        c.append(NSLayoutConstraint(item: avatarView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .Height, multiplier: 1, constant: 100))
        
        c.append(NSLayoutConstraint(item: nameText, attribute: .Left, relatedBy: .Equal, toItem: avatarView, attribute: .Right, multiplier: 1, constant: 20))
        c.append(NSLayoutConstraint(item: nameText, attribute: .Bottom, relatedBy: .Equal, toItem: avatarView, attribute: .CenterY, multiplier: 1, constant: -5))
        c.append(NSLayoutConstraint(item: nameText, attribute: .Right, relatedBy: .Equal, toItem: profileView, attribute: .Right, multiplier: 1, constant: -10))
        
        c.append(NSLayoutConstraint(item: birthdayText, attribute: .Left, relatedBy: .Equal, toItem: avatarView, attribute: .Right, multiplier: 1, constant: 20))
        c.append(NSLayoutConstraint(item: birthdayText, attribute: .Top, relatedBy: .Equal, toItem: avatarView, attribute: .CenterY, multiplier: 1, constant: 5))
        c.append(NSLayoutConstraint(item: birthdayText, attribute: .Right, relatedBy: .Equal, toItem: profileView, attribute: .Right, multiplier: 1, constant: -10))
        
        c.append(NSLayoutConstraint(item: hintLabel, attribute: .CenterY, relatedBy: .Equal, toItem: avatarView, attribute: .CenterY, multiplier: 1, constant: 5))
        c.append(NSLayoutConstraint(item: hintLabel, attribute: .CenterX, relatedBy: .Equal, toItem: avatarView, attribute: .CenterX, multiplier: 1, constant: 0))
        c.append(NSLayoutConstraint(item: hintLabel, attribute: .Width, relatedBy: .Equal, toItem: avatarView, attribute: .Width, multiplier: 1, constant: 0))
        
        c.append(NSLayoutConstraint(item: editButton, attribute: .CenterY, relatedBy: .Equal, toItem: titleLabel, attribute: .CenterY, multiplier: 1, constant: 0))
        c.append(NSLayoutConstraint(item: editButton, attribute: .Left, relatedBy: .Equal, toItem: self, attribute: .Left, multiplier: 1, constant: 10))
        
        c.append(NSLayoutConstraint(item: profileVisibilityHintLabel, attribute: .Top, relatedBy: .Equal, toItem: avatarView, attribute: .Bottom, multiplier: 1, constant: 20))
        c.append(NSLayoutConstraint(item: profileVisibilityHintLabel, attribute: .Left, relatedBy: .Equal, toItem: self, attribute: .Left, multiplier: 1, constant: 20))
        c.append(NSLayoutConstraint(item: profileVisibilityHintLabel, attribute: .Right, relatedBy: .Equal, toItem: self, attribute: .Right, multiplier: 1, constant: -20))
        
        
        self.customConstraints += c
        
        self.addConstraints(c)
        
    }
    
    private func setupKeyboardToolBar(){
        let toolBar = UIToolbar(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, 44))
        doneBarButton = UIBarButtonItem(title: nil, style: .Plain, target: self, action: "editComplete")
        toolBar.items = [doneBarButton]
        nameText.inputAccessoryView = toolBar
        birthdayText.inputAccessoryView = toolBar
    }
    
    override func localizeAndApplyColorScheme(){
        
        super.localizeAndApplyColorScheme()
        
        editButton.setAttributedTitle(localizedStringAttributed("html-button.title.edit.profile"), forState: .Normal)
        editButton.setAttributedTitle(localizedStringAttributed("html-button.title.save.profile"), forState: .Selected)
        
        nameText.placeholder = localizedString("profile.name.placeholder")
        birthdayText.placeholder = localizedString("profile.birthday.placeholder")
        
        titleLabel.attributedText = localizedStringAttributed("html-title.public.profile")
        hintLabel.attributedText = localizedStringAttributed("html-label.tap.to.cahnge")
        profileVisibilityHintLabel.attributedText = localizedStringAttributed("html-label.profile.view.visibility.hint")
        
        doneBarButton.title = localizedString("button.title.done.keyboard")
        doneBarButton.accessibilityLabel = localizedString("accessibility.button.title.done.keyboard")
        
        self.needsUpdateConstraints()
    }
    
    override func closeButtonTapped() {
        delegate?.closeButtonTapped()
    }
    
    func changePhotoTapped(){
        
        if(editButton.selected){
            delegate?.changePhotoButtonTapped()
        }
    }
    
    func editTapped(){
        
        editButton.selected = !editButton.selected
        birthdayText.enabled = editButton.selected
        nameText.enabled = editButton.selected
        
        if(!editButton.selected){
            editComplete()
            delegate?.saveButtonTapped(self.userInfo)
        }else{
            nameText.becomeFirstResponder()
            
            UIView.animateWithDuration(1, animations: { () -> Void in
                self.hintLabel.alpha = 1
                }, completion: { (_) -> Void in
                    UIView.animateWithDuration(2) { () -> Void in
                        self.hintLabel.alpha = 0
                }
            })
        }
    }
    
    func editComplete(){
        self.userInfo.screenName = self.nameText.text
        nameText.resignFirstResponder()
        birthdayText.resignFirstResponder()
    }
    
    func datePickerChanged(datePicker:UIDatePicker) {
        
        self.userInfo.dateOfBirth = datePicker.date
        birthdayText.text = self.userInfo.dateOfBirthAsString()
        birthdayText.selected = true
    }
    
    func isEditing() ->Bool{
        return editButton.selected
    }
}

