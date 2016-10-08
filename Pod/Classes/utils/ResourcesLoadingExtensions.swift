//
//  ResourcesLoadingExtensions.swift
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


extension Bundle {
    class func phoneIdBundle() -> Bundle {

        return Bundle(for: PhoneIdLoginButton.self)
    }
}

extension UIImage {

    convenience init?(namedInPhoneId: String) {
        let frameworkBundle = Bundle.phoneIdBundle()

        self.init(named: namedInPhoneId, in: frameworkBundle, compatibleWith: nil)
    }

}

extension UIStoryboard {

    convenience init?(namedInPhoneId: String) {
        let frameworkBundle = Bundle.phoneIdBundle()
        self.init(name: namedInPhoneId, bundle: frameworkBundle)

    }

}

