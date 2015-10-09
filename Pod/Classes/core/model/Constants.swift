//
//  Constants.swift
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


internal struct Notifications {
    static let VerificationSuccess = "PhoneIdLoginSuccess"
    static let VerificationFail = "PhoneIdLoginFail"
    static let DidLogout = "PhoneIdLogout"
    static let TokenRefreshed = "PhoneIdTokenRefreshed"
    static let AppNameUpdated = "PhoneIdAppNameUpdate"
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
    static let  FormMultipart = "multipart/form-data"
}

internal enum Endpoints {
    case RequestCode
    case RequestToken
    case RequestMe
    case ClientsList
    case Contacts
    case NeedRefreshContacts
    case UploadAvatar
    
    func endpoint(params: String...) -> String {
        switch (self) {
        case .RequestCode: return "auth/sendcode"
        case .RequestToken: return "auth/token"
        case .RequestMe: return "users/me"
        case .ClientsList: return "clients/\(params[0])"
        case .Contacts: return "contacts"
        case .NeedRefreshContacts: return "contacts/refresh?checksum=\(params[0])"
        case .UploadAvatar: return "users/upload"
        }
    }
}

internal struct TokenKey {
    static let Access = "access_token"
    static let Refresh = "refresh_token"
    static let ExpireTime = "expires_in"
    static let Timestamp = "timestamp"
}

internal struct NumberKey {
    static let number = "phone_number"
    static let iso = "iso_country_code"
    static let countryCode = "country_code"
}

internal enum AuthChannels{
    case Sms
    case Call
    var value:String{
        get{
          switch(self){
          case Sms: return "sms"
          case Call: return "call"}
        }
    }
}

