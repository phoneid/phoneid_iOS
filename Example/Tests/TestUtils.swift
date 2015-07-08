//
//  TestUtils.swift
//  PhoneIdSDK
//
//  Created by Alyona on 7/5/15.
//  Copyright © 2015 phoneId. All rights reserved.
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
    
    
    override func dataTaskWithRequest(request: NSURLRequest, completionHandler: (NSData?, NSURLResponse?, NSError?) -> Void) -> NSURLSessionDataTask? {
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


