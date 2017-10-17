//
//  CountryCodePickerViewController.swift
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

public typealias CountryCodePickerCompletionBlock = ((_ model:NumberInfo) -> Void)

open class CountryCodePickerViewController: UIViewController, PhoneIdConsumer, CountryCodePickerViewDelegate {

    open var phoneIdModel: NumberInfo!
    open var countryCodePickerCompletionBlock: CountryCodePickerCompletionBlock?

    fileprivate var countryCodePickerView: CountryCodePickerView! {
        get {
            let result = self.view as? CountryCodePickerView
            if (result == nil) {
                fatalError("self.view expected to be kind of CountryCodePickerView")
            }
            return result
        }
    }

    public init(model: NumberInfo) {
        super.init(nibName: nil, bundle: nil)
        self.phoneIdModel = model
    }

    required public init(coder aDecoder: NSCoder) {
        fatalError("NSCoding not supported")
    }

    open override func loadView() {
        let result = phoneIdComponentFactory.countryCodePickerView(self.phoneIdModel)
        result.delegate = self
        self.view = result
    }

    open override func viewDidAppear(_ animated: Bool) {

        super.viewDidAppear(animated)

        let countrySearchController = self.countryCodePickerView.searchController()
        present(countrySearchController, animated: true, completion: {
            countrySearchController.searchBar.becomeFirstResponder()
        })
    }

    // MARK: CountryCodePickerViewDelegate

    func close() {
        self.dismiss(animated: true, completion: nil)
    }

    func countryCodeSelected(_ model: NumberInfo) {
        self.phoneIdModel = model
        self.dismiss(animated: true) { [weak self] in
            guard let me  = self else {return}
            PhoneIdService.sharedInstance.phoneIdWorkflowCountryCodeSelected?(model.phoneCountryCode!)
            me.countryCodePickerCompletionBlock?(model)
        }
    }
}
