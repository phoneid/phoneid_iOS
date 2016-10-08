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


extension URLRequest{
    
    static func requestWithURL(_ URL: Foundation.URL, method: String, queryParams: [String: String]?, bodyParams: Dictionary<String,AnyObject>?, headers: [String: String]?) -> URLRequest {
        
        let actualURL: Foundation.URL
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
            var components = URLComponents(url: URL, resolvingAgainstBaseURL: true)!
            components.percentEncodedQuery = query
            print("query = \(query)")
            actualURL = components.url!
        } else {
            actualURL = URL
        }
        
        print("URL = \(actualURL.absoluteString)", actualURL.absoluteString)
        
        let request = NSMutableURLRequest(url: actualURL)
        request.httpMethod = method
        
        var headersMod = headers != nil ? headers! : [:]
        
        if let bodyParams = bodyParams{
            
            if headersMod[HttpHeaderName.ContentType]==HttpHeaderValue.JsonEncoded {
                do {
                    request.httpBody = try JSONSerialization.data(withJSONObject: bodyParams, options: [])
                    print(NSString(data: request.httpBody!, encoding: String.Encoding.utf8.rawValue))
                } catch _ {
                    request.httpBody = nil
                }
            } else if headersMod[HttpHeaderName.ContentType]==HttpHeaderValue.FormEncoded{
                
                let needHandleMulripart = bodyParams.values.filter({ (element) -> Bool in
                    return ((element as? Data) != nil || (element as? UIImage) != nil)
                })
                
                if(needHandleMulripart.count > 0){
                    let boundary:String = UUID().uuidString
                    headersMod[HttpHeaderName.ContentType] = "\(HttpHeaderValue.FormMultipart); boundary=\(boundary)"
                    request.httpBody = prepareMultipartBody(bodyParams, boundary: boundary)                    
                    
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
                    request.httpBody = contentBodyAsString.data(using: String.Encoding.utf8)!
                }
                
            }
            
            
        }
        
        for (field, value) in headersMod {
            request.setValue(value, forHTTPHeaderField: field)
        }
        
        return request as URLRequest
    }
    
    
    static func prepareMultipartBody(_ bodyParams: Dictionary<String,AnyObject>, boundary: String) -> Data{
        
        let body = NSMutableData()
        
        body.appendString("boundary=\(boundary)\r\n")
        for (key, value) in bodyParams {
            
            let isImage = (value as? UIImage) != nil
            let isData = (value as? Data) != nil
            let isBinary = (isData || isImage)
            
            body.appendString("--\(boundary)\r\n")
            if(isBinary){
                let valueData:Data = isImage ? UIImageJPEGRepresentation(value as! UIImage, 0.7)! : value as! Data
                body.appendString("Content-Disposition: form-data; name=\"\(key)\"; filename=\"\(key)\"\r\n")
                body.appendString("Content-Transfer-Encoding:binary\r\n")
                body.appendString("Content-Length: \(valueData.count)\r\n\r\n")
                body.append(valueData)
                body.appendString("\r\n")
                
            }else{
                body.appendString("Content-Disposition: form-data; name=\"\(key)\"\n\n")
                body.appendString("\(value)\r\n")
            }
            
        }
        
        body.appendString("--\(boundary)--\r\n")
        return body as Data
    }
}

extension String {
    func escapeStr() -> (String) {
        let raw: NSString = self as NSString
        let allowedCharacters = (CharacterSet.urlHostAllowed as NSCharacterSet).mutableCopy();
        (allowedCharacters as AnyObject).removeCharacters(in: ":?&=;+!@#$()',*");
        let str = raw.addingPercentEncoding(withAllowedCharacters: allowedCharacters as! CharacterSet)
        return str!
    }
}

extension NSMutableData{
    func appendString(_ string:String){
        self.append(string.data(using: String.Encoding.utf8)!)
    }
}

