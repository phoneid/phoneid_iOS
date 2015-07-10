//
//  Response.swift
//  PhoneIdSDK
//
//  Created by Alyona on 6/23/15.
//  Copyright © 2015 phoneId. All rights reserved.
//

import Foundation

typealias NetworkingCompletion = Response -> Void

public struct Response {

    let response: NSURLResponse!
    let data: NSData!
    var error: NSError?
    
    var responseJSON: AnyObject? {
        var result:AnyObject? = nil;
        if let data = data {
            do {
                result = try NSJSONSerialization.JSONObjectWithData(data, options: [])
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
            string = NSString(data: data, encoding: NSUTF8StringEncoding) {
                return String(string)
        } else {
            return nil
        }
    }
}