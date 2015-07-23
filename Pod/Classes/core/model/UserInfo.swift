//
//  UserInfo.swift
//  phoneid_iOS
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


import Foundation



public class UserInfo: ParseableModel{
    public var id:String?
    public var clientId:String?
    public var phoneNumber:String?
    
    public required init(json:NSDictionary){
        super.init(json:json)
        id = json["id"] as? String
        clientId = json["client_id"] as? String
        phoneNumber = json["phone_number"] as? String
    }
    
    public override func isValid() -> Bool{
        return id != nil && clientId != nil && phoneNumber != nil
    }

}