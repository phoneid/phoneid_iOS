//
//  NSURLRequest+PhoneId.swift
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


extension NSURLRequest{
    
    class func requestWithURL(URL: NSURL, method: String, queryParams: [String: String]?, bodyParams: Dictionary<String,AnyObject>?, headers: [String: String]?) -> NSURLRequest {
        
        let actualURL: NSURL
        if let queryParams = queryParams {
            
            var query:String=""
            for contentKey in queryParams.keys {
                if(contentKey == queryParams.keys.first) {
                    query += contentKey + "=" + (queryParams[contentKey]! as String).escapeStr()
                }
                else {
                    query += "&" + contentKey + "=" + (queryParams[contentKey]! as String).escapeStr()
                }
            }
            let components = NSURLComponents(URL: URL, resolvingAgainstBaseURL: true)!
            components.percentEncodedQuery = query
            print("query = \(query)")
            actualURL = components.URL!
        } else {
            actualURL = URL
        }
        
        print("URL = \(actualURL.absoluteString)", actualURL.absoluteString)
        
        let request = NSMutableURLRequest(URL: actualURL)
        request.HTTPMethod = method
        
        var headersMod = headers != nil ? headers! : [:]
        
        if let bodyParams = bodyParams{
            
            if headersMod[HttpHeaderName.ContentType]==HttpHeaderValue.JsonEncoded {
                do {
                    request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(bodyParams, options: [])
                    print(NSString(data: request.HTTPBody!, encoding: NSUTF8StringEncoding))
                } catch _ {
                    request.HTTPBody = nil
                }
            } else if headersMod[HttpHeaderName.ContentType]==HttpHeaderValue.FormEncoded{
                
                let needHandleMulripart = bodyParams.values.filter({ (element) -> Bool in
                    return ((element as? NSData) != nil || (element as? UIImage) != nil)
                })
                
                if(needHandleMulripart.count > 0){
                    let boundary:String = NSUUID().UUIDString
                    headersMod[HttpHeaderName.ContentType] = "\(HttpHeaderValue.FormMultipart); boundary=\(boundary)"
                    request.HTTPBody = prepareMultipartBody(bodyParams, boundary: boundary)                    
                    
                }else{
                    var firstOneAdded = false
                    let contentKeys:Array<String> = Array(bodyParams.keys)
                    var contentBodyAsString:String=""
                    for contentKey in contentKeys {
                        if(!firstOneAdded) {
                            contentBodyAsString += contentKey + "=" + (bodyParams[contentKey]! as! String).escapeStr()
                            firstOneAdded = true
                        }
                        else {
                            contentBodyAsString += "&" + contentKey + "=" + (bodyParams[contentKey]! as! String).escapeStr()
                        }
                    }
                    request.HTTPBody = contentBodyAsString.dataUsingEncoding(NSUTF8StringEncoding)!
                }
                
            }
            
            
        }
        
        for (field, value) in headersMod {
            request.setValue(value, forHTTPHeaderField: field)
        }
        
        return request
    }
    
    
    class func prepareMultipartBody(bodyParams: Dictionary<String,AnyObject>, boundary: String) -> NSData{
        
        let body = NSMutableData()
        
        body.appendString("boundary=\(boundary)\r\n")
        for (key, value) in bodyParams {
            
            let isImage = (value as? UIImage) != nil
            let isData = (value as? NSData) != nil
            let isBinary = (isData || isImage)
            
            body.appendString("--\(boundary)\r\n")
            if(isBinary){
                let valueData:NSData = isImage ? UIImageJPEGRepresentation(value as! UIImage, 0.7)! : value as! NSData
                body.appendString("Content-Disposition: form-data; name=\"\(key)\"; filename=\"\(key)\"\r\n")
                body.appendString("Content-Transfer-Encoding:binary\r\n")
                body.appendString("Content-Length: \(valueData.length)\r\n\r\n")
                body.appendData(valueData)
                body.appendString("\r\n")
                
            }else{
                body.appendString("Content-Disposition: form-data; name=\"\(key)\"\n\n")
                body.appendString("\(value)\r\n")
            }
            
        }
        
        body.appendString("--\(boundary)--\r\n")
        return body
    }
}

extension String {
    func escapeStr() -> (String) {
        let raw: NSString = self
        let allowedCharacters = NSCharacterSet.URLHostAllowedCharacterSet().mutableCopy();
        allowedCharacters.removeCharactersInString(":?&=;+!@#$()',*");
        let str = raw.stringByAddingPercentEncodingWithAllowedCharacters(allowedCharacters as! NSCharacterSet)
        return str!
    }
}

extension NSMutableData{
    func appendString(string:String){
        self.appendData(string.dataUsingEncoding(NSUTF8StringEncoding)!)
    }
}

