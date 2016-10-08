//
//  UserInfo.swift
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

import libPhoneNumber_iOS

open class UserInfo: ParseableModel{
    open var id:String?
    open var clientId:String?
    open var screenName:String?
    open var phoneNumber:String?
    open var dateOfBirth:Date?
    open var imageURL:String?
    open var updatedImage:UIImage?
    
    public required init(json:NSDictionary){
        super.init(json:json)
        id = json["id"] as? String
        clientId = json["client_id"] as? String
        phoneNumber = json["phone_number"] as? String
        screenName = json["screen_name"] as? String
        imageURL = json["picture"] as? String
        if let birthdate = json["birthdate"] as? String{
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            dateOfBirth = dateFormatter.date(from: birthdate)
        }
    }
    
    open override func isValid() -> Bool{
        return id != nil && clientId != nil && phoneNumber != nil
    }
    
    func dateOfBirthAsString() ->String?{
        var result:String? = nil
        if let dateOfBirth=self.dateOfBirth {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = DateFormatter.Style.medium
            dateFormatter.timeStyle = DateFormatter.Style.none
            
            result = dateFormatter.string(from: dateOfBirth)
        }

        return result
    }

    func asDictionary()->[String:String]{
        var result:[String:String] = [:]
        if let screenName = self.screenName {
            result["screen_name"] = screenName
        }
        if let birthdate = self.dateOfBirth {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            result["birthdate"] = dateFormatter.string(from: birthdate)
        }
        return result
    }
    
    func formattedPhoneNumber()->String?{
        
        let number = NumberInfo(numberE164: self.phoneNumber).internationalFormatted()
        return number
    }
    
}
