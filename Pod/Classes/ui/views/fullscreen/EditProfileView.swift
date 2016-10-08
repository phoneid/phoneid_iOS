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

protocol EditProfileViewDelegate: NSObjectProtocol {
    func changePhotoButtonTapped()

    func changeUserNameButtonTapped()

    func closeButtonTapped()

    func saveButtonTapped(_ userInfo: UserInfo)
}

class DatePickerCell: UITableViewCell {
    fileprivate(set) var datePicker: UIDatePicker!
    fileprivate var expanded: Bool = false {
        didSet {
            datePicker?.isHidden = !expanded
        }
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupSubviews()
        setupLayout()
    }

    func setupSubviews() {
        datePicker = {
            let picker = UIDatePicker()
            picker.datePickerMode = .date
            picker.isHidden = true

            let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
            let currentDate = Date()
            var comps = DateComponents()

            comps.year = -8
            picker.maximumDate = (calendar as NSCalendar).date(byAdding: comps, to: currentDate, options: []);

            comps.year = -120
            picker.minimumDate = (calendar as NSCalendar).date(byAdding: comps, to: currentDate, options: []);

            return picker
        }()

        datePicker.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(datePicker)
    }

    func setupLayout() {
        self.removeConstraints(self.contentView.constraints)
        self.addConstraint(NSLayoutConstraint(item: datePicker, attribute: .top, relatedBy: .equal, toItem: self.contentView, attribute: .top, multiplier: 1, constant: 5))
        self.addConstraint(NSLayoutConstraint(item: datePicker, attribute: .left, relatedBy: .equal, toItem: self.contentView, attribute: .left, multiplier: 1, constant: 5))
        self.addConstraint(NSLayoutConstraint(item: datePicker, attribute: .width, relatedBy: .equal, toItem: self.contentView, attribute: .width, multiplier: 1, constant: 5))
        self.addConstraint(NSLayoutConstraint(item: datePicker, attribute: .height, relatedBy: .equal, toItem: self.contentView, attribute: .height, multiplier: 1, constant: 5))
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class ProfilePictureView: UIView {
    fileprivate(set) var avatarView: WebImageView!
    fileprivate(set) var nameText: UILabel!
    fileprivate(set) var hintLabel: UILabel!

    init() {
        super.init(frame: CGRect.zero)
        setupSubviews()
        setupLayout()
    }

    func setupWithUser(_ user: UserInfo) {
        hintLabel.isHidden = (user.imageURL != nil)
        avatarView.downloadImage(user.imageURL)
        nameText.text = user.screenName
    }

    func setupSubviews() {
        avatarView = {
            let avatarView = WebImageView()
            avatarView.contentMode = .scaleAspectFit
            let layer = avatarView.layer;
            layer.masksToBounds = true
            layer.cornerRadius = 50
            return avatarView
        }()

        nameText = {
            let label = UILabel()
            label.textAlignment = .center
            return label
        }()

        hintLabel = {
            let label = UILabel()
            label.numberOfLines = 0
            label.textAlignment = .center
            return label
        }()

        let subviews: [UIView] = [avatarView, nameText, hintLabel]
        for (_, element) in subviews.enumerated() {
            element.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview(element)
        }
    }

    func setupLayout() {
        self.addConstraint(NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 166))
        self.addConstraint(NSLayoutConstraint(item: avatarView, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: avatarView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 20))
        self.addConstraint(NSLayoutConstraint(item: avatarView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: 100))
        self.addConstraint(NSLayoutConstraint(item: avatarView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 100))
        self.addConstraint(NSLayoutConstraint(item: hintLabel, attribute: .centerX, relatedBy: .equal, toItem: avatarView, attribute: .centerX, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: hintLabel, attribute: .centerY, relatedBy: .equal, toItem: avatarView, attribute: .centerY, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: hintLabel, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: 100))
        self.addConstraint(NSLayoutConstraint(item: hintLabel, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 100))
        self.addConstraint(NSLayoutConstraint(item: nameText, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: nameText, attribute: .top, relatedBy: .equal, toItem: self.avatarView, attribute: .bottom, multiplier: 1, constant: 8))
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

open class EditProfileView: PhoneIdBaseFullscreenView, UITableViewDataSource, UITableViewDelegate {


    weak var delegate: EditProfileViewDelegate?

    fileprivate(set) var table: UITableView!
    fileprivate(set) var userNameCell: UITableViewCell!
    fileprivate(set) var birthdateCell: UITableViewCell!
    fileprivate(set) var datePickerCell: DatePickerCell!
    fileprivate(set) var changePicCell: UITableViewCell!
    fileprivate(set) var numberCell: UITableViewCell!
    fileprivate(set) var profileSummaryView: ProfilePictureView!
    fileprivate(set) var footer: UITableViewHeaderFooterView!
    fileprivate(set) var activityIndicator: UIActivityIndicatorView!

    fileprivate var cells: [UITableViewCell]!

    fileprivate(set) var saveButton: UIButton!

    open var userInfo: UserInfo!

    override public init(frame: CGRect) {
        super.init(frame: frame)
    }

    open var avatarImage: UIImage? {
        set {
            self.profileSummaryView.avatarView.image = newValue
            self.profileSummaryView.hintLabel.isHidden = newValue != nil
        }
        get {
            return self.profileSummaryView.avatarView.image
        }
    }

    convenience init(user: UserInfo, scheme: ColorScheme, bundle: Bundle, tableName: String) {

        self.init(frame: CGRect.zero)
        userInfo = user
        colorScheme = scheme
        localizationBundle = bundle
        localizationTableName = tableName

        doOnInit()
    }

    override func doOnInit() {
        setupSubviews()
        setupLayout()
        setupWithUser(self.userInfo)
        localizeAndApplyColorScheme()
    }

    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupWithUser(_ user: UserInfo) {
        userNameCell.detailTextLabel!.text = user.screenName ?? localizedString("profile.value.not.set")
        birthdateCell.detailTextLabel!.text = user.dateOfBirth != nil ? user.dateOfBirthAsString() : localizedString("profile.value.not.set")
        numberCell.detailTextLabel!.text = user.formattedPhoneNumber()
        profileSummaryView.setupWithUser(user)
        datePickerCell.datePicker.date = userInfo.dateOfBirth as Date? ?? Date()
    }

    override func setupSubviews() {
        super.setupSubviews()

        userNameCell = {
            let cell = UITableViewCell(style: UITableViewCellStyle.value1, reuseIdentifier: "ordinary")
            cell.accessoryType = .disclosureIndicator
            return cell
        }()

        birthdateCell = {
            let cell = UITableViewCell(style: UITableViewCellStyle.value1, reuseIdentifier: "ordinary")
            cell.accessoryType = .disclosureIndicator
            return cell
        }()

        datePickerCell = {
            let cell = DatePickerCell(style: UITableViewCellStyle.value1, reuseIdentifier: "expandable")
            cell.datePicker.addTarget(self, action: #selector(EditProfileView.datePickerChanged(_:)), for: UIControlEvents.valueChanged)
            return cell
        }()


        changePicCell = {
            let cell = UITableViewCell(style: UITableViewCellStyle.value1, reuseIdentifier: "ordinary")
            cell.accessoryType = .disclosureIndicator
            return cell
        }()

        activityIndicator = {
            let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
            activityIndicator.color = self.colorScheme.profileActivityIndicator
            return activityIndicator
        }()


        numberCell = UITableViewCell(style: UITableViewCellStyle.value1, reuseIdentifier: "ordinary")

        cells = [userNameCell, birthdateCell, datePickerCell, changePicCell, numberCell]

        table = {
            [unowned self] in
            let table = UITableView(frame: CGRect.zero, style: .grouped)
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
            profileView.hintLabel.textColor = colorScheme.profilePictureEditingHintText
            profileView.avatarView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(EditProfileView.changePhotoTapped)))
            profileView.avatarView.isUserInteractionEnabled = true
            profileView.avatarView.activityIndicator.color = colorScheme.profileActivityIndicator
            profileView.isUserInteractionEnabled = true
            return profileView
        }()

        saveButton = {
            let saveButton = UIButton()
            saveButton.titleLabel?.textAlignment = .left
            saveButton.addTarget(self, action: #selector(EditProfileView.saveTapped), for: .touchUpInside)
            return saveButton
        }()

        footer = {
            let footer = UITableViewHeaderFooterView()
            footer.textLabel?.textColor = colorScheme.profileCommentSectionText
            footer.textLabel?.font = UIFont.systemFont(ofSize: 17)
            footer.textLabel?.numberOfLines = 0
            footer.textLabel?.lineBreakMode = .byWordWrapping
            return footer
        }()

        let subviews: [UIView] = [titleLabel, saveButton, table, activityIndicator]
        for (_, element) in subviews.enumerated() {
            element.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview(element)
        }

    }

    override func setupLayout() {

        super.setupLayout()

        var c: [NSLayoutConstraint] = []

        c.append(NSLayoutConstraint(item: activityIndicator, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0))
        c.append(NSLayoutConstraint(item: activityIndicator, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))

        c.append(NSLayoutConstraint(item: table, attribute: .top, relatedBy: .equal, toItem: headerBackgroundView, attribute: .bottom, multiplier: 1, constant: 0))
        c.append(NSLayoutConstraint(item: table, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 1, constant: 0))
        c.append(NSLayoutConstraint(item: table, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0))
        c.append(NSLayoutConstraint(item: table, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0))
        c.append(NSLayoutConstraint(item: saveButton, attribute: .centerY, relatedBy: .equal, toItem: titleLabel, attribute: .centerY, multiplier: 1, constant: 0))
        c.append(NSLayoutConstraint(item: saveButton, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1, constant: -10))


        self.customConstraints += c

        self.addConstraints(c)

    }

    open override func layoutSubviews() {
        super.layoutSubviews()
        let newSize = profileSummaryView.systemLayoutSizeFitting(UILayoutFittingCompressedSize)
        profileSummaryView.frame = CGRect(x: 0, y: 0, width: table.bounds.size.height, height: newSize.height)
        table.tableHeaderView = profileSummaryView
    }

    override func localizeAndApplyColorScheme() {

        super.localizeAndApplyColorScheme()

        profileSummaryView.hintLabel.text = localizedString("profile.hint.photo")

        userNameCell.textLabel!.text = localizedString("profile.name.placeholder")
        birthdateCell.textLabel!.text = localizedString("profile.birthday.placeholder")
        changePicCell.textLabel!.text = localizedString("profile.change.picture")
        numberCell.textLabel!.text = localizedString("profile.phone.number")

        saveButton.setAttributedTitle(localizedStringAttributed("html-button.title.save.profile"), for: UIControlState())

        titleLabel.text = localizedString("title.public.profile")
        titleLabel.textColor = self.colorScheme.headerTitleText
        titleLabel.textAlignment = .center

        self.needsUpdateConstraints()
    }

    override func closeButtonTapped() {
        delegate?.closeButtonTapped()
    }

    func changePhotoTapped() {
        delegate?.changePhotoButtonTapped()
    }


    func saveTapped() {
        delegate?.saveButtonTapped(self.userInfo)
    }

    func datePickerChanged(_ datePicker: UIDatePicker) {

        self.userInfo.dateOfBirth = datePicker.date
        self.birthdateCell.detailTextLabel!.text = self.userInfo.dateOfBirthAsString()
    }

    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cells.count
    }

    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = cells[(indexPath as NSIndexPath).row]
        cell.backgroundColor = self.colorScheme.profileDataSectionBackground
        cell.textLabel?.textColor = self.colorScheme.profileDataSectionTitleText
        cell.detailTextLabel?.textColor = self.colorScheme.profileDataSectionValueText
        return cell
    }

    open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        var result: CGFloat = 44

        if let cell = cells[(indexPath as NSIndexPath).row] as? DatePickerCell {
            result = cell.expanded ? 177 : 0
        }


        return result
    }

    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        switch ((indexPath as NSIndexPath).row) {
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

    open func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return self.localizedString("profile.hint.about.number")
    }

    open func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return footer
    }

    open func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 100
    }

    open func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
}

