//
//  PhoneIdRefreshMonitor
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

class PhoneIdRefreshMonitor{
    var timer:Timer?
    var notificationCenter:NotificationCenter!
    weak var phoneId:PhoneIdService!
    var reachability:Reachability?
    
    var isRunning:Bool
    let maxRefreshRetryCount = 5
    let refreshRetrySleepSeconds = 2.0
    var refreshRetryCount:Int
    
    
    init(phoneIdService:PhoneIdService, notificationCenter:NotificationCenter){
        phoneId = phoneIdService
        isRunning = false
        refreshRetryCount = 0
        self.notificationCenter = notificationCenter
        
        do{
            reachability = try Reachability()
        } catch {
            print("PhoneId: Failed to start reachability monitor")
        }
        
        notificationCenter.addObserver(self, selector: #selector(PhoneIdRefreshMonitor.willEnterForeground), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
        notificationCenter.addObserver(self, selector: #selector(PhoneIdRefreshMonitor.didEnterBackground), name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
    }
    
    convenience init(phoneIdService:PhoneIdService){
        self.init(phoneIdService:phoneIdService, notificationCenter: NotificationCenter.default)
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
        
        startReachabilityMonitoring()
        
        resetTimer(token)
        
    }
    
    func startReachabilityMonitoring(){
        
        try?reachability?.start()
        
//        if let reachability = reachability{
//            
//            
//            reachability.whenReachable = {[unowned self] reachability in
//                self.start()
//            }
//            reachability.whenUnreachable = {[unowned self] reachability in
//                self.stop()
//            }
//            do {
//                try reachability.startNotifier()
//            } catch {
//                print("Unable to start reachability notifier for phone.id")
//            }
//        }else{
//            print("Failed to create reachability object for phone.id refresh token monitor.")
//        }

    }
    
    func resetTimer(_ token:TokenInfo){
        refreshRetryCount = 0
        timer?.invalidate()
        timer = nil
        
        var fireTime = 0.0
        
        if let expirationTime = token.expirationTime {
            fireTime = expirationTime.timeIntervalSince1970 - TimeInterval(token.expirationPeriod!/3)
        }
        
        if(fireTime > Date().timeIntervalSince1970){
            
            let fireDate = Date(timeIntervalSince1970:fireTime)
            timer = Timer(fireAt: fireDate, interval: 0, target: self, selector: #selector(PhoneIdRefreshMonitor.timerFired), userInfo: nil, repeats: false)
            RunLoop.current.add(timer!, forMode: RunLoopMode.defaultRunLoopMode)
            
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
                
                let delayTime = DispatchTime.now() + Double(Int64(self.refreshRetrySleepSeconds * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
                DispatchQueue.main.asyncAfter(deadline: delayTime) {
                    self.timerFired()
                }
                
            }else{
                self.stop()
                self.phoneId.logout()
            }
            self.refreshRetryCount+=1
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
