//
//  UserInfo.swift
//  PhoneIdSDK
//
//  Created by Alyona on 7/6/15.
//  Copyright © 2015 phoneId. All rights reserved.
//

import Foundation

public class UserInfo: NSObject{
    public var id:String?
    public var clientId:String?
    public var phoneNumber:String?
    
    public init(json:NSDictionary){
        super.init()
        id = json["id"] as? String
        clientId = json["client_id"] as? String
        phoneNumber = json["phone_number"] as? String
    }
    
    public func isValid() -> Bool{
    
        return id != nil && clientId != nil && phoneNumber != nil
    }
    
    

}