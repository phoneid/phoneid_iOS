//
//  Constants.swift
//  PhoneIdSDK
//
//  Created by Alyona on 6/23/15.
//  Copyright © 2015 phoneId. All rights reserved.
//

import Foundation


internal struct Notifications {
    static let LoginSuccess = "PhoneIdAccessOk"
    static let LoginFail = "PhoneIdAccessKo"
    static let UpdateAppName = "PhoneIdAppNameUpdate";
}

internal struct Constants {
    static let baseURL = NSURL(string: "https://api.phone.id/v2/")!
}

internal struct  HttpMethod {
    static let Post = "POST"
    static let Get = "GET"
    static let Put = "PUT"
    static let Patch = "PATCH"
    static let Delete = "DELETE"
}

internal struct HttpHeaderName{
    static let  ContentType = "Content-Type"
    static let  Authorization = "Authorization"
}

internal struct  HttpHeaderValue{
    static let  FormEncoded = "application/x-www-form-urlencoded"
    static let  JsonEncoded = "application/json"
}

internal enum Endpoints {
    case RequestCode
    case VerifyToken
    case RequestMe
    case ClientsList
    
    func endpoint(params: String...) -> String {
        switch (self) {
        case .RequestCode: return "auth/users/sendcode"
        case .VerifyToken: return "auth/users/token"
        case .RequestMe: return "auth/users/me"
        case .ClientsList: return "clients/\(params[0])"
        }
    }
}

internal struct TokenKey {
    static let Access = "access_token"
    static let Refresh = "refresh_token"
    static let ExpireTime = "expires_in"
}



