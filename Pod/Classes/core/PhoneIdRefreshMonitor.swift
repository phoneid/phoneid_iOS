//
//  PhoneIdTokenMonitor.swift
//  Pods
//
//  Created by Alyona on 7/13/15.
//
//

import Foundation

class PhoneIdRefreshMonitor{
    var timer:NSTimer?
    var notificationCenter:NSNotificationCenter!
    weak var phoneId:PhoneIdService!
    
    var isRunning:Bool
    let maxRefreshRetryCount = 5
    let refreshRetrySleepSeconds = 2.0
    var refreshRetryCount:Int
    
    
    init(phoneIdService:PhoneIdService, notificationCenter:NSNotificationCenter){
        phoneId = phoneIdService
        isRunning = false
        refreshRetryCount = 0
        self.notificationCenter = notificationCenter
        
        notificationCenter.addObserver(self, selector: "willEnterForeground", name: UIApplicationWillEnterForegroundNotification, object: nil)
        notificationCenter.addObserver(self, selector: "didEnterBackground", name: UIApplicationDidEnterBackgroundNotification, object: nil)
    }
    
    convenience init(phoneIdService:PhoneIdService){
        self.init(phoneIdService:phoneIdService, notificationCenter: NSNotificationCenter.defaultCenter())
    }
    
    deinit{
        stop()
        notificationCenter.removeObserver(self)
    }
    
    func start()-> Void {
        
        guard !isRunning else {return}
        
        isRunning = true
        
        guard phoneId.token != nil else {return}
        
        let token = phoneId.token!
        
        guard token.isValid() else {return}
        
        resetTimer(token)
        
    }
    
    func resetTimer(token:TokenInfo){
        refreshRetryCount = 0
        timer?.invalidate()
        timer = nil
        
        let fireTime =  token.expirationTime!.timeIntervalSince1970 - NSTimeInterval(token.expirationPeriod!/3)
        
        if(fireTime > NSDate().timeIntervalSince1970){
            
            let fireDate = NSDate(timeIntervalSince1970:fireTime)
            timer = NSTimer(fireDate: fireDate, interval: 0, target: self, selector: "timerFired", userInfo: nil, repeats: false)
            NSRunLoop.currentRunLoop().addTimer(timer!, forMode: NSDefaultRunLoopMode)
            
        }else{
            timerFired()
        }
        
        
    }
    
    @objc func timerFired(){
        
        guard isRunning else {return}
        
        phoneId.refreshToken { (token, error) -> Void in
            if(error == nil){
                
                self.resetTimer(token!)
                
            }else if(self.refreshRetryCount <= self.maxRefreshRetryCount){
                
                let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(self.refreshRetrySleepSeconds * Double(NSEC_PER_SEC)))
                dispatch_after(delayTime, dispatch_get_main_queue()) {
                    self.timerFired()
                }
                
            }else{
                self.stop()
                self.phoneId.logout()
            }
            self.refreshRetryCount++
        }
        
    }
    
    func stop(){
        timer?.invalidate()
        timer = nil
        isRunning = false
    }
    
    @objc func willEnterForeground(){
        
        self.start()
        
    }
    
    @objc func didEnterBackground(){
        
        self.stop()
        
    }
    
    
}