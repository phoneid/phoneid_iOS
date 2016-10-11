//
//  CountryCodePickerView.swift
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
import libPhoneNumber_iOS

protocol CountryCodePickerViewDelegate: NSObjectProtocol {
    func countryCodeSelected(model: NumberInfo)

    func close()
}

class CountryInfo: NSObject {
    var name: String!
    var prefix: String!
    var code: String!

    var firstLetter: String {
        get {
            return (name as NSString).substringToIndex(1)
        }
    }

    init(name: String, prefix: String, code: String) {
        super.init()
        self.name = name
        self.prefix = prefix
        self.code = code
    }

    func localizedTitle() -> String {
        return name
    }
}

typealias CountryCodePickerModel = [(letter:String, countries:[CountryInfo])]

public class CountryCodePickerView: PhoneIdBaseFullscreenView, UITableViewDataSource, UITableViewDelegate, UISearchControllerDelegate, UISearchResultsUpdating {

    private let collation = UILocalizedIndexedCollation.currentCollation()

    private(set) var tableView: UITableView!


    internal weak var delegate: CountryCodePickerViewDelegate?
    private var countrySearchController: UISearchController!

    private var sections: CountryCodePickerModel = []
    private var searchResults: CountryCodePickerModel = []

    override init(model: NumberInfo, scheme: ColorScheme, bundle: NSBundle, tableName: String) {
        super.init(model: model, scheme: scheme, bundle: bundle, tableName: tableName)
        populateCountryList()
        doOnInit()


        NSNotificationCenter.defaultCenter().addObserver(self,
                selector: #selector(CountryCodePickerView.keyboardWillShow(_:)),
                name: UIKeyboardWillShowNotification,
                object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self,
                selector: #selector(CountryCodePickerView.keyboardWillHide(_:)),
                name: UIKeyboardWillHideNotification,
                object: nil)
    }

    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)

    }

    var haveExtraSections: Bool {
        get {
            return (havePhoneSection || haveNetworkSection)
        }
    }
    var havePhoneSection: Bool {
        get {
            return phoneIdModel.phoneCountryCode != nil &&
                    !(phoneIdModel.phoneCountryCode == phoneIdModel.phoneCountryCodeSim)
        }
    }
    var haveNetworkSection: Bool {
        get {
            return phoneIdModel.phoneCountryCodeSim != nil
        }
    }
    var countOfExtraSections: Int {
        get {
            return Int(havePhoneSection) + Int(haveNetworkSection)
        }
    }

    override func setupSubviews() {
        super.setupSubviews()

        tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.registerClass(CountryCodeCell.self, forCellReuseIdentifier: "CountryCodeCell")

        tableView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(tableView)

    }

    func searchController() -> UISearchController {
        if (countrySearchController == nil) {
            countrySearchController = UISearchController(searchResultsController: nil)
            countrySearchController.searchResultsUpdater = self
            countrySearchController.delegate = self
            countrySearchController.dimsBackgroundDuringPresentation = false
            countrySearchController.hidesNavigationBarDuringPresentation = false

            tableView.tableHeaderView = countrySearchController.searchBar
        }
        return countrySearchController
    }

    override func setupLayout() {

        super.setupLayout()

        var c: [NSLayoutConstraint] = []

        c.append(NSLayoutConstraint(item: tableView, attribute: .Left, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1, constant: 0))
        c.append(NSLayoutConstraint(item: tableView, attribute: .Right, relatedBy: .Equal, toItem: self, attribute: .Right, multiplier: 1, constant: 0))
        c.append(NSLayoutConstraint(item: tableView, attribute: .Top, relatedBy: .Equal, toItem: headerBackgroundView, attribute: .Bottom, multiplier: 1, constant: 0))
        c.append(NSLayoutConstraint(item: tableView, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1, constant: 0))

        self.customConstraints += c

        self.addConstraints(c)
    }

    override func localizeAndApplyColorScheme() {
        super.localizeAndApplyColorScheme()
        titleLabel.attributedText = localizedStringAttributed("html-title.country.code")
        tableView.sectionIndexColor = colorScheme.sectionIndexText
        tableView.sectionIndexBackgroundColor = UIColor.clearColor()
        tableView.sectionIndexTrackingBackgroundColor = UIColor.clearColor()
    }


    // MARK: tableView

    public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if (self.isSearchMode()) {
            return searchResults.count
        } else {
            let sectionCount = sections.count - 1 + countOfExtraSections
            return sectionCount
        }
    }

    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: CountryCodeCell = tableView.dequeueReusableCellWithIdentifier("CountryCodeCell", forIndexPath: indexPath) as! CountryCodeCell
        cell.applyColorScheme(self.phoneIdComponentFactory.colorScheme)
        let model: CountryInfo = self.determineModel(atIndexPath: indexPath)
        cell.setupWithModel(model)
        return cell
    }

    public func tableView(tableView: UITableView, numberOfRowsInSection section: NSInteger) -> Int {

        if (self.isSearchMode()) {
            return searchResults[section].countries.count;
        } else {
            if (haveExtraSections && section < countOfExtraSections) {
                return 1
            } else {
                return sections[section - countOfExtraSections + 1].countries.count;
            }
        }
    }

    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let country: CountryInfo = self.determineModel(atIndexPath: indexPath)

        if (self.countrySearchController.searchBar.isFirstResponder()) {
            self.countrySearchController.searchBar.resignFirstResponder()
            self.countrySearchController.dismissViewControllerAnimated(false) {
                [unowned self] () -> Void in
                self.applySelection(country)
            }
        } else {
            applySelection(country)
        }
    }

    public func tableView(tableView: UITableView, titleForHeaderInSection section: NSInteger) -> String? {
        var string: String
        if (!self.isSearchMode()) {
            if (section == 0 && havePhoneSection && haveNetworkSection) {
                string = localizedString("current.phone")
            } else if (section < countOfExtraSections) {
                string = localizedString("current.network")
            } else {
                string = collation.sectionTitles[section - countOfExtraSections]
            }
        } else {
            string = searchResults[section].letter;
        }
        return string
    }

    public func tableView(tableView: UITableView, heightForHeaderInSection section: NSInteger) -> (CGFloat) {
        return CountryCodeCell.height;
    }

    public func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? {

        var result = collation.sectionIndexTitles

        if (self.isSearchMode()) {
            result = self.searchResults.map({
                (element: (letter:String, countries:[CountryInfo])) -> String in
                return element.letter
            })
        }

        result.insert("\u{0001F50D}", atIndex: 0)

        return result
    }

    public func tableView(tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int {

        if (index == 0) {
            tableView.setContentOffset(CGPointZero, animated: false)
            countrySearchController.searchBar.becomeFirstResponder()
            return NSNotFound;
        }
        return collation.sectionForSectionIndexTitleAtIndex(index - 1);

    }

    // MARK: - Utilities

    func determineModel(atIndexPath indexPath: NSIndexPath) -> CountryInfo {
        if (self.isSearchMode()) {
            return searchResults[indexPath.section].countries[indexPath.row];
        } else {
            var result: CountryInfo! = nil
            let locale = prefferedLocale()
            if (indexPath.section == 0 && havePhoneSection && haveNetworkSection) {

                let countryName = locale.displayNameForKey(NSLocaleCountryCode, value: phoneIdModel.isoCountryCode!)!;
                result = CountryInfo(name: countryName, prefix: phoneIdModel.phoneCountryCode!, code: phoneIdModel.isoCountryCode!)

            } else if (indexPath.section < countOfExtraSections) {

                let iso: String = phoneIdModel.isoCountryCodeSim != nil ? phoneIdModel.isoCountryCodeSim! : phoneIdModel.isoCountryCode!
                let cc: String = phoneIdModel.phoneCountryCodeSim != nil ? phoneIdModel.phoneCountryCodeSim! : phoneIdModel.phoneCountryCode!

                let countryName = locale.displayNameForKey(NSLocaleCountryCode, value: iso)!

                result = CountryInfo(name: countryName, prefix: cc, code: iso)
            } else {
                result = sections[indexPath.section - countOfExtraSections + 1].countries[indexPath.row];
            }
            return result
        }
    }

    func applySelection(country: CountryInfo) {

        self.phoneIdModel.isoCountryCode = country.code
        self.phoneIdModel.phoneCountryCode = country.prefix

        if let delegate = self.delegate {
            delegate.countryCodeSelected(self.phoneIdModel)
        }
    }

    func isSearchMode() -> Bool {
        let searchString: String? = self.countrySearchController?.searchBar.text
        let result = searchString != nil ? !searchString!.isEmpty : false
        return result
    }

    // MARK: - UISearchResultsUpdating

    public func updateSearchResultsForSearchController(searchController: UISearchController) {
        let searchString = searchController.searchBar.text
        self.filterContentForSearchText(searchString!);
        self.tableView.reloadData()
    }

    func filterContentForSearchText(searchText: String) {

        var result: CountryCodePickerModel = []
        if (!searchText.isEmpty) {
            for section in sections {

                let filteredCountries: [CountryInfo] = section.countries.filter({
                    (country: CountryInfo) -> Bool in                    

                    let rangeInName = country.name.rangeOfString(searchText, options: [.CaseInsensitiveSearch, .DiacriticInsensitiveSearch])

                    let rangeInPrefix = country.prefix.rangeOfString(searchText, options: [.CaseInsensitiveSearch, .DiacriticInsensitiveSearch])

                    return (rangeInPrefix != nil || rangeInName != nil)
                })

                if (filteredCountries.count > 0) {
                    result.append(letter: section.letter, countries: filteredCountries)
                }
            }
        } else {
            result = self.sections
        }
        self.searchResults = result;
    }

    func prefferedLocale() -> NSLocale {
        let langs: AnyObject = NSLocale.preferredLanguages()
        let identifier: String = (langs.firstItem as? String) ?? "en_US"
        let locale = NSLocale(localeIdentifier: identifier)
        return locale
    }

    func populateCountryList() {

        var result: CountryCodePickerModel = []

        result.append((letter: "\u{0001F50D}", countries: []))

        let countries = loadCountriesList()

        let selector: Selector = #selector(CountryInfo.localizedTitle)
        let sortedCountries: [AnyObject] = collation.sortedArrayFromArray(countries, collationStringSelector: selector)
        for c in sortedCountries {

            let sectionNumber = collation.sectionForObject(c, collationStringSelector: selector)
            let country = c as! CountryInfo
            if (sectionNumber + 1 < result.count) {
                result[sectionNumber + 1].countries.append(country)
            } else {
                result.append((letter: country.firstLetter, countries: [country]))
            }
        }

        self.sections = result
    }

    func loadCountriesList() -> [CountryInfo] {
        let countryCodeArray: Array<String> = NSLocale.ISOCountryCodes() as Array<String>;
        var countryArray: Array<CountryInfo> = [];
        let locale = prefferedLocale()
        for countryCode in countryCodeArray {
            let countryName: String = locale.displayNameForKey(NSLocaleCountryCode, value: countryCode)!;
            var countryInfo: CountryInfo!
            let phoneUtil = NBPhoneNumberUtil.sharedInstance()
            if let resolvedCountryCode = phoneUtil.getCountryCodeForRegion(countryCode) {
                if (resolvedCountryCode != 0) {
                    countryInfo = CountryInfo(name: countryName, prefix: "+\(resolvedCountryCode)", code: countryCode)
                    countryArray.append(countryInfo)
                }
            }
        }
        return countryArray

    }

    override func closeButtonTapped() {
        if (self.countrySearchController.active) {
            countrySearchController.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
        }
        if let delegate = delegate {
            delegate.close()
        }
    }

    func keyboardWillShow(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            if let keyboardSize: CGSize = userInfo[UIKeyboardFrameEndUserInfoKey]?.CGRectValue.size {
                self.tableView.contentInset = UIEdgeInsetsMake(0.0, 0.0, keyboardSize.height, 0.0);
            }
        }
    }

    func keyboardWillHide(notification: NSNotification) {
        self.tableView.contentInset = UIEdgeInsetsZero;
    }

}