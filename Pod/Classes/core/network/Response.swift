//
//  Response.swift
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

typealias NetworkingCompletion = (Response) -> Void

public struct Response {

    let response: URLResponse!
    let data: Data!
    var error: NSError?
    
    var responseJSON: AnyObject? {
        var result:AnyObject? = nil;
        if let data = data {
            do {
                result = try JSONSerialization.jsonObject(with: data, options: [])
            } catch _ {
                if let e = error{
                   NSLog("Failed to deserialize JSON due to %@", e.localizedDescription)
                }
            }
        }
        return result
    }
    
    var responseString: String? {
        if let data = data,
            let string = NSString(data: data, encoding: String.Encoding.utf8.rawValue) {
                return String(string)
        } else {
            return nil
        }
    }
}
