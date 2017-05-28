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
    class func validationFail(_ descriptionKey:String?) -> PhoneIdServiceError{
        return PhoneIdNumberValidationError(code: 1004, descriptionKey:descriptionKey!, reasonKey: nil)
    }
}

open class NumberInfo: NSObject {
    
    open var phoneNumber:String?
    open var phoneCountryCode:String?
    open var isoCountryCode:String?
    
    open let defaultCountryCode:String = "+1"
    open let defaultIsoCountryCode:String = "US"
    
    open fileprivate(set) var phoneCountryCodeSim:String?
    open fileprivate(set) var isoCountryCodeSim:String?
    
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
        if let number:NBPhoneNumber = try? self.phoneUtil.parse(withPhoneCarrierRegion: numberE164){
            self.phoneNumber = number.nationalNumber.stringValue
            self.phoneCountryCode = "+\(number.countryCode.stringValue)"
            self.isoCountryCode = self.phoneUtil.getRegionCode(for: number)
        }
    }
    
    open func validate() throws -> Bool {
        
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
            let validationResult:NBEValidationResult = phoneUtil.isPossibleNumber(withReason: number, error:&error)
            
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
    
    open func isValid() -> (result: Bool, error: NSError?) {
        
        var result = false
        var error:NSError? = nil;
        
        do{
            result = try self.validate()
        }catch let e as NSError{
            error = e
        }        
        return (result, error);
    }
    
    fileprivate var phoneUtil: NBPhoneNumberUtil {return NBPhoneNumberUtil.sharedInstance()}
    
    fileprivate func prep(){
        let netInfo:CTTelephonyNetworkInfo = CTTelephonyNetworkInfo()
        let carrier:CTCarrier! = netInfo.subscriberCellularProvider
        
        // device with sim reader
        if ((carrier) != nil) {

            if (carrier.mobileCountryCode == nil) {
                // device with sim reader but without sim
                
            } else {

                self.isoCountryCode = carrier.isoCountryCode!.uppercased() // IT
                self.isoCountryCodeSim = self.isoCountryCode
                
                if let countryCode = phoneUtil.getCountryCode(forRegion: isoCountryCode){
                    self.phoneCountryCode = "+\(countryCode)"
                }
                
                self.phoneCountryCodeSim = self.phoneCountryCode
            }
        }
    }
    
    
    func isValidNumber(_ number: String) -> Bool {
        
        do {
            let myNumber: NBPhoneNumber! = try phoneUtil.parse(number, defaultRegion: self.isoCountryCode)
            if (phoneUtil.isValidNumber(myNumber)) {
                return true
            }
        }catch{
            
        }
        
        return false;
    }
    
    open func e164Format() -> String? {
        let number = self.phoneCountryCode! + self.phoneNumber!
        let result =  NumberInfo.e164Format(number, iso: self.isoCountryCode!)
        return result
    }
    
    class func e164Format(_ number:String, iso:String) -> String? {
        var result:String? = nil;
        
        if let formatted = try? NBPhoneNumberUtil.sharedInstance().parse(number, defaultRegion: iso){
            result = try! NBPhoneNumberUtil.sharedInstance().format(formatted, numberFormat: NBEPhoneNumberFormat.E164)
        }
    
        return result
    }
    
    func formatNumber(_ number: String) -> String {
        
        do {
            let myNumber: NBPhoneNumber! = try phoneUtil.parse(number, defaultRegion: self.isoCountryCode);
            let countryCodeWithSpace: String = self.phoneCountryCode! + " "
            let tempNumber = try phoneUtil.format(myNumber, numberFormat: NBEPhoneNumberFormat.INTERNATIONAL)
            return tempNumber.replacingOccurrences(of: countryCodeWithSpace, with: "")
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
    
    override open var description: String {
        
        return "NumberInfo: {phoneCountryCode:\(phoneCountryCode ?? "nil"),\n phoneNumber: \(phoneNumber ?? "nil"),\nphoneCountryCodeSim: \(phoneCountryCodeSim ?? "nil"), isoCountryCode: \(isoCountryCode ?? "nil"), \nisoCountryCodeSim: \(isoCountryCodeSim ?? "nil")  }"
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
