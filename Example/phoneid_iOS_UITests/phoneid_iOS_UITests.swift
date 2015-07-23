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
    
    func testFullCycleSuccess() {
  
        let app = XCUIApplication()
        app.buttons["Login with phone.id"].tap()
        app.textFields["Phone Number"].typeText(TestConstants.PhoneNumber)

        app.buttons["OK"].tap()
        app.childrenMatchingType(.Window).elementBoundByIndex(0).childrenMatchingType(.Other).elementBoundByIndex(1).childrenMatchingType(.Other).element.childrenMatchingType(.TextField).element.typeText(TestConstants.VerificationCode)
        XCTAssertNotNil(app.buttons["Log out"])
        app.buttons["Log out"].tap()
        
    }
    
    
    
    func testWorkflowCancelled_NumberInput() {
        let app = XCUIApplication()
        app.buttons["Login with phone.id"].tap()
        app.childrenMatchingType(.Window).elementBoundByIndex(0).childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Button).elementBoundByIndex(0).tap()
        
        XCTAssertNotNil(app.buttons["Login with phone.id"])
        
    }
    
    func testWorkflowCancelled_VerificationCode() {
        
        let app = XCUIApplication()
        app.buttons["Login with phone.id"].tap()
        app.textFields["Phone Number"].typeText(TestConstants.PhoneNumber)
        app.buttons["OK"].tap()
        app.childrenMatchingType(.Window).elementBoundByIndex(0).childrenMatchingType(.Other).elementBoundByIndex(1).childrenMatchingType(.Other).element.childrenMatchingType(.Button).elementBoundByIndex(0).tap()
        
        XCTAssertNotNil(app.buttons["Login with phone.id"])
    }
    
    
    func testWrongVerifictionCode() {
        
        
        let app = XCUIApplication()
        app.buttons["Login with phone.id"].tap()
        app.textFields["Phone Number"].typeText(TestConstants.PhoneNumber)
        app.buttons["OK"].tap()
        
        let element = app.childrenMatchingType(.Window).elementBoundByIndex(0).childrenMatchingType(.Other).elementBoundByIndex(1).childrenMatchingType(.Other).element
        element.childrenMatchingType(.TextField).element.typeText("123456")
        
        XCTAssertNotNil(app.textViews["The code you typed is different\nfrom the one we've sent you.\n\nCo"])
        
    }
 
// temporary broken:
//
//    func testCountryCodeSearch() {
//        
//
//        let app = XCUIApplication()
//        app.buttons["Login with phone.id"].tap()
//        
//        NSThread.sleepForTimeInterval(0.5)
//        
//        app.buttons["+1"].tap()
//        
//        let searchSearchField = app.searchFields["Search"]
//        
//        NSThread.sleepForTimeInterval(1.5)
//        
//        searchSearchField.typeText("uni")
//        
//        
//        app.tables.elementBoundByIndex(0).staticTexts["United States"].tap()
//        
//        let phoneNumberTextField = app.textFields["Phone Number"]
//        phoneNumberTextField.tap()
//        phoneNumberTextField.typeText("4158320000")
//        app.buttons["OK"].tap()
//        app.textFields["______"].typeText("111111")
//        
//        XCTAssertNotNil(app.buttons["Log out"])
//        
//        
//    }
    
}
