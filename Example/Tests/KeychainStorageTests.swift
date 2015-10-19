//
//  KeychainStorageTests.swift
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
import phoneid_iOS

class KeychainStorageTests: XCTestCase {
    
    
    override func tearDown() {
        KeychainStorage.clear();
        super.tearDown()
    }
    
    func testSave() {

        KeychainStorage.saveValue("key1", value: "value1");
        let value = KeychainStorage.loadValue("key1");
        XCTAssertNotNil(value);
        XCTAssertEqual(value! as String, "value1", "saved and loaded vlaue for same key should be equal");
        
    }
    
    func testDoubleSave() {
        
        KeychainStorage.saveValue("key1", value: "value1");
        KeychainStorage.saveValue("key1", value: "value2");
        let value = KeychainStorage.loadValue("key1");
        XCTAssertNotNil(value);
        XCTAssertEqual(value! as String, "value2", "saved and loaded vlaue for same key should be equal");
        
    }
    
    func testLoadNonExisting() {
        
        let value = KeychainStorage.loadValue("key1_unexisting");
        XCTAssertNil(value);
        
    }
    
    func testDelete() {
        KeychainStorage.saveValue("key3", value: "value1");
        let result = KeychainStorage.deleteValue("key3");
        XCTAssertTrue(result, "Expected successfull delete");
        let value = KeychainStorage.loadValue("key3");
        XCTAssertNil(value);
        
    }
    
    func testClear() {
        KeychainStorage.saveValue("key1", value: "value1");
        KeychainStorage.saveValue("key2", value: "value2");
        KeychainStorage.saveValue("key3", value: "value3");
        let result = KeychainStorage.clear();
        XCTAssertTrue(result, "Expected successfull clear");
        XCTAssertNil(KeychainStorage.loadValue("key1"));
        XCTAssertNil(KeychainStorage.loadValue("key2"));
        XCTAssertNil(KeychainStorage.loadValue("key3"));
        
    }

    
}
