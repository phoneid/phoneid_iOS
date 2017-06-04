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
import Contacts

class ContactsLoader: NSObject {


    func getContacts(_ defaultISOCountryCode: String, completion: @escaping ([ContactInfo]?) -> Void) {

        let store = CNContactStore()
        
        var result: [ContactInfo]?
        
        store.requestAccess(for: .contacts) { (granted, error) in
            if granted {
            
                do {
                    
                    let keysToFetch = [CNContactGivenNameKey as CNKeyDescriptor
                        , CNContactFamilyNameKey as CNKeyDescriptor
                        , CNContactPhoneNumbersKey as CNKeyDescriptor
                        , CNContactOrganizationNameKey as CNKeyDescriptor]
                    
                    // Get all the containers
                    var allContainers: [CNContainer] = []
                    do {
                        allContainers = try store.containers(matching: nil)
                    } catch {
                        print("Error fetching containers")
                    }
                    
                    var contacts: [CNContact] = []
                    
                    // Iterate all containers and append their contacts to our results array
                    for container in allContainers {
                        let fetchPredicate = CNContact.predicateForContactsInContainer(withIdentifier: container.identifier)
                        
                        do {
                            let containerResults = try store.unifiedContacts(matching: fetchPredicate, keysToFetch: keysToFetch)
                            contacts.append(contentsOf: containerResults)
                        } catch {
                            print("Error fetching results for container")
                        }
                    }
                    
                    contacts.forEach({ (contact) in
                        
                        contact.phoneNumbers.forEach({ (numberInfo) in
                        
                            let number = NumberInfo.e164Format(numberInfo.value.stringValue, iso: defaultISOCountryCode)
                            if let number = number {
                                let info = ContactInfo()
                                info.number = number
                                info.kind = numberInfo.label
                                info.company = contact.organizationName
                                info.firstName = contact.givenName
                                info.lastName = contact.familyName
                                
                                if result == nil { result = [] }
                                result?.append(info)
                            }
                        })
                    })
                    
                }
                
            }else{
            
                let alertController = UIAlertController(title: nil, message: NSLocalizedString(
                    "phone.id.needs.access.to.your.contacts", bundle: Bundle.phoneIdBundle(), comment: "phone.id.needs.access.to.your.contacts"), preferredStyle: .alert)
                
                alertController.addAction(UIAlertAction(title: NSLocalizedString("alert.button.title.dismiss", bundle: Bundle.phoneIdBundle(), comment: "alert.button.title.dismiss"), style: .cancel, handler: nil));
                
                UIApplication.shared.keyWindow?.rootViewController?.present(alertController, animated: true, completion: nil)
                
            }
            completion(result)
        }
    }
}
