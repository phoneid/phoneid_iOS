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
    func countryCodeSelected(_ model: NumberInfo)

    func close()
}

class CountryInfo: NSObject {
    var name: String!
    var prefix: String!
    var code: String!

    var firstLetter: String {
        get {
            return (name as NSString).substring(to: 1)
        }
    }

    init(name: String, prefix: String, code: String) {
        super.init()
        self.name = name
        self.prefix = prefix
        self.code = code
    }

    @objc func localizedTitle() -> String {
        return name
    }
}

typealias CountryCodePickerModel = [(letter:String, countries:[CountryInfo])]

open class CountryCodePickerView: PhoneIdBaseFullscreenView, UITableViewDataSource, UITableViewDelegate, UISearchControllerDelegate, UISearchResultsUpdating {

    fileprivate let collation = UILocalizedIndexedCollation.current()

    fileprivate(set) var tableView: UITableView!


    internal weak var delegate: CountryCodePickerViewDelegate?
    fileprivate var countrySearchController: UISearchController!

    fileprivate var sections: CountryCodePickerModel = []
    fileprivate var searchResults: CountryCodePickerModel = []

    override init(model: NumberInfo, scheme: ColorScheme, bundle: Bundle, tableName: String) {
        super.init(model: model, scheme: scheme, bundle: bundle, tableName: tableName)
        populateCountryList()
        doOnInit()


        NotificationCenter.default.addObserver(self,
                selector: #selector(CountryCodePickerView.keyboardWillShow(_:)),
                name: NSNotification.Name.UIKeyboardWillShow,
                object: nil)
        NotificationCenter.default.addObserver(self,
                selector: #selector(CountryCodePickerView.keyboardWillHide(_:)),
                name: NSNotification.Name.UIKeyboardWillHide,
                object: nil)
    }

    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)

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
            return Int(havePhoneSection ? 1 : 0) + Int(haveNetworkSection ? 1 : 0)
        }
    }

    override func setupSubviews() {
        super.setupSubviews()

        tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(CountryCodeCell.self, forCellReuseIdentifier: "CountryCodeCell")

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

        c.append(NSLayoutConstraint(item: tableView, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: 0))
        c.append(NSLayoutConstraint(item: tableView, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1, constant: 0))
        c.append(NSLayoutConstraint(item: tableView, attribute: .top, relatedBy: .equal, toItem: headerBackgroundView, attribute: .bottom, multiplier: 1, constant: 0))
        c.append(NSLayoutConstraint(item: tableView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0))

        self.customConstraints += c

        self.addConstraints(c)
    }

    override func localizeAndApplyColorScheme() {
        super.localizeAndApplyColorScheme()
        titleLabel.attributedText = localizedStringAttributed("html-title.country.code")
        tableView.sectionIndexColor = colorScheme.sectionIndexText
        tableView.sectionIndexBackgroundColor = UIColor.clear
        tableView.sectionIndexTrackingBackgroundColor = UIColor.clear
    }


    // MARK: tableView

    open func numberOfSections(in tableView: UITableView) -> Int {
        if (self.isSearchMode()) {
            return searchResults.count
        } else {
            let sectionCount = sections.count - 1 + countOfExtraSections
            return sectionCount
        }
    }

    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: CountryCodeCell = tableView.dequeueReusableCell(withIdentifier: "CountryCodeCell", for: indexPath) as! CountryCodeCell
        cell.applyColorScheme(self.phoneIdComponentFactory.colorScheme)
        let model: CountryInfo = self.determineModel(atIndexPath: indexPath)
        cell.setupWithModel(model)
        return cell
    }

    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: NSInteger) -> Int {

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

    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let country: CountryInfo = self.determineModel(atIndexPath: indexPath)

        if (self.countrySearchController.searchBar.isFirstResponder) {
            self.countrySearchController.searchBar.resignFirstResponder()
            self.countrySearchController.dismiss(animated: false) {
                [unowned self] () -> Void in
                self.applySelection(country)
            }
        } else {
            applySelection(country)
        }
    }

    open func tableView(_ tableView: UITableView, titleForHeaderInSection section: NSInteger) -> String? {
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

    open func tableView(_ tableView: UITableView, heightForHeaderInSection section: NSInteger) -> (CGFloat) {
        return CountryCodeCell.height;
    }

    open func sectionIndexTitles(for tableView: UITableView) -> [String]? {

        var result = collation.sectionIndexTitles

        if (self.isSearchMode()) {
            result = self.searchResults.map({
                (element: (letter:String, countries:[CountryInfo])) -> String in
                return element.letter
            })
        }

        result.insert("\u{0001F50D}", at: 0)

        return result
    }

    open func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {

        if (index == 0) {
            tableView.setContentOffset(CGPoint.zero, animated: false)
            countrySearchController.searchBar.becomeFirstResponder()
            return NSNotFound;
        }
        return collation.section(forSectionIndexTitle: index - 1);

    }

    // MARK: - Utilities

    func determineModel(atIndexPath indexPath: IndexPath) -> CountryInfo {
        if (self.isSearchMode()) {
            return searchResults[(indexPath as NSIndexPath).section].countries[(indexPath as NSIndexPath).row];
        } else {
            var result: CountryInfo! = nil
            let locale = prefferedLocale()
            if ((indexPath as NSIndexPath).section == 0 && havePhoneSection && haveNetworkSection) {

                let countryName = (locale as NSLocale).displayName(forKey: NSLocale.Key.countryCode, value: phoneIdModel.isoCountryCode!)!;
                result = CountryInfo(name: countryName, prefix: phoneIdModel.phoneCountryCode!, code: phoneIdModel.isoCountryCode!)

            } else if ((indexPath as NSIndexPath).section < countOfExtraSections) {

                let iso: String = phoneIdModel.isoCountryCodeSim != nil ? phoneIdModel.isoCountryCodeSim! : phoneIdModel.isoCountryCode!
                let cc: String = phoneIdModel.phoneCountryCodeSim != nil ? phoneIdModel.phoneCountryCodeSim! : phoneIdModel.phoneCountryCode!

                let countryName = (locale as NSLocale).displayName(forKey: NSLocale.Key.countryCode, value: iso)!

                result = CountryInfo(name: countryName, prefix: cc, code: iso)
            } else {
                result = sections[(indexPath as NSIndexPath).section - countOfExtraSections + 1].countries[(indexPath as NSIndexPath).row];
            }
            return result
        }
    }

    func applySelection(_ country: CountryInfo) {

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

    open func updateSearchResults(for searchController: UISearchController) {
        let searchString = searchController.searchBar.text
        self.filterContentForSearchText(searchString!);
        self.tableView.reloadData()
    }

    func filterContentForSearchText(_ searchText: String) {

        var result: CountryCodePickerModel = []
        if (!searchText.isEmpty) {
            for section in sections {

                let filteredCountries: [CountryInfo] = section.countries.filter({
                    (country: CountryInfo) -> Bool in                    

                    let rangeInName = country.name.range(of: searchText, options: [.caseInsensitive, .diacriticInsensitive])

                    let rangeInPrefix = country.prefix.range(of: searchText, options: [.caseInsensitive, .diacriticInsensitive])

                    return (rangeInPrefix != nil || rangeInName != nil)
                })

                if (filteredCountries.count > 0) {
                    result.append((letter: section.letter, countries: filteredCountries))
                }
            }
        } else {
            result = self.sections
        }
        self.searchResults = result;
    }

    func prefferedLocale() -> Locale {
        let langs: AnyObject = Locale.preferredLanguages as AnyObject
        let identifier: String = (langs.firstItem as? String) ?? "en_US"
        let locale = Locale(identifier: identifier)
        return locale
    }

    func populateCountryList() {

        var result: CountryCodePickerModel = []

        result.append((letter: "\u{0001F50D}", countries: []))

        let countries = loadCountriesList()

        let selector: Selector = #selector(CountryInfo.localizedTitle)
        let sortedCountries: [AnyObject] = collation.sortedArray(from: countries, collationStringSelector: selector) as [AnyObject]
        for c in sortedCountries {

            let sectionNumber = collation.section(for: c, collationStringSelector: selector)
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
        let countryCodeArray: Array<String> = Locale.isoRegionCodes as Array<String>;
        var countryArray: Array<CountryInfo> = [];
        let locale = prefferedLocale()
        for countryCode in countryCodeArray {
            let countryName: String = (locale as NSLocale).displayName(forKey: NSLocale.Key.countryCode, value: countryCode)!;
            var countryInfo: CountryInfo!
            let phoneUtil = NBPhoneNumberUtil.sharedInstance()
            if let resolvedCountryCode = phoneUtil?.getCountryCode(forRegion: countryCode) {
                if (resolvedCountryCode != 0) {
                    countryInfo = CountryInfo(name: countryName, prefix: "+\(resolvedCountryCode)", code: countryCode)
                    countryArray.append(countryInfo)
                }
            }
        }
        return countryArray

    }

    override func closeButtonTapped() {
        if (self.countrySearchController.isActive) {
            countrySearchController.presentingViewController?.dismiss(animated: true, completion: nil)
        }
        if let delegate = delegate {
            delegate.close()
        }
    }

    @objc func keyboardWillShow(_ notification: Notification) {
        if let userInfo = (notification as NSNotification).userInfo {

            if let value = userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue {
                let keyboardSize = value.cgRectValue.size
                self.tableView.contentInset = UIEdgeInsetsMake(0.0, 0.0, keyboardSize.height, 0.0);
            }
        }
    }

    @objc func keyboardWillHide(_ notification: Notification) {
        self.tableView.contentInset = UIEdgeInsets.zero;
    }

}
