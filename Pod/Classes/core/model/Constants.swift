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
    static let baseURL = URL(string: "https://api.phone.id/v2/")!
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
    case requestCode
    case requestToken
    case requestMe
    case clientsList
    case contacts
    case needRefreshContacts
    case uploadAvatar
    
    func endpoint(_ params: String...) -> String {
        switch (self) {
        case .requestCode: return "auth/sendcode"
        case .requestToken: return "auth/token"
        case .requestMe: return "users/me"
        case .clientsList: return "clients/\(params[0])"
        case .contacts: return "contacts"
        case .needRefreshContacts: return "contacts/refresh?checksum=\(params[0])"
        case .uploadAvatar: return "users/upload"
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
    case sms
    case call
    var value:String{
        get{
          switch(self){
          case .sms: return "sms"
          case .call: return "call"}
        }
    }
}

