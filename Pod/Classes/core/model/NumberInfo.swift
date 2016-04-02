//
//  NumberInfo.swift
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

import CoreTelephony.CTTelephonyNetworkInfo
import CoreTelephony.CTCarrier

import libPhoneNumber_iOS

class PhoneIdNumberValidationError:PhoneIdServiceError{
    class func validationFail(descriptionKey:String?) -> PhoneIdServiceError{
        return PhoneIdNumberValidationError(code: 1004, descriptionKey:descriptionKey!, reasonKey: nil)
    }
}

public class NumberInfo: NSObject {
    
    public var phoneNumber:String?
    public var phoneCountryCode:String?
    public var isoCountryCode:String?
    
    public let defaultCountryCode:String = "+1"
    public let defaultIsoCountryCode:String = "US"
    
    public private(set) var phoneCountryCodeSim:String?
    public private(set) var isoCountryCodeSim:String?
    
    public override init() {
        super.init()
        self.prep()
    }
    
    public convenience init(number:String, countryCode:String, isoCountryCode:String) {
        self.init()
        self.phoneNumber = number
        self.phoneCountryCode = countryCode
        self.isoCountryCode = isoCountryCode
    }
    
    public convenience init(numberE164:String?) {
        self.init()
        if let number:NBPhoneNumber = try? self.phoneUtil.parseWithPhoneCarrierRegion(numberE164){
            self.phoneNumber = number.nationalNumber.stringValue
            self.phoneCountryCode = "+\(number.countryCode.stringValue)"
            self.isoCountryCode = self.phoneUtil.getRegionCodeForNumber(number)
        }
    }
    
    public func validate() throws -> Bool {
        
        guard self.phoneNumber != nil else{
            throw PhoneIdNumberValidationError.validationFail("error.number.is.not.set")
        }
        
        guard self.phoneCountryCode != nil else{
            throw PhoneIdNumberValidationError.validationFail("error.country.code.is.not.set")
        }

        guard self.isoCountryCode != nil else{
            throw PhoneIdNumberValidationError.validationFail("error.iso.country.code.is.not.set")
        }
        
        let numberString:String = self.phoneCountryCode! + self.phoneNumber!
        var result:Bool = false
        do{
        
            var error: NSError?
            let number:NBPhoneNumber! = try phoneUtil.parse(numberString, defaultRegion: self.isoCountryCode)
            let validationResult:NBEValidationResult = phoneUtil.isPossibleNumberWithReason(number, error:&error)
            
            if(validationResult != NBEValidationResult.IS_POSSIBLE){
                
                if let error = error{
                    throw PhoneIdNumberValidationError.validationFail(error.localizedDescription)
                }else{
                    throw PhoneIdNumberValidationError.validationFail("error.unkonwn.problem.phone.number.validation")
                }

            }
            result = phoneUtil.isValidNumber(number)
            
        }catch let error as PhoneIdNumberValidationError{
            throw error
        }catch let error as NSError{
            throw PhoneIdNumberValidationError.validationFail(error.localizedDescription)
        }
        
        return result;
    }
    
    public func isValid() -> (result: Bool, error: NSError?) {
        
        var result = false
        var error:NSError? = nil;
        
        do{
            result = try self.validate()
        }catch let e as NSError{
            error = e
        }        
        return (result, error);
    }
    
    private var phoneUtil: NBPhoneNumberUtil {return NBPhoneNumberUtil.sharedInstance()}
    
    private func prep(){
        let netInfo:CTTelephonyNetworkInfo = CTTelephonyNetworkInfo()
        let carrier:CTCarrier! = netInfo.subscriberCellularProvider
        
        // device with sim reader
        if ((carrier) != nil) {

            if (carrier.mobileCountryCode == nil) {
                // device with sim reader but without sim
                
            } else {

                self.isoCountryCode = carrier.isoCountryCode!.uppercaseString // IT
                self.isoCountryCodeSim = self.isoCountryCode
                
                if let countryCode = phoneUtil.getCountryCodeForRegion(isoCountryCode){
                    self.phoneCountryCode = "+\(countryCode)"
                }
                
                self.phoneCountryCodeSim = self.phoneCountryCode
            }
        }
    }
    
    
    func isValidNumber(number: String) -> Bool {
        
        do {
            let myNumber: NBPhoneNumber! = try phoneUtil.parse(number, defaultRegion: self.isoCountryCode)
            if (phoneUtil.isValidNumber(myNumber)) {
                return true
            }
        }catch{
            
        }
        
        return false;
    }
    
    public func e164Format() -> String? {
        let number = self.phoneCountryCode! + self.phoneNumber!
        let result: NSString? =  NumberInfo.e164Format(number, iso: self.isoCountryCode!);
        return result as? String
    }
    
    class func e164Format(number:String, iso:String) -> String? {
        var result: NSString? = nil;
        
        if let formatted = try? NBPhoneNumberUtil.sharedInstance().parse(number, defaultRegion: iso){
            result = try? NBPhoneNumberUtil.sharedInstance().format(formatted, numberFormat: NBEPhoneNumberFormat.E164)
        }
    
        return result as? String
    }
    
    func formatNumber(number: String) -> NSString {
        
        do {
            let myNumber: NBPhoneNumber! = try phoneUtil.parse(number, defaultRegion: self.isoCountryCode);
            let countryCodeWithSpace: String = self.phoneCountryCode! + " "
            let tempNumber = try phoneUtil.format(myNumber, numberFormat: NBEPhoneNumberFormat.INTERNATIONAL)
            return tempNumber.stringByReplacingOccurrencesOfString(countryCodeWithSpace, withString: "")
        }catch{
            return number
        }
    }
    
    func internationalFormatted()->String?{
        var number = self.phoneNumber
        if let parsed = try? NBPhoneNumberUtil.sharedInstance().parse(number, defaultRegion: self.isoCountryCode){
            if let formatted = try? NBPhoneNumberUtil.sharedInstance().format(parsed, numberFormat: NBEPhoneNumberFormat.INTERNATIONAL){
                number = formatted
            }
        }
        return number
    }
    
    override public var description: String {
        
        return "NumberInfo: {phoneCountryCode:\(phoneCountryCode),\n phoneNumber: \(phoneNumber),\nphoneCountryCodeSim: \(phoneCountryCodeSim), isoCountryCode: \(isoCountryCode), \nisoCountryCodeSim: \(isoCountryCodeSim)  }"
    }
    
    
    internal class func loadFromKeyChain()->NumberInfo?{
        
        let numberInfo = NumberInfo()
        
        numberInfo.phoneNumber = KeychainStorage.loadValue(NumberKey.number)
        numberInfo.phoneCountryCode = KeychainStorage.loadValue(NumberKey.countryCode)
        numberInfo.isoCountryCode = KeychainStorage.loadValue(NumberKey.iso)
        
        return numberInfo
    }
    
    internal func saveToKeychain(){
        if(self.isValid().result){
            KeychainStorage.saveValue(NumberKey.number, value:self.phoneNumber!)
            KeychainStorage.saveValue(NumberKey.countryCode, value:self.phoneCountryCode!)
            KeychainStorage.saveValue(NumberKey.iso, value:self.isoCountryCode!)
        }else{
            fatalError("Trying to save inconsistent token")
        }
    }

    internal func removeFromKeychain(){
        KeychainStorage.deleteValue(NumberKey.number);
        KeychainStorage.deleteValue(NumberKey.countryCode);
        KeychainStorage.deleteValue(NumberKey.iso);
    }
}
