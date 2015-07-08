//
//  PhoneIdFramework.swift
//  PhoneIdTestApp
//
//  Created by Alberto Sarullo on 30/08/14.
//  Copyright (c) 2014 Alberto Sarullo. All rights reserved.
//

import UIKit
import libPhoneNumber_iOS

public typealias LoginCompletion = (accessToken: String?, refreshToken: String?, error:ErrorType?) -> Void
public typealias RequestCompletion = (error:NSError?) -> Void

public typealias UserInfoRequestCompletion = (userInfo:UserInfo?,error:NSError?) -> Void
public typealias VerificationRequestCompletion = (token:TokenInfo?,error:NSError?) -> Void
public typealias PhoneIdAuthenticationCompletion = (token:TokenInfo) -> Void

public class PhoneIdService: NSObject {
    
    public class var sharedInstance: PhoneIdService {
        struct Static { static let instance: PhoneIdService = PhoneIdService() }
        return Static.instance
    }
    
    public var componentFactory:ComponentFactory = DefaultComponentFactory()
    public var phoneIdAuthenticationCompletion: PhoneIdAuthenticationCompletion?
    
    
    // MARK: Private
    
    internal(set) var appName: String?
    internal(set) var clientId: String?
    internal var urlSession: NSURLSession!;
    private var apiBaseURL:NSURL!
    

    private var phoneUtil: NBPhoneNumberUtil {return NBPhoneNumberUtil.sharedInstance()}
    internal var token: TokenInfo? {
        get {
            return TokenInfo.loadFromKeyChain()
        }
    }
    
    override init(){
        super.init()
        urlSession = NSURLSession.sharedSession()
        apiBaseURL = Constants.baseURL
    }
    
    convenience init(baseURL:NSURL) {
        self.init()
        apiBaseURL = baseURL
    }
    
    public func configureClient(clienId: String) {
        self.clientId = clienId;
    }
    
    
    public func logout() {
        KeychainStorage.deleteValue(TokenKey.Access);
        KeychainStorage.deleteValue(TokenKey.Refresh);
    }
    
    // MARK: - API
    public func requestAuthenticationCode(info: NumberInfo, completion:RequestCompletion) {
        
        let validation = info.isValid()
        guard validation.result else{
            completion(error:validation.error);
            return
        }
        
        let number = info.e164Format()!
        
        self.get(Endpoints.RequestCode.endpoint(), params:["number":number,"client_id":clientId!], completion: { response in
            
            var error:NSError?=nil
            if (response.error != nil){
                
                NSLog("Failed to request PhoneId authentication code due to \(response.error))")
                error = PhoneIdServiceError.requestFailedError("error.failed.request.auth.code", reasonKey:response.error?.localizedDescription)
                
            }else if let info = response.responseJSON as? NSDictionary{
                let responseCode = info["result"] as? Int
                if(responseCode==0){
                   NSLog("Request authentication code success:\(responseCode), info: \(info)")
                }else{
                    let message = "No request success marker in response \(response.responseJSON)"
                    NSLog(message)
                    error = PhoneIdServiceError.requestFailedError("error.unexpected.response", reasonKey: "error.reason.auth.unexpected.response")
                }
            }
            completion(error:error)
        })
        
    }
    
    
    public func verifyAuthentication(verifyCode: String, info: NumberInfo, completion:VerificationRequestCompletion) {
        
        let validation = info.isValid()
        guard validation.result else{
            completion(token: nil, error:validation.error);
            return
        }
        
        if let number: String = info.e164Format(){
            
            var params: Dictionary<String, AnyObject> = [:]
            params["grant_type"]="authorization_code"
            params["client_id"]=clientId!
            params["code"]=verifyCode + "/" + number
            
            NSLog("request params: %@", params)
            
            self.post(Endpoints.VerifyToken.endpoint(), params:params) { response in
                
                var resultError:NSError? = nil
                var token:TokenInfo? = nil
                
                if let responseJSON = response.responseJSON as? NSDictionary, error = response.error {
                    var reason: String
                    if let errorMessage = responseJSON["message"] as? String {
                        reason = errorMessage
                    }else{
                        reason = error.localizedDescription
                    }
                    resultError = PhoneIdServiceError.requestFailedError("error.failed.request.code.verification",reasonKey: reason)
                    self.sendNotificationLoginFail(responseJSON)
                }else{
                    
                    if let responseJSON = response.responseJSON as? NSDictionary{
                        token = TokenInfo(json:responseJSON)
                        if(!token!.isValid()){
                            token = nil
                        }
                    }
                    
                    if(token != nil){
                        token!.saveToKeyChain()
                        self.sendNotificationLoginSuccess(token!)
                    }else{
                        resultError = PhoneIdServiceError.requestFailedError("error.unexpected.response", reasonKey: "error.reason.response.does.not.contrain.valid.token.info")
                        self.sendNotificationLoginFail(["message" : resultError!.localizedDescription] as NSDictionary)
                    }
                
                }
                
                completion(token:token, error:resultError)
            }
        }
    }
    
    public func loadUserInfo(completion:UserInfoRequestCompletion) {
        
        let endpoint: String = Endpoints.RequestMe.endpoint()
        self.get(endpoint, params: nil) { response in

            if let responseError =  response.error {
                NSLog("Failed to obtain user info due to %@", responseError)
                let error = PhoneIdServiceError.requestFailedError("error.failed.request.user.info", reasonKey: responseError.localizedDescription)
                completion(userInfo: nil, error: error)
            }else{
                var resultUserInfo:UserInfo?=nil
                if let info = response.responseJSON as? NSDictionary{
                    NSLog("received user info %@", info)
                    let userInfo:UserInfo = UserInfo(json: info)
                    if(userInfo.isValid()){
                        resultUserInfo = userInfo
                    }
                }
                
                if(resultUserInfo != nil){
                    completion(userInfo:resultUserInfo , error: nil)
                }else{
                    let error = PhoneIdServiceError.inappropriateResponseError("error.user.info.unexpected.response", reasonKey:"error.reason.user.info.unexpected.response")
                    completion(userInfo:nil , error: error)
                }
            }
            
        }
    }
    
    internal func loadClients(clientId:String, completion:RequestCompletion){
        
        let endpoint: String = Endpoints.ClientsList.endpoint(clientId)
        self.get(endpoint, params:nil, completion: { response in
            
            var resultError:NSError? = nil
            if let error = response.error{
                NSLog("Failed to obtain list of PhoneId clients due to \(error)")
                resultError = PhoneIdServiceError.requestFailedError("error.failed.request.clients", reasonKey: error.localizedDescription)
                
            }else if let info = response.responseJSON as? NSDictionary,
                appName = info["appName"] as? String {
                    
                self.appName = appName
                self.sendNotificationAppName(info)
            }else{
                NSLog("Failed to parse appName in response \(response.responseJSON)")
                resultError = PhoneIdServiceError.inappropriateResponseError("error.unexpected.response", reasonKey: "error.reason.clients.unexpected.response")
            }
            completion(error: resultError)
        })
        
    }
    
    public func requestCallMeNow() {
        // to be implemented
    }
    
    public func abortCall() {
        
        urlSession.getTasksWithCompletionHandler({
            (dataTasks, uploadTasks, downloadTasks) -> Void in
            for tasksList: [NSURLSessionTask] in [dataTasks, uploadTasks, downloadTasks] {
                for task in tasksList {
                    task.cancel();
                }
            }
        });
    }
    
    
    // MARK: - NOTIFICATIONS / CALLBACKS
    
    private func sendNotificationLoginSuccess(token:TokenInfo) {
        
        NSNotificationCenter
            .defaultCenter()
            .postNotificationName(Notifications.LoginSuccess, object: nil, userInfo: ["token":token])
    }
    
    private func sendNotificationLoginFail(info: NSDictionary) {
        NSNotificationCenter
            .defaultCenter()
            .postNotificationName(Notifications.LoginFail, object: nil, userInfo: info as [NSObject:AnyObject])
    }
    
    private func sendNotificationAppName(info: NSDictionary) {
        NSNotificationCenter
            .defaultCenter()
            .postNotificationName(Notifications.UpdateAppName, object: nil, userInfo: info as [NSObject:AnyObject])
    }
    
    // MARK  - Networking internals
    
    private func requestWithMethod(method: String, endpoint:String, queryParams: [String: String]? = nil, bodyParams: Dictionary<String,AnyObject>? = nil, headers:[String: String]?=nil, completion: NetworkingCompletion) {
        
        let URL = NSURL(string: endpoint, relativeToURL: self.apiBaseURL)!
        
        let request = NSURLRequest.requestWithURL(URL, method: method, queryParams: queryParams, bodyParams: bodyParams, headers: headers)
        
        let task:NSURLSessionDataTask! = urlSession.dataTaskWithRequest(request) { data, response, sessionError in
            
            var error = sessionError
            if let httpResponse = response as? NSHTTPURLResponse {
                if httpResponse.statusCode < 200 || httpResponse.statusCode >= 300 {
                    let description = "HTTP response was \(httpResponse.statusCode)"
                    error = NSError(domain: "Custom", code: 0, userInfo: [NSLocalizedDescriptionKey: description])
                }
            }
            
            dispatch_async(dispatch_get_main_queue()) {
                
                let response = Response(response: response, data: data, error: error)
                
                #if DEBUG
                    NSLog("Response as string: \(response.responseString)")
                #endif
                
                completion(response)
            }
        }
        
        task.resume()
        
    }
    
    private func get(endpoint:String, params: [String: String]? = nil, completion: NetworkingCompletion) {
        var headers:[String: String]? = nil
        if (self.token != nil) {
            headers = [ HttpHeaderName.Authorization :"Bearer \(self.token!.accessToken!)"]
        }
        requestWithMethod(HttpMethod.Get, endpoint:endpoint, queryParams: params, headers: headers, completion: completion)
    }
    
    private func post(endpoint:String, params: Dictionary<String,AnyObject>? = nil, completion: NetworkingCompletion) {
        let headers = [HttpHeaderName.ContentType : HttpHeaderValue.FormEncoded];
        requestWithMethod(HttpMethod.Post, endpoint:endpoint, bodyParams: params, headers: headers, completion: completion)
    }
    
    private func postJSON(endpoint:String, params: Dictionary<String,AnyObject>? = nil, completion: NetworkingCompletion) {
        let headers = [HttpHeaderName.ContentType : HttpHeaderValue.JsonEncoded];
        requestWithMethod(HttpMethod.Post, endpoint:endpoint, bodyParams: params, headers: headers, completion: completion)
    }
    
}


