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
    func changeUserNameButtonTapped()
    func closeButtonTapped()
    func saveButtonTapped(userInfo:UserInfo)
}

class DatePickerCell:UITableViewCell{
    private(set) var datePicker:UIDatePicker!
    private var expanded:Bool = false {
        didSet {
            datePicker?.hidden = !expanded
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupSubviews()
        setupLayout()
    }
    
    func setupSubviews(){
        datePicker = {
            let picker = UIDatePicker()
            picker.datePickerMode = .Date
            picker.hidden = true
            
            let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
            let currentDate = NSDate()
            let comps = NSDateComponents()
            
            comps.year = -8
            picker.maximumDate = calendar!.dateByAddingComponents(comps, toDate:currentDate, options:[]);
            
            comps.year = -120
            picker.minimumDate = calendar!.dateByAddingComponents(comps, toDate:currentDate, options:[]);
            
            return picker
            }()
        
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(datePicker)
    }
    
    func setupLayout(){
        self.removeConstraints(self.contentView.constraints)
        self.addConstraint(NSLayoutConstraint(item: datePicker, attribute: .Top, relatedBy: .Equal, toItem: self.contentView, attribute: .Top, multiplier: 1, constant: 5))
        self.addConstraint(NSLayoutConstraint(item: datePicker, attribute: .Left, relatedBy: .Equal, toItem: self.contentView, attribute: .Left, multiplier: 1, constant: 5))
        self.addConstraint(NSLayoutConstraint(item: datePicker, attribute: .Width, relatedBy: .Equal, toItem: self.contentView, attribute: .Width, multiplier: 1, constant: 5))
        self.addConstraint(NSLayoutConstraint(item: datePicker, attribute: .Height, relatedBy: .Equal, toItem: self.contentView, attribute: .Height, multiplier: 1, constant: 5))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class ProfilePictureView:UIView{
    private(set) var avatarView: WebImageView!
    private(set) var nameText: UILabel!
    private(set) var hintLabel: UILabel!
    
    init(){
        super.init(frame:CGRectZero)
        setupSubviews()
        setupLayout()
    }
    
    func setupWithUser(user:UserInfo){
        avatarView.downloadImage(user.imageURL)
        nameText.text = user.screenName
    }
    
    func setupSubviews(){
        avatarView = {
            let avatarView = WebImageView()
            avatarView.contentMode = .ScaleAspectFit
            let layer = avatarView.layer;
            layer.masksToBounds = true
            layer.cornerRadius = 50
            return avatarView
            }()
        
        nameText = {
            let label = UILabel()
            label.textAlignment = .Center
            return label
            }()
        
        hintLabel = {
            let label = UILabel()
            label.numberOfLines = 0
            label.textAlignment = .Center
            label.alpha = 0
            return label
            }()
        
        let subviews:[UIView] = [hintLabel, avatarView, nameText]
        for(_, element) in subviews.enumerate(){
            element.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview(element)
        }
    }
    
    func setupLayout(){
        self.addConstraint(NSLayoutConstraint(item: self, attribute: .Height, relatedBy: .Equal, toItem:nil, attribute: .Height, multiplier: 1, constant: 166))
        self.addConstraint(NSLayoutConstraint(item: avatarView, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: avatarView, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1, constant: 20))
        self.addConstraint(NSLayoutConstraint(item: avatarView, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .Width, multiplier: 1, constant: 100))
        self.addConstraint(NSLayoutConstraint(item: avatarView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .Height, multiplier: 1, constant: 100))
        self.addConstraint(NSLayoutConstraint(item: hintLabel, attribute: .CenterX, relatedBy: .Equal, toItem: avatarView, attribute: .CenterX, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: hintLabel, attribute: .CenterY, relatedBy: .Equal, toItem: avatarView, attribute: .CenterY, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: hintLabel, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .Width, multiplier: 1, constant: 100))
        self.addConstraint(NSLayoutConstraint(item: hintLabel, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .Height, multiplier: 1, constant: 100))
        self.addConstraint(NSLayoutConstraint(item: nameText, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: nameText, attribute: .Top, relatedBy: .Equal, toItem: self.avatarView, attribute: .Bottom, multiplier: 1, constant: 8))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

public class EditProfileView: PhoneIdBaseFullscreenView, UITableViewDataSource, UITableViewDelegate {
    
    
    weak var delegate:EditProfileViewDelegate?
    
    private(set) var table:UITableView!
    private(set) var userNameCell:UITableViewCell!
    private(set) var birthdateCell:UITableViewCell!
    private(set) var datePickerCell:DatePickerCell!
    private(set) var changePicCell:UITableViewCell!
    private(set) var numberCell:UITableViewCell!
    private(set) var profileSummaryView: ProfilePictureView!
    private(set) var footer: UITableViewHeaderFooterView!
    private(set) var activityIndicator:UIActivityIndicatorView!
    
    private var cells:[UITableViewCell]!
    
    private(set) var saveButton: UIButton!

    public var userInfo:UserInfo!
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    public var avatarImage:UIImage?{
        set{
            self.profileSummaryView.avatarView.image = newValue
        }
        get {
            return self.profileSummaryView.avatarView.image
        }
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
        userNameCell.detailTextLabel!.text = user.screenName ?? "Not Set"
        birthdateCell.detailTextLabel!.text = user.dateOfBirth != nil ? user.dateOfBirthAsString() : "Not Set"
        numberCell.detailTextLabel!.text = user.formattedPhoneNumber()
        profileSummaryView.setupWithUser(user)
        datePickerCell.datePicker.date = userInfo.dateOfBirth ?? NSDate()
    }
    
    override func setupSubviews(){
        super.setupSubviews()
        
        userNameCell = {
            let cell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "ordinary")
            cell.accessoryType = .DisclosureIndicator
            return cell
            }()
        
        birthdateCell = {
            let cell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "ordinary")
            cell.accessoryType = .DisclosureIndicator
            return cell}()
        
        datePickerCell = { let cell = DatePickerCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "expandable")
            cell.datePicker.addTarget(self, action: Selector("datePickerChanged:"), forControlEvents: UIControlEvents.ValueChanged)
            return cell
            }()
        
        
        changePicCell = {let cell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "ordinary")
            cell.accessoryType = .DisclosureIndicator
            return cell
            }()
        
        activityIndicator = {
            let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
            activityIndicator.color = self.colorScheme.profileActivityIndicator
            return activityIndicator
        }()
        
        
        numberCell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "ordinary")
        
        cells = [userNameCell, birthdateCell, datePickerCell, changePicCell, numberCell]
        
        table = { [unowned self] in
            let table = UITableView(frame: CGRectZero, style: .Grouped)
            table.delegate = self
            table.dataSource = self
            table.backgroundColor = self.colorScheme.profileCommentSectionBackground
            table.tableFooterView = UIView()
            
            return table
            }()
        
        profileSummaryView = {
            let profileView = ProfilePictureView()
            profileView.backgroundColor = colorScheme.profilePictureSectionBackground
            profileView.avatarView.backgroundColor = colorScheme.profilePictureBackground
            profileView.nameText.textColor = colorScheme.profileTopUsernameText
            profileView.avatarView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "changePhotoTapped"))
            profileView.avatarView.userInteractionEnabled = true
            profileView.avatarView.activityIndicator.color = colorScheme.profileActivityIndicator
            profileView.userInteractionEnabled = true
            return profileView
            }()
        
        saveButton = {
            let saveButton = UIButton()
            saveButton.titleLabel?.textAlignment = .Left
            saveButton.addTarget(self, action: "saveTapped", forControlEvents: .TouchUpInside)
            return saveButton
            }()
        
        footer = {
            let footer = UITableViewHeaderFooterView()
            footer.textLabel?.textColor = colorScheme.profileCommentSectionText
            footer.textLabel?.font = UIFont.systemFontOfSize(17)
            footer.textLabel?.numberOfLines = 0
            footer.textLabel?.lineBreakMode = .ByWordWrapping
            return footer
        }()
        
        let subviews:[UIView] = [titleLabel, saveButton, table, activityIndicator]
        for(_, element) in subviews.enumerate(){
            element.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview(element)
        }

    }
    
    override func setupLayout(){
        
        super.setupLayout()
        
        var c:[NSLayoutConstraint] = []
        
        c.append(NSLayoutConstraint(item: activityIndicator, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1, constant: 0))
        c.append(NSLayoutConstraint(item: activityIndicator, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1, constant: 0))
        
        c.append(NSLayoutConstraint(item: table, attribute: .Top, relatedBy: .Equal, toItem: headerBackgroundView, attribute: .Bottom, multiplier: 1, constant: 0))
        c.append(NSLayoutConstraint(item: table, attribute: .Width, relatedBy: .Equal, toItem: self, attribute: .Width, multiplier: 1, constant: 0))
        c.append(NSLayoutConstraint(item: table, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1, constant: 0))
        c.append(NSLayoutConstraint(item: table, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1, constant: 0))
        c.append(NSLayoutConstraint(item: saveButton, attribute: .CenterY, relatedBy: .Equal, toItem: titleLabel, attribute: .CenterY, multiplier: 1, constant: 0))
        c.append(NSLayoutConstraint(item: saveButton, attribute: .Right, relatedBy: .Equal, toItem: self, attribute: .Right, multiplier: 1, constant: -10))
        
        
        self.customConstraints += c

        self.addConstraints(c)
        
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        let newSize = profileSummaryView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize)
        profileSummaryView.frame = CGRectMake(0, 0, table.bounds.size.height, newSize.height)
        table.tableHeaderView = profileSummaryView
    }
    
    override func localizeAndApplyColorScheme(){
        
        super.localizeAndApplyColorScheme()
        
        userNameCell.textLabel!.text = localizedString("profile.name.placeholder")
        birthdateCell.textLabel!.text = localizedString("profile.birthday.placeholder")
        changePicCell.textLabel!.text = localizedString("profile.change.picture")
        numberCell.textLabel!.text = localizedString("profile.phone.number")
        
        saveButton.setAttributedTitle(localizedStringAttributed("html-button.title.save.profile"), forState: .Normal)

        titleLabel.text = localizedString("title.public.profile")
        titleLabel.textColor = self.colorScheme.headerTitleText
        titleLabel.textAlignment = .Center

        self.needsUpdateConstraints()
    }
    
    override func closeButtonTapped() {
        delegate?.closeButtonTapped()
    }
    
    func changePhotoTapped(){
         delegate?.changePhotoButtonTapped()
    }
    

    func saveTapped(){
        delegate?.saveButtonTapped(self.userInfo)
    }
    
    func datePickerChanged(datePicker:UIDatePicker) {
        
        self.userInfo.dateOfBirth = datePicker.date
        self.birthdateCell.detailTextLabel!.text = self.userInfo.dateOfBirthAsString()
    }

    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cells.count
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return cells[indexPath.row]
    }
    
    public func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        var result:CGFloat = 44

       if let cell = cells[indexPath.row] as? DatePickerCell{
           result = cell.expanded ? 177 : 0
       }

        
        return result
    }
    
    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)  {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        switch(indexPath.row){
        case 0:
            delegate?.changeUserNameButtonTapped()
            break
        case 1:
            tableView.beginUpdates()
            datePickerCell.expanded = !datePickerCell.expanded
            tableView.endUpdates()
            break
        case 3:
            delegate?.changePhotoButtonTapped()
            break
        default: break
        
        }
    }
    
    public func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return "Your phone number won’t be shared with anyone, but people who already know your number will be able to look for you."
    }
    
    public func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return footer
    }
    
    public func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 100
    }
    
    public func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
}

