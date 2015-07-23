//
//  TestUtils.swift
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

@testable import phoneid_iOS

class TestConstants{

    static let ClientId = "TestPhoneId"
    static let AppName = "Test Phone.id"
    static let PhoneNumber = "4158320000"
    static let IsoCountryCode = "US"
    static let PhoneCountryCode = "+1"
    
    static let VerificationCode = "111111"
    
    
    static let defaultStepTimeout:NSTimeInterval = 10
    
    static let numberInfo = NumberInfo(number: PhoneNumber, countryCode: PhoneCountryCode, isoCountryCode: IsoCountryCode)
}

class MockSession: NSURLSession {
    var completionHandler: ((NSData!, NSURLResponse!, NSError!) -> Void)?
    
    var mockResponse: (data: NSData?, urlResponse: NSURLResponse?, error: NSError?) = (data: nil, urlResponse: nil, error: nil)
    
    override class func sharedSession() -> NSURLSession {
        return MockSession()
    }
    
    override func dataTaskWithRequest(request: NSURLRequest, completionHandler: (NSData?, NSURLResponse?, NSError?) -> Void) -> NSURLSessionDataTask{
        
        self.completionHandler = completionHandler
        return MockTask(response: self.mockResponse, completionHandler: completionHandler)
    }
    
    class MockTask: NSURLSessionDataTask {
        typealias Response = (data: NSData?, urlResponse: NSURLResponse?, error: NSError?)
        var mockResponse: Response
        let completionHandler: ((NSData!, NSURLResponse!, NSError!) -> Void)?
        
        init(response: Response, completionHandler: ((NSData!, NSURLResponse!, NSError!) -> Void)?) {
            self.mockResponse = response
            self.completionHandler = completionHandler
        }
        override func resume() {
            completionHandler!(mockResponse.data, mockResponse.urlResponse, mockResponse.error)
        }
    }
}

class MockUtil{

    class func sessionForMockResponseWithParams(endpoint:String, params:AnyObject, statusCode: Int) ->MockSession{
        let session = MockSession()
        let jsonData = try! NSJSONSerialization.dataWithJSONObject(params, options: [])
        let URL = NSURL(string: endpoint, relativeToURL: Constants.baseURL)!
        let urlResponse = NSHTTPURLResponse(URL:URL, statusCode: statusCode, HTTPVersion: nil, headerFields: nil)

        session.mockResponse = (jsonData, urlResponse: urlResponse, error: nil)
        
        return session
    }
}

extension NSError{

    func print(){
        if let reason = self.localizedFailureReason{
            NSLog("error description: \(self.localizedDescription) \nreason: \(reason)")
        }else{
            NSLog("error description: \(self.localizedDescription)")
        }

    }

}

func delay(delay:Double, closure:()->()) {
    dispatch_after(
        dispatch_time(
            DISPATCH_TIME_NOW,
            Int64(delay * Double(NSEC_PER_SEC))
        ),
        dispatch_get_main_queue(), closure)
}


