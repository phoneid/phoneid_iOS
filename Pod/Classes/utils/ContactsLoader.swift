//
//  ContactsLoader.swift
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
import AddressBook

// Going to switch to Contacts framework as soon we drop support of iOS8

class ContactsLoader: NSObject {

    var book: ABAddressBook!

    @discardableResult 
    func createAddressBook() -> Bool {

        if self.book != nil {
            return true
        }

        var err: Unmanaged<CFError>? = nil
        let adbk: ABAddressBook? = ABAddressBookCreateWithOptions(nil, &err).takeRetainedValue()

        if adbk == nil {
            print(err)
            self.book = nil
            return false
        }

        self.book = adbk

        return true
    }

    func determineStatus(_ completion: @escaping (Bool) -> Void) {
        let status = ABAddressBookGetAuthorizationStatus()
        switch status {
        case .authorized:
            self.createAddressBook()
            completion(true)

        case .notDetermined:
                                    
            ABAddressBookRequestAccessWithCompletion(nil) {
                (granted: Bool, err: CFError!) in
                DispatchQueue.main.async {
                    if granted {
                        self.createAddressBook()
                    } else {
                        self.book = nil
                    }
                    completion(granted)
                }
            }
        case .restricted, .denied:
            self.book = nil
            completion(false)
        }
    }

    func getContacts(_ defaultISOCountryCode: String, completion: @escaping ([ContactInfo]?) -> Void) {

        determineStatus {
            [unowned self] (authenticated) -> Void in

            var result: [ContactInfo]?

            if (authenticated) {

                let people = ABAddressBookCopyArrayOfAllPeople(self.book).takeRetainedValue() as NSArray as [ABRecord]
                for person: ABRecord in people {

                    var contactInfo: ContactInfo!

                    let phonesRef: ABMultiValue = ABRecordCopyValue(person, kABPersonPhoneProperty).takeRetainedValue() as ABMultiValue

                    for i: Int in 0 ..< ABMultiValueGetCount(phonesRef) {

                        if let value = ABMultiValueCopyValueAtIndex(phonesRef, i).takeRetainedValue() as? String {

                            if let number = NumberInfo.e164Format(value, iso: defaultISOCountryCode) {

                                contactInfo = ContactInfo()

                                contactInfo.number = number
                                
                                
                                let locLabel : CFString = (ABMultiValueCopyLabelAtIndex(phonesRef, i) != nil) ? ABMultiValueCopyLabelAtIndex(phonesRef, i).takeUnretainedValue() as CFString : ""
                                
                                let cfStr:CFTypeRef = locLabel
                                let nsTypeString = cfStr as! NSString
                                let customLabel:String = nsTypeString as String

                                contactInfo.kind = customLabel
                                    .replacingOccurrences(of: "_$!<", with: "")
                                    .replacingOccurrences(of: ">!$_", with: "")

                                if let firstName = ABRecordCopyValue(person, kABPersonFirstNameProperty)?.takeRetainedValue() as? String {
                                    contactInfo.firstName = firstName
                                }

                                if let lastName = ABRecordCopyValue(person, kABPersonLastNameProperty)?.takeRetainedValue() as? String {
                                    contactInfo.lastName = lastName
                                }

                                if let lastName = ABRecordCopyValue(person, kABPersonOrganizationProperty)?.takeRetainedValue() as? String {
                                    contactInfo.company = lastName
                                }
                            }
                        }
                        if (contactInfo != nil) {
                            if result == nil {
                                result = []
                            }
                            result?.append(contactInfo)
                        }
                    }


                }

            } else {

                let alertController = UIAlertController(title: nil, message: NSLocalizedString(
                "phone.id.needs.access.to.your.contacts", bundle: Bundle.phoneIdBundle(), comment: "phone.id.needs.access.to.your.contacts"), preferredStyle: .alert)

                alertController.addAction(UIAlertAction(title: NSLocalizedString("alert.button.title.dismiss", bundle: Bundle.phoneIdBundle(), comment: "alert.button.title.dismiss"), style: .cancel, handler: nil));

                UIApplication.shared.keyWindow?.rootViewController?.present(alertController, animated: true, completion: nil)


            }
            completion(result)
        }
    }


}
