//
//  ConfigurationTests.swift
//  PhoneIdTestapp
//
//  Created by Alyona on 6/19/15.
//  Copyright © 2015 Alberto Sarullo. All rights reserved.
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
