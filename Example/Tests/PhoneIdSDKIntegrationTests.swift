//
//  PhoneIdSDKIntegrationTests.swift
//  PhoneIdSDK
//
//  Created by Alyona on 7/5/15.
//  Copyright © 2015 phoneId. All rights reserved.
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
        
        var expectation = expectationWithDescription("Confirm verification code")
        phoneId.verifyAuthentication(TestConstants.VerificationCode, info: info, completion: { (token, error) -> Void in
            
            if(error == nil){
                expectation.fulfill()
            }
        })
        waitForExpectationsWithTimeout(TestConstants.defaultStepTimeout, handler: nil)
        
        expectation = expectationWithDescription("Request user info")
        phoneId.loadUserInfo() { (userInfo, e1) -> Void in
            
            if let userInfo = userInfo{
                if(e1 == nil && userInfo.isValid()){
                    expectation.fulfill()
                }
            }
        }
        waitForExpectationsWithTimeout(TestConstants.defaultStepTimeout, handler: nil)
        
        
    }
  
    
    func testAuthenticationWorkflow_VerificationFail() {
        
        let phoneId:PhoneIdService = PhoneIdService();
        phoneId.clientId = TestConstants.ClientId
        
        let info: NumberInfo = NumberInfo()
        info.phoneCountryCode = TestConstants.PhoneCountryCode
        info.isoCountryCode = TestConstants.IsoCountryCode
        info.phoneNumber = TestConstants.PhoneNumber
        
        
        self.loadClientsAndRequestAuthentication(phoneId, info: info)
        
        
        let expectation = expectationWithDescription("Confirm verification code should fail")
        phoneId.verifyAuthentication("101022", info: info, completion: { (token, error) -> Void in
            
            if(error != nil){
                expectation.fulfill()
            }
        })
        waitForExpectationsWithTimeout(TestConstants.defaultStepTimeout, handler: nil)
    }
    
    
    
    func loadClientsAndRequestAuthentication(phoneId:PhoneIdService, info:NumberInfo){
        var expectation = expectationWithDescription("Load list of application name")
        phoneId.loadClients(phoneId.clientId! ) { (e) -> Void in
            if(e == nil){
                expectation.fulfill()
            }
        }
        waitForExpectationsWithTimeout(TestConstants.defaultStepTimeout, handler: nil)
        
        
        expectation = expectationWithDescription("Request verification code")
        phoneId.requestAuthenticationCode(info) { (e) -> Void in
            if(e == nil){
                expectation.fulfill()
            }
        }
        waitForExpectationsWithTimeout(TestConstants.defaultStepTimeout, handler: nil)
    }
    
}


