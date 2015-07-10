//
//  PhoneIdServiceError.swift
//  PhoneIdSDK
//
//  Created by Alyona on 7/5/15.
//  Copyright © 2015 phoneId. All rights reserved.
//

import Foundation

public enum ErrorCode:Int{
    case InappropriateResult = 101
    case RequestFailed = 102
    case InvalidParameters = 100
    
    var asInt:Int {
        get{ return self.rawValue}
    }
}

public class PhoneIdServiceError:NSError{
    
    public init(code:Int, descriptionKey:String, reasonKey:String?){
        let description =  NSLocalizedString(descriptionKey, bundle: NSBundle.phoneIdBundle(), comment:descriptionKey)
        var info = [NSLocalizedDescriptionKey:description]
        
        if let reasonKey = reasonKey{
            let reason =  NSLocalizedString(reasonKey, bundle: NSBundle.phoneIdBundle(), comment:reasonKey)
            info[NSLocalizedFailureReasonErrorKey] = reason
        }
        super.init(domain:"com.phoneid.PhoneIdSDK", code: code, userInfo: info)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
            
    public class func inappropriateResponseError(descriptionKey:String, reasonKey:String?) -> PhoneIdServiceError{
        return PhoneIdServiceError(code:ErrorCode.InappropriateResult.asInt, descriptionKey:descriptionKey  , reasonKey: reasonKey)
    }
    
    public class func requestFailedError(descriptionKey:String, reasonKey:String?) -> PhoneIdServiceError{
        return PhoneIdServiceError(code:ErrorCode.RequestFailed.asInt, descriptionKey: descriptionKey, reasonKey: reasonKey)
    }
    
    public class func invalidParameters(descriptionKey:String, reasonKey:String?) -> PhoneIdServiceError{
        return PhoneIdServiceError(code:ErrorCode.InvalidParameters.asInt, descriptionKey:"error.phone.number.validation.failed", reasonKey: reasonKey)
    }
}



