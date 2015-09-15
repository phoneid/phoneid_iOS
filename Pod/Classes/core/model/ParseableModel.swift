//
//  ParseableModel.swift
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

public protocol Parseable{
    init(json:NSDictionary)
    func isValid() -> Bool
    static func parse(response:Response) -> Self?
}

public class ParseableModel:NSObject, Parseable{
    
    public required init(json:NSDictionary){
        super.init()
    }

    public class func parse(response:Response) -> Self?{
        
        if let info = response.responseJSON as? NSDictionary{
            
            let result = self.init(json:info)
            
            if(result.isValid()){
                return result
            }
        }
        return nil
    }
    
    public func isValid() -> Bool{ return true}
}