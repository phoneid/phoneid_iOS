//
//  File.swift
//  phoneid_iOS
//
//  Created by Alyona on 7/14/15.
//  Copyright © 2015 CocoaPods. All rights reserved.
//

import Foundation

import XCTest

@testable import phoneid_iOS

class PhoneIdRefreshMonitorTests: XCTestCase {

    let tokenJSON = ["token_type":"bearer",
        "access_token": "ea99fa1f6a7c7713dbcc7d94edfdbc48b15c47a0",
        "expires_in": 10,
        "refresh_token":"5023784657d3549ad4887c3d313d42bab83106b6"]

    var phoneId:PhoneIdService!;
    
    override func setUp() {
         KeychainStorage.clear()
         phoneId = self.preparePhoneIdServiceInstance()
    }
    
    override func tearDown() {
        phoneId.logout()
    }
    
    func preparePhoneIdServiceInstance() -> PhoneIdService{
    
        let phoneId = PhoneIdService()
        phoneId.configureClient(TestConstants.ClientId, autorefresh: true)

        phoneId.urlSession = MockUtil.sessionForMockResponseWithParams(Endpoints.RequestToken.endpoint(), params:tokenJSON, statusCode:200)
        
        let expectation = expectationWithDescription("expect success code verification")
        phoneId.verifyAuthentication(TestConstants.VerificationCode, info: TestConstants.numberInfo) { (token, error) -> Void in
            if(token != nil && token!.isValid()){
                expectation.fulfill()
            }
        }
        waitForExpectationsWithTimeout(TestConstants.defaultStepTimeout, handler: nil)
        return phoneId
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
       
        self.preparePhoneIdServiceInstance()
        
        for(var i=0; i<5; i++){
            self.expectationForNotification(Notifications.TokenRefreshed, object: nil, handler: nil)
            
            waitForExpectationsWithTimeout(8, handler: nil)
        }

    }
    
    func testNotRefreshAfterLogout() {
        
        self.preparePhoneIdServiceInstance()
        
        let expectation = expectationWithDescription("expect successfulll token refresh")
        phoneId.phoneIdAuthenticationRefreshed = { (token) -> Void  in
            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(TestConstants.defaultStepTimeout, handler: nil)
        
        phoneId.logout()
        
        var refreshed = false
        phoneId.phoneIdAuthenticationRefreshed = { (token) -> Void  in
            refreshed = true
        }
        
        let expectation1 = expectationWithDescription("expect token not refreshing")
        delay(15) {expectation1.fulfill()}

        waitForExpectationsWithTimeout(20, handler:nil)
        
        XCTAssertFalse(refreshed)
        
    }
    
    func testRefreshExpiredTokenAfterEnterForeground() {
        
        self.preparePhoneIdServiceInstance()
        let notificationCenter =  phoneId.refreshMonitor.notificationCenter
        
        notificationCenter.postNotificationName(UIApplicationDidEnterBackgroundNotification, object: nil)
        
        XCTAssertFalse(phoneId.token!.expired)
        
        let expectation = expectationWithDescription("wait for token expire")
        delay(12) {expectation.fulfill()}
        waitForExpectationsWithTimeout(13, handler:nil)
        
        XCTAssertTrue(phoneId.token!.expired)
        
        let expectation1 = expectationWithDescription("expect successfulll token refresh")
        phoneId.phoneIdAuthenticationRefreshed = { (token) -> Void  in
            expectation1.fulfill()
        }

        notificationCenter.postNotificationName(UIApplicationWillEnterForegroundNotification, object: nil)
        
        waitForExpectationsWithTimeout(20, handler:nil)
        
    }
    
    
}