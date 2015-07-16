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
    public var timestamp:NSDate?;
    
    public var expirationTime:NSDate?{
        get {
            var result:NSDate? = nil
            if let timestamp = timestamp, expirationPeriod=expirationPeriod{
                result = NSDate(timeIntervalSince1970: timestamp.timeIntervalSince1970 + NSTimeInterval(expirationPeriod))
            }
            return result
        }
    }
    
    public var expired:Bool{
        get {
            let result = expirationTime?.timeIntervalSince1970 < NSDate().timeIntervalSince1970
            return result
        }
    }

    init(){
        super.init(json:[:])
    }
    
    public required init(json:NSDictionary){
        super.init(json:json)
        self.accessToken = json[TokenKey.Access] as? String
        self.refreshToken = json[TokenKey.Refresh] as? String
        self.expirationPeriod = json[TokenKey.ExpireTime] as? Int
        
        //#if DEBUG
        //    self.expirationPeriod = 30
        //#endif
        
        
        self.timestamp = NSDate()
    }
    
    public override func isValid() -> Bool{
        
        return accessToken != nil && refreshToken != nil && expirationPeriod != nil
    }
    
    internal class func loadFromKeyChain()->TokenInfo?{
        
        let tokenInfo = TokenInfo()
        
        tokenInfo.accessToken = KeychainStorage.loadValue(TokenKey.Access)
        tokenInfo.refreshToken = KeychainStorage.loadValue(TokenKey.Refresh)
        tokenInfo.expirationPeriod = KeychainStorage.loadIntValue(TokenKey.ExpireTime)

        if let timestamp = KeychainStorage.loadTimeIntervalValue(TokenKey.Timestamp){
            tokenInfo.timestamp = NSDate(timeIntervalSince1970:timestamp)
        }
        
        return tokenInfo.isValid() ? tokenInfo : nil
    }
    
    internal func saveToKeychain(){
        if(self.isValid()){
            
            KeychainStorage.saveValue(TokenKey.Access, value:self.accessToken!)
            KeychainStorage.saveValue(TokenKey.Refresh, value:self.refreshToken!)
            KeychainStorage.saveIntValue(TokenKey.ExpireTime, value:self.expirationPeriod!)
            KeychainStorage.saveTimeIntervalValue(TokenKey.Timestamp, value: self.timestamp!.timeIntervalSince1970)
            
        }else{
            fatalError("Trying to save inconsistent token")
        }
    }
    
    internal func removeFromKeychain(){
        KeychainStorage.deleteValue(TokenKey.Access);
        KeychainStorage.deleteValue(TokenKey.Refresh);
        KeychainStorage.deleteValue(TokenKey.Access);
        KeychainStorage.deleteValue(TokenKey.Refresh);
    }
    
}