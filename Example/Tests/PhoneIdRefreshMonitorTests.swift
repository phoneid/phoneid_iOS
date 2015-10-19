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
        "refresh_token":"5023784657d3549ad4887c3d313d42bab83106b6"]
    
    var phoneId:PhoneIdService! = PhoneIdService.sharedInstance;
    
    override func setUp() {
        
        let urlSession = MockUtil.sessionForMockResponseWithParams(Endpoints.RequestToken.endpoint(), params:tokenJSON, statusCode:200)
        
        KeychainStorage.clear()
        phoneId.urlSession = urlSession

        
        phoneId.configureClient(TestConstants.ClientId, autorefresh: true)
        
       let expectation = expectationWithDescription("expect success code verification")
       phoneId.verifyAuthentication(TestConstants.VerificationCode, info: TestConstants.numberInfo) { (token, error) -> Void in
           if(token != nil && token!.isValid()){
               expectation.fulfill()
           }
       }
       waitForExpectationsWithTimeout(TestConstants.defaultStepTimeout, handler: nil)
        
    }
    
    override func tearDown() {
        phoneId.logout()
        phoneId = nil
    }
    
    func testReactOnNotifications() {
        
        
        
        let notificationCenter =  phoneId.refreshMonitor.notificationCenter
        
        XCTAssertTrue(phoneId.refreshMonitor.isRunning)
        
        notificationCenter.postNotificationName(UIApplicationDidEnterBackgroundNotification, object: nil)
        
        XCTAssertFalse(phoneId.refreshMonitor.isRunning)
        
        notificationCenter.postNotificationName(UIApplicationWillEnterForegroundNotification, object: nil)
        
        XCTAssertTrue(phoneId.refreshMonitor.isRunning)
        
    }
    
    func testRefreshByTimer() {
        
        var expectation = expectationWithDescription("expect successfulll token refresh")
        phoneId.phoneIdAuthenticationRefreshed = { (token) -> Void  in
            XCTAssertNotNil(token)
            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(8, handler: nil)
        
        expectation = expectationWithDescription("expect successfulll token refresh")
        phoneId.phoneIdAuthenticationRefreshed = { (token) -> Void  in
            XCTAssertNotNil(token)
            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(8, handler: nil)
        
    }
    
    func testNotRefreshAfterLogout() {
        
        let expectation = expectationWithDescription("expect successfulll token refresh")
        phoneId.phoneIdAuthenticationRefreshed = { (token) -> Void  in
            XCTAssertNotNil(token)
            expectation.fulfill()
            self.phoneId.logout()
        }
        waitForExpectationsWithTimeout(TestConstants.defaultStepTimeout, handler: nil)
        
        
        var refreshed = false
        var errorReceived = false
        
        phoneId.phoneIdWorkflowErrorHappened = { (token) -> Void  in
            errorReceived = true
        }
        
        phoneId.phoneIdAuthenticationRefreshed = { (token) -> Void  in
            refreshed = true
        }
        
        let expectation1 = expectationWithDescription("expect token not refreshing")
        delay(15) {expectation1.fulfill()}
        
        waitForExpectationsWithTimeout(20, handler:nil)
        
        XCTAssertFalse(refreshed)
        XCTAssertFalse(errorReceived)
        
    }
    
    func testRefreshExpiredTokenAfterEnterForeground() {
        
        let notificationCenter = phoneId.refreshMonitor.notificationCenter
        notificationCenter.postNotificationName(UIApplicationDidEnterBackgroundNotification, object: nil)
        
        
        let token:TokenInfo = phoneId.token!
        token.timestamp =  NSDate().dateByAddingTimeInterval(NSTimeInterval(-30))
        token.saveToKeychain()
        
        XCTAssertFalse( phoneId.token == nil)
        XCTAssertTrue(phoneId.token!.expired)
        
        
        let expectation1 = expectationWithDescription("expect successfulll token refresh")
        phoneId.phoneIdAuthenticationRefreshed = { (token) -> Void  in
            expectation1.fulfill()
            self.phoneId.logout()
        }
        
        notificationCenter.postNotificationName(UIApplicationWillEnterForegroundNotification, object: nil)
        
        waitForExpectationsWithTimeout(8, handler:nil)
        
    }
    
    
}