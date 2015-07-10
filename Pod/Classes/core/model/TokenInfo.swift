//
//  TokenInfo.swift
//  PhoneIdSDK
//
//  Created by Alyona on 7/6/15.
//  Copyright © 2015 phoneId. All rights reserved.
//

import Foundation

public class TokenInfo: ParseableModel{
    
    public var accessToken:String?;
    public var refreshToken:String?;
    public var expirationPeriod:Int?;

    init(){
        super.init(json:[:])
    }
    
    public required init(json:NSDictionary){
        super.init(json:json)
        self.accessToken = json[TokenKey.Access] as? String
        self.refreshToken = json[TokenKey.Refresh] as? String
        self.expirationPeriod = json[TokenKey.ExpireTime] as? Int
    }
    
    public override func isValid() -> Bool{
        
        return accessToken != nil && refreshToken != nil && expirationPeriod != nil
    }
    
    internal class func loadFromKeyChain()->TokenInfo?{
        
        let tokenInfo = TokenInfo()
        
        tokenInfo.accessToken = KeychainStorage.loadValue(TokenKey.Access)
        tokenInfo.refreshToken = KeychainStorage.loadValue(TokenKey.Refresh)
        tokenInfo.expirationPeriod = KeychainStorage.loadIntValue(TokenKey.ExpireTime)
        
        return tokenInfo.isValid() ? tokenInfo : nil
    }
    
    internal func saveToKeyChain(){
        if(self.isValid()){
            KeychainStorage.saveValue(TokenKey.Access, value:self.accessToken!)
            KeychainStorage.saveValue(TokenKey.Refresh, value:self.refreshToken!)
            KeychainStorage.saveIntValue(TokenKey.ExpireTime, value:self.expirationPeriod!)
        }else{
            fatalError("Trying to save inconsistent token")
        }
    }
    
}