//
//  TestUtils.swift
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

@testable import phoneid_iOS

class TestConstants{
    
    static let ClientId = "TestPhoneId"
    static let AppName = "Test Phone.id"
    static let PhoneNumber = "4158320000"
    static let IsoCountryCode = "US"
    static let PhoneCountryCode = "+1"
    
    static let VerificationCode = "111111"
    
    
    static let defaultStepTimeout:TimeInterval = 10
    
    static let numberInfo = NumberInfo(number: PhoneNumber, countryCode: PhoneCountryCode, isoCountryCode: IsoCountryCode)
}

class MockSession: URLSession {
    typealias Response = (data: Data?, urlResponse: URLResponse?, error: NSError?)
    typealias CompletionHandler = ((Data?, URLResponse?, NSError?) -> Void)
    
    var mockResponses: [String : Response] = [:]
    
    func workQueue () ->OperationQueue { return OperationQueue.main}
    
    override class func sharedSession() -> URLSession {
        return MockSession()
    }
    
    override func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask{
        
        if let url = request.url?.absoluteString, let mockRequest = self.mockResponses[url]{
            return MockTask(session: self, request:request, response: mockRequest, completionHandler:completionHandler)
        }else{
            fatalError("Mock response is not configured for \(request.url)")
        }
    }
    
 
    class MockTask: URLSessionDataTask {
        var mockResponse:Response!
        var completionHandler:CompletionHandler!
        
        init(session:MockSession, request:URLRequest, response: Response, completionHandler: ((Data?, URLResponse?, NSError?) -> Void)?) {
            self.mockResponse = response
            self.completionHandler = completionHandler
        }
        
        override func resume() {
            self.completionHandler(mockResponse.data, mockResponse.urlResponse, mockResponse.error)
        }
    }
}

class MockUtil{
    
    class func mockResponseWithParams(_ session:MockSession, endpoint:String, params:AnyObject, statusCode: Int){
        
        let jsonData = try! JSONSerialization.data(withJSONObject: params, options: [])
        let URL = Foundation.URL(string: endpoint, relativeTo: Constants.baseURL)!
        let urlResponse = HTTPURLResponse(url:URL, statusCode: statusCode, httpVersion: nil, headerFields: nil)
        if let url = URL.absoluteString {
            session.mockResponses[url] = (jsonData, urlResponse: urlResponse, error: nil)
        }
    }
    
    class func sessionForMockResponseWithParams(_ endpoint:String, params:AnyObject, statusCode: Int) ->MockSession{
        let session = MockSession()
        self.mockResponseWithParams(session, endpoint: endpoint, params: params, statusCode: statusCode)
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

func delay(_ delay:Double, closure:@escaping ()->()) {
    DispatchQueue.main.asyncAfter(
        deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
}


