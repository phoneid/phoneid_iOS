//
//  PhoneIdRefreshMonitorTests.swift
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

import XCTest

@testable import phoneid_iOS

class PhoneIdRefreshMonitorTests: XCTestCase {
    
    let tokenJSON = ["token_type":"bearer",
        "access_token": "ea99fa1f6a7c7713dbcc7d94edfdbc48b15c47a0",
        "expires_in": 10,
        "refresh_token":"5023784657d3549ad4887c3d313d42bab83106b6"] as [String : Any]
    
    var phoneId:PhoneIdService! = PhoneIdService.sharedInstance;
    
    override func setUp() {
        
        let urlSession = MockUtil.sessionForMockResponseWithParams(Endpoints.requestToken.endpoint(), params:tokenJSON, statusCode:200)
        
        KeychainStorage.clear()
        phoneId.urlSession = urlSession

        
        phoneId.configureClient(TestConstants.ClientId, autorefresh: true)
        
       let expectation = self.expectation(description: "expect success code verification")
       phoneId.verifyAuthentication(TestConstants.VerificationCode, info: TestConstants.numberInfo) { (token, error) -> Void in
           if(token != nil && token!.isValid()){
               expectation.fulfill()
           }
       }
       waitForExpectations(timeout: TestConstants.defaultStepTimeout, handler: nil)
        
    }
    
    override func tearDown() {
        phoneId.logout()
        phoneId = nil
    }
    
    func testReactOnNotifications() {
        
        
        
        let notificationCenter =  phoneId.refreshMonitor.notificationCenter
        
        XCTAssertTrue(phoneId.refreshMonitor.isRunning)
        
        notificationCenter.post(name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
        
        XCTAssertFalse(phoneId.refreshMonitor.isRunning)
        
        notificationCenter.post(name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
        
        XCTAssertTrue(phoneId.refreshMonitor.isRunning)
        
    }
    
    func testRefreshByTimer() {
        
        var expectation = self.expectation(description: "expect successfulll token refresh")
        phoneId.phoneIdAuthenticationRefreshed = { (token) -> Void  in
            XCTAssertNotNil(token)
            expectation.fulfill()
        }
        waitForExpectations(timeout: 8, handler: nil)
        
        expectation = self.expectation(description: "expect successfulll token refresh")
        phoneId.phoneIdAuthenticationRefreshed = { (token) -> Void  in
            XCTAssertNotNil(token)
            expectation.fulfill()
        }
        waitForExpectations(timeout: 8, handler: nil)
        
    }
    
    func testNotRefreshAfterLogout() {
        
        let expectation = self.expectation(description: "expect successfulll token refresh")
        phoneId.phoneIdAuthenticationRefreshed = { (token) -> Void  in
            XCTAssertNotNil(token)
            expectation.fulfill()
            self.phoneId.logout()
        }
        waitForExpectations(timeout: TestConstants.defaultStepTimeout, handler: nil)
        
        
        var refreshed = false
        var errorReceived = false
        
        phoneId.phoneIdWorkflowErrorHappened = { (token) -> Void  in
            errorReceived = true
        }
        
        phoneId.phoneIdAuthenticationRefreshed = { (token) -> Void  in
            refreshed = true
        }
        
        let expectation1 = self.expectation(description: "expect token not refreshing")
        delay(15) {expectation1.fulfill()}
        
        waitForExpectations(timeout: 20, handler:nil)
        
        XCTAssertFalse(refreshed)
        XCTAssertFalse(errorReceived)
        
    }
    
    func testRefreshExpiredTokenAfterEnterForeground() {
        
        let notificationCenter = phoneId.refreshMonitor.notificationCenter
        notificationCenter.post(name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
        
        
        let token:TokenInfo = phoneId.token!
        token.timestamp =  Date().addingTimeInterval(TimeInterval(-30))
        token.saveToKeychain()
        
        XCTAssertFalse( phoneId.token == nil)
        XCTAssertTrue(phoneId.token!.expired)
        
        
        let expectation1 = expectation(description: "expect successfulll token refresh")
        phoneId.phoneIdAuthenticationRefreshed = { (token) -> Void  in
            expectation1.fulfill()
            self.phoneId.logout()
        }
        
        notificationCenter.post(name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
        
        waitForExpectations(timeout: 8, handler:nil)
        
    }
    
    
}
