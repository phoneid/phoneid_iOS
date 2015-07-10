//
//  ParseableModel.swift
//  Pods
//
//  Created by Alyona on 7/10/15.
//
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