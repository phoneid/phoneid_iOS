//
//  PhoneIdServiceError.swift
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

public enum ErrorCode:Int{
    case inappropriateResult = 101
    case requestFailed = 102
    case invalidParameters = 100
    
    var asInt:Int {
        get{ return self.rawValue}
    }
}

open class PhoneIdServiceError:NSError{
    
    public init(code:Int, descriptionKey:String, reasonKey:String?){
        let description =  NSLocalizedString(descriptionKey, bundle: Bundle.phoneIdBundle(), comment:descriptionKey)
        var info = [NSLocalizedDescriptionKey:description]
        
        if let reasonKey = reasonKey{
            let reason =  NSLocalizedString(reasonKey, bundle: Bundle.phoneIdBundle(), comment:reasonKey)
            info[NSLocalizedFailureReasonErrorKey] = reason
        }
        super.init(domain:"com.phoneid.PhoneIdSDK", code: code, userInfo: info)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
            
    open class func inappropriateResponseError(_ descriptionKey:String, reasonKey:String?) -> PhoneIdServiceError{
        return PhoneIdServiceError(code:ErrorCode.inappropriateResult.asInt, descriptionKey:descriptionKey  , reasonKey: reasonKey)
    }
    
    open class func requestFailedError(_ descriptionKey:String, reasonKey:String?) -> PhoneIdServiceError{
        return PhoneIdServiceError(code:ErrorCode.requestFailed.asInt, descriptionKey: descriptionKey, reasonKey: reasonKey)
    }
    
    open class func invalidParameters(_ descriptionKey:String, reasonKey:String?) -> PhoneIdServiceError{
        return PhoneIdServiceError(code:ErrorCode.invalidParameters.asInt, descriptionKey:"error.phone.number.validation.failed", reasonKey: reasonKey)
    }
}



