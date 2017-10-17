//
//  KeychainStorage.swift
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

import Security

// Identifiers
let serviceIdentifier = "auth"
let userAccount = "phoneid.user"
let accessGroup = "phoneid.services"

// Arguments for the keychain queries
let kSecClassValue = kSecClass as String
let kSecAttrAccountValue = kSecAttrAccount as String
let kSecValueDataValue = kSecValueData as String
let kSecClassGenericPasswordValue = kSecClassGenericPassword as String
let kSecAttrServiceValue = kSecAttrService as String
let kSecMatchLimitValue = kSecMatchLimit as String
let kSecReturnDataValue = kSecReturnData as String
let kSecMatchLimitOneValue = kSecMatchLimitOne as String


open class KeychainStorage: NSObject {
    
    open class func saveValue(_ value: String) {
        self.saveValue(serviceIdentifier, value: value)
    }

    open class func loadValue() -> String? {
        let token = self.loadValue(serviceIdentifier)
        return token
    }

    @discardableResult 
    open class func saveValue(_ key: String, value: String) -> Bool {

        let data: Data = value.data(using: String.Encoding.utf8, allowLossyConversion: false)!

        let query: NSMutableDictionary = NSMutableDictionary(objects: [kSecClassGenericPasswordValue, key, userAccount, data], forKeys: [kSecClassValue as NSCopying, kSecAttrServiceValue as NSCopying, kSecAttrAccountValue as NSCopying, kSecValueDataValue as NSCopying])

        SecItemDelete(query as CFDictionary)

        let status: OSStatus = SecItemAdd(query as CFDictionary, nil)

        return status == noErr
    }

    open class func loadValue(_ key: String) -> String? {

        let query: NSMutableDictionary = NSMutableDictionary(objects: [kSecClassGenericPasswordValue, key, userAccount, kCFBooleanTrue, kSecMatchLimitOneValue],
                forKeys: [kSecClassValue as NSCopying, kSecAttrServiceValue as NSCopying, kSecAttrAccountValue as NSCopying, kSecReturnDataValue as NSCopying, kSecMatchLimitValue as NSCopying])

        var result: AnyObject?
        let status = withUnsafeMutablePointer(to: &result) {
            SecItemCopyMatching(query, UnsafeMutablePointer($0))
        }


        var value: String?

        if status == noErr, let retrievedData: Data = result as? Data {
            value = String(data: retrievedData, encoding: String.Encoding.utf8)
        }

        return value
    }

    @discardableResult
    open class func saveIntValue(_ key: String, value: Int) -> Bool {
        return self.saveValue(key, value: "\(value)")
    }

    open class func loadIntValue(_ key: String) -> Int? {

        var result: Int?

        if let value = self.loadValue(key) {
            result = Int(value)
        }

        return result

    }

    @discardableResult
    open class func saveTimeIntervalValue(_ key: String, value: TimeInterval) -> Bool {
        return self.saveValue(key, value: "\(value)")
    }

    open class func loadTimeIntervalValue(_ key: String) -> TimeInterval? {

        var result: TimeInterval?

        if let value = self.loadValue(key) {
            result = TimeInterval(value)
        }

        return result

    }

    @discardableResult 
    open class func deleteValue(_ key: String) -> Bool {
        let query = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrServiceValue as String: key] as [String : Any]


        let status: OSStatus = SecItemDelete(query as CFDictionary)

        return status == noErr
    }

    @discardableResult 
    open class func clear() -> Bool {
        let query = [kSecClass as String: kSecClassGenericPassword]

        let status: OSStatus = SecItemDelete(query as CFDictionary)

        return status == noErr
    }


}
