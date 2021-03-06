//
//  ContactInfo.swift
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


internal class ContactInfo: NSObject{
    
    var number:String?
    var kind:String?
    var firstName:String?
    var lastName:String?
    var company:String?
            
    func asDebugDictionary() -> [String:String]{
        
        var result:[String:String] = [:]
        
        if let number = self.number {
            result["number"] = number
        }
        
        if let kind = self.kind {
            result["kind"] = kind
        }
        
        if let firstName = self.firstName {
            result["first_name"] = firstName
        }
        
        if let lastName = self.lastName {
            result["last_name"] = lastName
        }
        
        if let company = self.company {
            result["company"] = company
        }
        
        if let number = self.number {
            result["number_checksum"] = number.sha1()
        }
        return result
    }
    
    func asDictionary()->[String:String]{
        var result:[String:String] = [:]
        if let number = self.number {
            result["number_checksum"] = number.sha1()
        }
        return result
    }
}