//
//  ConfigurationTests.swift
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



import XCTest
@testable import phoneid_iOS

class NumberInfoTests: XCTestCase {
    
    func testValidation_NumberIsNotSet() {
        let info = NumberInfo()

        do{ try info.validate();}
        catch  _ as PhoneIdNumberValidationError{ return }
        catch _{}
        
        XCTAssertTrue(false, "validation of \(info) should throw PhoneIdNumberValidationError");
    }
    
    func testValidation_CountryCodeIsNot() {
        let info = NumberInfo()
        info.phoneCountryCode = nil
        info.phoneNumber = "677757473"
        
        do{ try info.validate();}
        catch  _ as PhoneIdNumberValidationError{ return }
        catch _{}
        
        XCTAssertTrue(false, "validation of \(info) should throw PhoneIdNumberValidationError");
    }
    
    func testValidation_InvalidData() {
        let info = NumberInfo()
        info.phoneNumber = "6777sdwe23457473"
        info.phoneCountryCode = "33280"
        info.isoCountryCode = "ZUA"
        
        do{ try info.validate();}
        catch let error{
            print(error)
            return
        }
        XCTAssertTrue(false, "validation of \(info) should throw");
        
    }
    
    func testValidation_ValidData() {
        let info = NumberInfo(number: "677757473", countryCode: "380", isoCountryCode: "UA")
        
        do{ try info.validate();}
        catch _{
            XCTAssertTrue(false, "validation of \(info) should not throw");
        }
    
    }
    
}
