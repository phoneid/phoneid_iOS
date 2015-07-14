//
//  KeychainStorage.swift
//  PhoneIdTestapp
//
//  Created by Alyona on 6/19/15.
//  Copyright © 2015 Alberto Sarullo. All rights reserved.
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
        
        var dataTypeRef :Unmanaged<AnyObject>?
        
        let status: OSStatus = SecItemCopyMatching(query, &dataTypeRef)

        var value: String?
        
        if status == noErr {
            let retrievedData: NSData = dataTypeRef!.takeRetainedValue() as! NSData
            value = NSString(data: retrievedData, encoding: NSUTF8StringEncoding) as? String;
        } else {
            print("Nothing was retrieved from the keychain. Status code \(status)")
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
