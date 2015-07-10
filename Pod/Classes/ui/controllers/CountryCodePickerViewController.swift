//
//  CountryCodePickerViewController.swift
//  PhoneIdSDK
//
//  Created by Alyona on 7/2/15.
//  Copyright © 2015 phoneId. All rights reserved.
//

import Foundation

public typealias CountryCodePickerCompletionBlock = ((model:NumberInfo)->Void)

public class CountryCodePickerViewController: UIViewController, PhoneIdConsumer, CountryCodePickerViewDelegate {

    public var phoneIdModel:NumberInfo!
    public var countryCodePickerCompletionBlock:CountryCodePickerCompletionBlock?
    
    private var countryCodePickerView:CountryCodePickerView!
        {
        get {
            let result = self.view as? CountryCodePickerView
            if(result == nil){
                fatalError("self.view expected to be kind of CountryCodePickerView")
            }
            return result
        }
    }
    
    public init(model: NumberInfo){
        super.init(nibName: nil, bundle: nil)
        self.phoneIdModel = model
    }
    
    required public init(coder aDecoder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    public override func loadView() {
        let result = phoneIdComponentFactory.countryCodePickerView(self.phoneIdModel)
        result.delegate = self
        self.view = result
    }
    
    public override func viewDidAppear(animated: Bool) {
        
        let countrySearchController = self.countryCodePickerView.countrySearchController
        presentViewController(countrySearchController, animated: true, completion:{
            countrySearchController.searchBar.becomeFirstResponder()
        })
        super.viewDidAppear(animated)
    }
    
    // MARK: CountryCodePickerViewDelegate
    
    func goBack() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func countryCodeSelected(model: NumberInfo) {
        self.phoneIdModel = model
        if let completion = countryCodePickerCompletionBlock{
            completion(model: model)
        }
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}