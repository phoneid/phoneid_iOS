//
//  phoneid_iOS_UITests.swift
//  phoneid_iOS_UITests
//
//  Copyright 2015 Federico Pomi
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
import phoneid_iOS

class phoneid_iOS_UITests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
        continueAfterFailure = false
        
        PhoneIdService.sharedInstance.logout()
        
        XCUIApplication().launch()
    }
    
    func testProminentMode_FullCycleSuccess() {
        
        let app = XCUIApplication()
        let window = app.childrenMatchingType(.Window).elementBoundByIndex(2)
        
        let phoneIdButton = app.otherElements.containingType(.Button, identifier:"Login with phone.id").childrenMatchingType(.Button).matchingIdentifier("Login with phone.id").elementBoundByIndex(0)
        phoneIdButton.tap()
        
        
        window.textFields["Phone Number"].typeText(TestConstants.PhoneNumber)
        
        window.buttons["OK"].tap()
        
        
        window.textFields["Verification Code"].typeText(TestConstants.VerificationCode)
        
        
        let logout = app.otherElements.containingType(.Button, identifier:"Log out").childrenMatchingType(.Button).matchingIdentifier("Log out").elementBoundByIndex(0)
        
        XCTAssertNotNil(logout)
        
        
        logout.tap()
        
    }
    
    
    
    func testProminentMode_WorkflowCancelled_NumberInput() {
        
        
        let app = XCUIApplication()
        
        app.otherElements.containingType(.Button, identifier:"Login with phone.id").childrenMatchingType(.Button).matchingIdentifier("Login with phone.id").elementBoundByIndex(0).tap()
        
        app.buttons["Close"].tap()
        
        app.alerts.collectionViews.buttons["Dismiss"].tap()
        
        let loginButton = app.otherElements.containingType(.Button, identifier:"Login with phone.id").childrenMatchingType(.Button).matchingIdentifier("Login with phone.id").elementBoundByIndex(0)
        
        XCTAssertNotNil(loginButton)
        
    }
    
    func testProminentMode_WorkflowCancelled_VerificationCode() {
        
        let app = XCUIApplication()
        
        app.otherElements.containingType(.Button, identifier:"Login with phone.id").childrenMatchingType(.Button).matchingIdentifier("Login with phone.id").elementBoundByIndex(0).tap()
        
        let window = app.childrenMatchingType(.Window).elementBoundByIndex(2)
        
        window.textFields["Phone Number"].typeText(TestConstants.PhoneNumber)
        
        window.buttons["OK"].tap()
        
        app.buttons["Close"].tap()
        
        XCTAssertNotNil(app.buttons["Login with phone.id"])
    }
    
    
    func testProminentMode_WrongVerifictionCode() {
        
        
        let app = XCUIApplication()
        
        app.otherElements.containingType(.Button, identifier:"Login with phone.id").childrenMatchingType(.Button).matchingIdentifier("Login with phone.id").elementBoundByIndex(0).tap()
        
        let window = app.childrenMatchingType(.Window).elementBoundByIndex(2)
        
        window.textFields["Phone Number"].typeText(TestConstants.PhoneNumber)
        
        window.buttons["OK"].tap()
        
        window.textFields["Verification Code"].typeText("1234567")
        
        XCTAssertNotNil(app.textViews["The code you typed is different\nfrom the one we've sent you.\n\nCo"])
        
    }
    
    func testProminentMode_DoneButton(){
        
        
        let app = XCUIApplication()
        
        app.otherElements.containingType(.Button, identifier:"Login with phone.id").childrenMatchingType(.Button).matchingIdentifier("Login with phone.id").elementBoundByIndex(0).tap()
        
        let window = app.childrenMatchingType(.Window).elementBoundByIndex(2)
        
        window.textFields["Phone Number"].typeText(TestConstants.PhoneNumber)
        
        NSThread.sleepForTimeInterval(0.5)
        
        XCTAssertFalse(window.toolbars.buttons["Done"].exists)
        
        window.buttons["Close"].tap()
        
    }
    
    func testProminentMode_ShowCountryCodePicker(){
        
        
        let app = XCUIApplication()
        app.otherElements.containingType(.Button, identifier:"Login with phone.id").childrenMatchingType(.Button).matchingIdentifier("Login with phone.id").elementBoundByIndex(0).tap()
        
        app.toolbars.buttons["Change Country"].tap()
        
        NSThread.sleepForTimeInterval(0.5)
        
        let window = app.childrenMatchingType(.Window).elementBoundByIndex(2)
        let searchSearchField = window.searchFields["Search"]
        
        XCTAssertTrue(searchSearchField.exists)
        
    }
    
    func testProminentMode_SearchCountryCode(){
        
        let app = XCUIApplication()
        
        app.otherElements.containingType(.Button, identifier:"Login with phone.id").childrenMatchingType(.Button).matchingIdentifier("Login with phone.id").elementBoundByIndex(0).tap()
        
        app.toolbars.buttons["Change Country"].tap()
        
        doSearchTesting(app)
        
    }
    
    func doSearchTesting(app:XCUIApplication){
        
        
        for str in ["U","n","i","t","e","d"," ","S"] {
            app.searchFields["Search"].typeText(str)
            NSThread.sleepForTimeInterval(0.1)
        }
        
        
        let window = app.childrenMatchingType(.Window).elementBoundByIndex(2)
        let searchResultsTable = window.tables.elementBoundByIndex(1)
        let texts = searchResultsTable.childrenMatchingType(.Cell).elementBoundByIndex(0).staticTexts
        
        let countryCode = texts.elementBoundByIndex(0).label
        let countryName = texts.elementBoundByIndex(1).label
        
        XCTAssertEqual(countryCode, "+1")
        XCTAssertEqual(countryName, "United States")
    
    }
    
    func testCompactMode_EasyCycleSuccess(){
        
        let app = XCUIApplication()
        app.switches["0"].tap()
        
        let element = app.otherElements.containingType(.StaticText, identifier:"Use compact mode").childrenMatchingType(.Other).elementBoundByIndex(2)
        
        element.buttons["Login with phone.id"].tap()
        
        app.textFields["Phone Number "].typeText(TestConstants.PhoneNumber)
        app.buttons["OK"].tap()
        
        NSThread.sleepForTimeInterval(2)
        app.textFields["Verification Code"].typeText(TestConstants.VerificationCode)
        
        NSThread.sleepForTimeInterval(2)
        element.buttons["Log out"].tap()
        
    }
    
    func testCompactMode_FullCycleSuccess(){
        
        
        let app = XCUIApplication()
        app.switches["0"].tap()

        let compactButton = app.otherElements.containingType(.StaticText, identifier:"Use compact mode").childrenMatchingType(.Other).elementBoundByIndex(2)
        
        compactButton.buttons["Login with phone.id"].tap()
        
        app.textFields["Phone Number "].typeText(TestConstants.PhoneNumber)
        
        
        app.buttons["OK"].tap()
        
        NSThread.sleepForTimeInterval(2)
        
        let verificationCodeTextField = app.textFields["Verification Code"]
        
        verificationCodeTextField.typeText("123456")
        
        NSThread.sleepForTimeInterval(5)
        
        let backButton = app.buttons["Back"]
        
        backButton.tap()
        
        app.buttons["OK"].tap()
        
        NSThread.sleepForTimeInterval(2)
        
        verificationCodeTextField.typeText(TestConstants.VerificationCode)
        
        NSThread.sleepForTimeInterval(2)
        
        compactButton.buttons["Log out"].tap()
        
        
    }
    
    func testCompactMode_Search(){
    
        
        let app = XCUIApplication()
        
        app.switches["0"].tap()
        
        let compactButton = app.otherElements.containingType(.StaticText, identifier:"Use compact mode").childrenMatchingType(.Other).elementBoundByIndex(2)
        
        compactButton.buttons["Login with phone.id"].tap()
        
        compactButton.buttons.matchingIdentifier("Change Country").elementBoundByIndex(0).tap()
        
        doSearchTesting(app)
        
    }
    
   
    
    
}
