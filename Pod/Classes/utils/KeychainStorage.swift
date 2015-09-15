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


public class KeychainStorage: NSObject {

    public class func saveValue(value: String) {
        self.saveValue(serviceIdentifier, value: value)
    }
    
    public class func loadValue() -> String? {
        let token = self.loadValue(serviceIdentifier)
        return token
    }
    
    public class func saveValue(key: String, value: String) -> Bool {
        
        let data: NSData = value.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!

        let query: NSMutableDictionary = NSMutableDictionary(objects: [kSecClassGenericPasswordValue, key, userAccount, data], forKeys: [kSecClassValue, kSecAttrServiceValue, kSecAttrAccountValue, kSecValueDataValue])

        SecItemDelete(query as CFDictionaryRef)
        
        let status: OSStatus = SecItemAdd(query as CFDictionaryRef, nil)
        
        return status == noErr
    }
    
    public class func loadValue(key: String) -> String? {

        let query: NSMutableDictionary = NSMutableDictionary(objects: [kSecClassGenericPasswordValue, key, userAccount, kCFBooleanTrue, kSecMatchLimitOneValue],
            forKeys: [kSecClassValue, kSecAttrServiceValue, kSecAttrAccountValue, kSecReturnDataValue, kSecMatchLimitValue])
        
        var result: AnyObject?
        let status = withUnsafeMutablePointer(&result) { SecItemCopyMatching(query, UnsafeMutablePointer($0)) }


        var value: String?
        
        if status == noErr {
            let retrievedData: NSData = result as! NSData
            value = NSString(data: retrievedData, encoding: NSUTF8StringEncoding) as? String;
        }
        
        return value
    }
    
    public class func saveIntValue(key: String, value: Int) -> Bool {
        return self.saveValue(key, value: "\(value)")
    }
    
    public class func loadIntValue(key: String) ->Int?{
        
        var result:Int?
        
        if let value = self.loadValue(key){
            result = Int(value)
        }
        
        return result
    
    }
    
    public class func saveTimeIntervalValue(key: String, value: NSTimeInterval) -> Bool {
        return self.saveValue(key, value: "\(value)")
    }
    
    public class func loadTimeIntervalValue(key: String) ->NSTimeInterval?{
        
        var result:NSTimeInterval?
        
        if let value = self.loadValue(key){
            result = NSTimeInterval(value)
        }
        
        return result
        
    }
    
    public class func deleteValue(key: String) -> Bool {
        let query = [
            kSecClass as String : kSecClassGenericPassword,
            kSecAttrServiceValue as String : key ]

        
        let status: OSStatus = SecItemDelete(query as CFDictionaryRef)
        
        return status == noErr
    }
    
    public class func clear() -> Bool {
        let query = [ kSecClass as String : kSecClassGenericPassword ]
        
        let status: OSStatus = SecItemDelete(query as CFDictionaryRef)
        
        return status == noErr
    }
    
    
}
