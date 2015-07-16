//
//  CountryCodePickerView.swift
//  PhoneIdSDK
//
//  Created by Alyona on 7/2/15.
//  Copyright © 2015 phoneId. All rights reserved.
//

import Foundation
import libPhoneNumber_iOS

protocol CountryCodePickerViewDelegate:NSObjectProtocol{
    func countryCodeSelected(model:NumberInfo)
    func goBack()
}

class CountryInfo: NSObject{
    var name:String!
    var prefix:String!
    var code:String!
    
    var firstLetter:String {
        get { return (name as NSString).substringToIndex(1) }
    }
    
    init(name:String, prefix:String, code:String){
        super.init()
        self.name = name
        self.prefix = prefix
        self.code = code
    }
}

typealias CountryCodePickerModel = [ (letter: String, countries: [CountryInfo]) ]

public class CountryCodePickerView: PhoneIdBaseView, UITableViewDataSource, UITableViewDelegate, UISearchControllerDelegate, UISearchResultsUpdating{
    
    private(set) var tableView:UITableView!
    private(set) var titleLabel:UILabel!
    private(set) var backButton:UIButton!
    
    internal weak var delegate:CountryCodePickerViewDelegate?
    private var countrySearchController:UISearchController!
    
    private var sections:CountryCodePickerModel = []
    private var searchResults:CountryCodePickerModel = []
    
    override init(model:NumberInfo, scheme:ColorScheme, bundle:NSBundle, tableName:String){
        super.init(model: model, scheme:scheme, bundle:bundle, tableName:tableName)
        populateCountryList()
        doOnInit()
    }
    
    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setupSubviews(){
        super.setupSubviews()
                
        super.closeButton.hidden = true
        
        tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.registerClass(CountryCodeCell.self , forCellReuseIdentifier: "CountryCodeCell")
        
        titleLabel = UILabel()
        titleLabel.font = UIFont.systemFontOfSize(18)
        titleLabel.textAlignment = .Center
        
        backButton = UIButton()
        backButton.setImage(UIImage(namedInPhoneId: "icon-back"), forState: .Normal)
        backButton.addTarget(self, action: "backTapped:", forControlEvents: .TouchUpInside)
        
        let subviews:[UIView] = [tableView, titleLabel, backButton]
        
        for(_, element) in subviews.enumerate(){
            element.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview(element)
        }
        

        
    }
    
    func searchController() -> UISearchController{
        if(countrySearchController == nil){
            countrySearchController = UISearchController(searchResultsController: nil)
            countrySearchController.searchResultsUpdater = self
            countrySearchController.delegate = self
            countrySearchController.dimsBackgroundDuringPresentation = false
            countrySearchController.hidesNavigationBarDuringPresentation = false
            tableView.tableHeaderView = countrySearchController.searchBar
        }
        return countrySearchController
    }
    
    override func setupLayout(){
        
        super.setupLayout()
        
        var c:[NSLayoutConstraint] = []
        
        c.append(NSLayoutConstraint(item: tableView, attribute: .Left, relatedBy: .Equal, toItem: self, attribute: .Left, multiplier: 1, constant: 0))
        c.append(NSLayoutConstraint(item: tableView, attribute: .Right, relatedBy: .Equal, toItem: self, attribute: .Right, multiplier: 1, constant: 0))
        c.append(NSLayoutConstraint(item: tableView, attribute: .Top, relatedBy: .Equal, toItem: titleLabel, attribute: .Bottom, multiplier: 1, constant: 0))
        c.append(NSLayoutConstraint(item: tableView, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1, constant: 0))
        
        c.append(NSLayoutConstraint(item: titleLabel, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1, constant:20))
        c.append(NSLayoutConstraint(item: titleLabel, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1, constant:0))
        c.append(NSLayoutConstraint(item: titleLabel, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .Height, multiplier: 1, constant:44))
        c.append(NSLayoutConstraint(item: titleLabel, attribute: .Width, relatedBy: .Equal, toItem: self, attribute: .Width, multiplier: 0.8, constant:0))
        
        c.append(NSLayoutConstraint(item: backButton, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1, constant:20))
        c.append(NSLayoutConstraint(item: backButton, attribute: .Left, relatedBy: .Equal, toItem: self, attribute: .Left, multiplier: 1, constant:5))
        c.append(NSLayoutConstraint(item: backButton, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .Height, multiplier: 1, constant:44))
        
        self.customConstraints += c
        
        self.addConstraints(c)
    }
    
    override func localizeAndApplyColorScheme(){
        titleLabel.text = localizedString("title.country.code")
        titleLabel.textColor = colorScheme.normalText
    }
    
    func backTapped(sender:UIButton){
        if(self.countrySearchController.active){
            countrySearchController.presentingViewController?.dismissViewControllerAnimated(true,completion: nil)
        }
        if let delegate = delegate{
            delegate.goBack()
        }
    }
    
    // MARK: tableView
    
    public func numberOfSectionsInTableView(tableView:UITableView) -> Int {
        if (self.isSearchMode()) {
            return searchResults.count
        } else {
            return sections.count
        }
    }
    
    public func tableView(tableView:UITableView, cellForRowAtIndexPath indexPath:NSIndexPath) -> UITableViewCell
    {
        let cell:CountryCodeCell = tableView.dequeueReusableCellWithIdentifier("CountryCodeCell", forIndexPath: indexPath) as! CountryCodeCell
        
        let model:CountryInfo = self.determineModel(atIndexPath:indexPath)
        cell.setupWithModel(model)
        return cell
    }
    
    public func tableView(tableView:UITableView, numberOfRowsInSection section:NSInteger) -> Int {
        
        if (self.isSearchMode()) {
            return searchResults[section].countries.count;
        } else {
            if (section == 0) {
                return phoneIdModel.phoneCountryCodeSim != nil ? 1 : 0
            } else {
                return sections[section].countries.count;
            }
        }
    }
    
    public func tableView(tableView:UITableView, didSelectRowAtIndexPath indexPath:NSIndexPath) {
        let country: CountryInfo = self.determineModel(atIndexPath:indexPath)
        
        if( self.countrySearchController.searchBar.isFirstResponder()){
            self.countrySearchController.searchBar.resignFirstResponder()
            self.countrySearchController.dismissViewControllerAnimated(false) { [unowned self] () -> Void in
                self.applySelection(country)
            }
        }else{
            applySelection(country)
        }
    }
    
    public func tableView(tableView:UITableView, titleForHeaderInSection section:NSInteger) -> String? {
        var string:String
        if (!self.isSearchMode()) {
            if (section == 0) {
                string = phoneIdModel.phoneCountryCode != nil ? localizedString("current.phone") : ""
            } else {
                string = sections[section].letter
            }
        } else {
            string = searchResults[section].letter;
        }
        return string
    }
    
    public func tableView(tableView:UITableView, heightForHeaderInSection section:NSInteger) -> (CGFloat) {
        if (!isSearchMode() && section == 0 && phoneIdModel.phoneCountryCodeSim==nil) {
            return 0;
        }
        return CountryCodeCell.height;
    }
    
    // MARK: - Utilities
    
    func determineModel(atIndexPath indexPath:NSIndexPath) -> CountryInfo{
        if (self.isSearchMode()) {
            return searchResults[indexPath.section].countries[indexPath.row];
        } else {
            if (indexPath.section == 0 && phoneIdModel.phoneCountryCodeSim != nil) {
                let locale = prefferedLocale()
                let countryName = locale.displayNameForKey(NSLocaleCountryCode, value:phoneIdModel.isoCountryCode!)!;
                return CountryInfo(name:countryName, prefix: phoneIdModel.phoneCountryCode!, code: phoneIdModel.isoCountryCode!)
            } else {
                return sections[indexPath.section].countries[indexPath.row];
            }
        }
    }
    
    func applySelection(country:CountryInfo){
        
        self.phoneIdModel.isoCountryCode = country.code
        self.phoneIdModel.phoneCountryCode = country.prefix
        
        if let delegate = self.delegate{
            delegate.countryCodeSelected(self.phoneIdModel)
        }
    }
    
    func isSearchMode() -> Bool{
        let searchString:String? = self.countrySearchController?.searchBar.text
        let result = searchString != nil ? !searchString!.isEmpty : false
        return result
    }
    
    // MARK: - UISearchResultsUpdating
    
    public func updateSearchResultsForSearchController(searchController: UISearchController){
        let searchString = searchController.searchBar.text
        self.filterContentForSearchText(searchString!);
        self.tableView.reloadData()
    }
    
    func filterContentForSearchText(searchText:String){
        
        var result:CountryCodePickerModel = []
        if (!searchText.isEmpty){
            for section in sections{
                
                let filteredCountries:[CountryInfo] = section.countries.filter({ (country:CountryInfo) -> Bool in
                    (country.name.lowercaseString.rangeOfString(searchText.lowercaseString) != nil ) ||
                        (country.prefix.lowercaseString.rangeOfString(searchText.lowercaseString) != nil )
                    
                    let rangeInName = country.name.rangeOfString(searchText, options: [.CaseInsensitiveSearch,.DiacriticInsensitiveSearch])
                    
                    let rangeInPrefix = country.prefix.rangeOfString(searchText, options: [.CaseInsensitiveSearch, .DiacriticInsensitiveSearch])
                    
                    return (rangeInPrefix != nil || rangeInName != nil)
                })
                
                if (filteredCountries.count > 0){
                    result.append(letter: section.letter, countries: filteredCountries)
                }
            }
        }else{
            result = self.sections
        }
        self.searchResults = result;
    }
    
    func prefferedLocale() -> NSLocale{
        let langs:AnyObject = NSLocale.preferredLanguages()
        let identifier:String = langs[0] as! String
        let locale = NSLocale(localeIdentifier: identifier)
        return locale
    }
    
    func populateCountryList() {
        
        var result:CountryCodePickerModel = []
        
        result.append((letter:"\u{0001F50D}", countries:[]))
        
        let countries = loadCountriesList()
        
        for country:CountryInfo in countries {
            
            let index = result.indexOf({(letter: String, countries: [CountryInfo]) -> Bool in letter == country.firstLetter })
            
            if let index = index {
                result[index].countries.append(country)
            } else {
                result.append((letter:country.firstLetter, countries:[country]))
            }
        }
        
        self.sections = result
    }
    
    func loadCountriesList() -> [CountryInfo]{
        let countryCodeArray:Array<String> = NSLocale.ISOCountryCodes() as Array<String>;
        var countryArray:Array<CountryInfo> = [];
        let locale = prefferedLocale()
        for countryCode in countryCodeArray {
            let countryName:String = locale.displayNameForKey(NSLocaleCountryCode, value:countryCode)!;
            
            let phoneUtil = NBPhoneNumberUtil.sharedInstance()
            if let resolvedCountryCode = phoneUtil.getCountryCodeForRegion(countryCode){
                if (resolvedCountryCode != "") {
                    let countryInfo = CountryInfo(name:countryName, prefix:"+\(resolvedCountryCode)",code:countryCode)
                    countryArray.append(countryInfo)
                }
            }else {
                print("Not present: \(countryCode) \(countryName)")
            }
        }
        
        let sortedCountryArray:Array<CountryInfo> = countryArray.sort({ (first, second) -> Bool in
            first.name.localizedCaseInsensitiveCompare(second.name) == NSComparisonResult.OrderedAscending
        })
        return sortedCountryArray
        
    }

}