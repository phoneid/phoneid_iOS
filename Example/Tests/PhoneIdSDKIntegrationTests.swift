//
//  PhoneIdSDKIntegrationTests.swift
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



class PhoneIdSDKIntegrationTests: XCTestCase {
    
    override func tearDown() {
        KeychainStorage.clear();
        super.tearDown()
    }

    func testAuthenticationWorkflow_Success() {
        
        let phoneId:PhoneIdService = PhoneIdService();
        phoneId.clientId = TestConstants.ClientId
        
        let info: NumberInfo = NumberInfo()
        info.phoneCountryCode = TestConstants.PhoneCountryCode
        info.isoCountryCode = TestConstants.IsoCountryCode
        info.phoneNumber = TestConstants.PhoneNumber
        
        self.loadClientsAndRequestAuthentication(phoneId, info: info)
        
        var expectation = self.expectation(description: "Confirm verification code")
        phoneId.verifyAuthentication(TestConstants.VerificationCode, info: info, completion: { (token, error) -> Void in
            
            if(error == nil){
                expectation.fulfill()
            }
        })
        waitForExpectations(timeout: TestConstants.defaultStepTimeout, handler: nil)
        
        // request user info
        expectation = self.expectation(description: "Request user info")
        phoneId.loadMyProfile() { (userInfo, e1) -> Void in
            
            if let userInfo = userInfo{
                if(e1 == nil && userInfo.isValid()){
                    expectation.fulfill()
                }
            }
        }
        waitForExpectations(timeout: TestConstants.defaultStepTimeout, handler: nil)
        
        // upload contacts list
        expectation = self.expectation(description: "Upload contacts list")
        phoneId.uploadContacts() { (numberOfUpdatedContacts ,error) -> Void in
            
            if(error == nil){
                expectation.fulfill()
            }
            
        }
        waitForExpectations(timeout: 30, handler: nil)
        
    }
  
    
    func testAuthenticationWorkflow_VerificationFail() {
        
        let phoneId:PhoneIdService = PhoneIdService();
        phoneId.clientId = TestConstants.ClientId
        
        let info: NumberInfo = NumberInfo()
        info.phoneCountryCode = TestConstants.PhoneCountryCode
        info.isoCountryCode = TestConstants.IsoCountryCode
        info.phoneNumber = TestConstants.PhoneNumber
        
        
        self.loadClientsAndRequestAuthentication(phoneId, info: info)
        
        
        let expectation = self.expectation(description: "Confirm verification code should fail")
        phoneId.verifyAuthentication("101022", info: info, completion: { (token, error) -> Void in
            
            if(error != nil){
                expectation.fulfill()
            }
        })
        waitForExpectations(timeout: TestConstants.defaultStepTimeout, handler: nil)
    }
    
    
    
    func loadClientsAndRequestAuthentication(_ phoneId:PhoneIdService, info:NumberInfo){
        var expectation = self.expectation(description: "Load application name")
        phoneId.loadClients(phoneId.clientId! ) { (e) -> Void in
            if(e == nil){
                expectation.fulfill()
            }
        }
        waitForExpectations(timeout: TestConstants.defaultStepTimeout, handler: nil)
        
        
        expectation = self.expectation(description: "Request verification code")
        phoneId.requestAuthenticationCode(info) { (e) -> Void in
            if(e == nil){
                expectation.fulfill()
            }
        }
        waitForExpectations(timeout: TestConstants.defaultStepTimeout, handler: nil)
    }
    
}


