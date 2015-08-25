//
//  PhoneIdService.swift
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



import UIKit
import libPhoneNumber_iOS


public typealias RequestCompletion = (error:NSError?) -> Void
public typealias UserInfoRequestCompletion = (userInfo:UserInfo?,error:NSError?) -> Void
public typealias TokenRequestCompletion = (token:TokenInfo?,error:NSError?) -> Void

public typealias PhoneIdAuthenticationSucceed = (token:TokenInfo) -> Void
public typealias PhoneIdWorkflowErrorHappened = (error:NSError) -> Void
public typealias PhoneIdAuthenticationCancelled = () -> Void

public class PhoneIdService: NSObject {
    
    public class var sharedInstance: PhoneIdService {
        struct Static { static let instance: PhoneIdService = PhoneIdService() }
        return Static.instance
    }
    
    public var componentFactory:ComponentFactory = DefaultComponentFactory()
    public var phoneIdAuthenticationSucceed: PhoneIdAuthenticationSucceed?
    public var phoneIdAuthenticationCancelled: PhoneIdAuthenticationCancelled?
    public var phoneIdAuthenticationRefreshed: PhoneIdAuthenticationSucceed?
    public var phoneIdWorkflowErrorHappened: PhoneIdWorkflowErrorHappened?
    public var phoneIdDidLogout:(() -> Void)?
    
    public var isLoggedIn: Bool {
        get {
            return token != nil ? self.token!.isValid() : false
        }
    }
    
    public var token: TokenInfo? {
        get {
            return TokenInfo.loadFromKeyChain()
        }
    }
    
    public internal(set) var appName: String?
    public internal(set) var clientId: String?
    public internal(set) var autorefreshToken: Bool = true
    
    internal var urlSession: NSURLSession!;
    internal var refreshMonitor: PhoneIdRefreshMonitor!;
    
    private var apiBaseURL:NSURL!
    private var phoneUtil: NBPhoneNumberUtil {return NBPhoneNumberUtil.sharedInstance()}
    
    override init(){
        super.init()
        urlSession = NSURLSession.sharedSession()
        apiBaseURL = Constants.baseURL
        
    }
    
    convenience init(baseURL:NSURL) {
        self.init()
        apiBaseURL = baseURL
    }
    
    public func configureClient(id: String, autorefresh:Bool = true) {
        self.autorefreshToken = autorefresh
        
        self.clientId = id;
        
        if(autorefresh){
            refreshMonitor = PhoneIdRefreshMonitor(phoneIdService:self)
            if(self.isLoggedIn){
                refreshMonitor.start()
            }
        }
    }
    
    
    public func logout() {
        
        self.refreshMonitor?.stop()
        self.token?.removeFromKeychain();
        
        NSNotificationCenter
            .defaultCenter()
            .postNotificationName(Notifications.DidLogout, object: nil, userInfo:nil)
        phoneIdDidLogout?()
    }
    
    // MARK: - API
    func requestAuthenticationCode(info: NumberInfo, completion:RequestCompletion) {
        
        let validation = info.isValid()
        guard validation.result else{
            completion(error:validation.error);
            self.notifyClientCodeAboutError(validation.error)
            return
        }
        
        let number = info.e164Format()!
        
        self.post(Endpoints.RequestCode.endpoint(), params:["number":number,"client_id":clientId!], completion: { response in
            
            var error:NSError?=nil
            if let responseError = response.error {
                NSLog("Failed to request PhoneId authentication code due to \(responseError))")
                error = PhoneIdServiceError.requestFailedError("error.failed.request.auth.code", reasonKey:responseError.localizedDescription)
                
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
            self.notifyClientCodeAboutError(error)
        })
        
    }
    
    func verifyAuthentication(verifyCode: String, info: NumberInfo, completion:TokenRequestCompletion) {
        
        let validation = info.isValid()
        guard validation.result else{
            completion(token: nil, error:validation.error);
            self.notifyClientCodeAboutError(validation.error)
            return
        }
        
        if let number: String = info.e164Format(){
            
            var params: Dictionary<String, AnyObject> = [:]
            params["grant_type"] = "password"
            params["username"] = number
            params["password"] = verifyCode
            params["client_id"] = clientId!
            
            print("request params: \(params)")
            
            self.post(Endpoints.RequestToken.endpoint(), params:params) { response in
                
                var error:NSError?
                var token:TokenInfo?
                
                if let responseError = response.error {
                    NSLog("Failed to verify code %@", responseError)
                    error = PhoneIdServiceError.requestFailedError("error.failed.request.code.verification",reasonKey: responseError.localizedDescription)
                    self.sendNotificationVerificationFail(error!)
                    
                    
                }else if let receivedToken = TokenInfo.parse(response){
                    receivedToken.numberInfo = info
                    self.doOnAuthenticationSucceed(receivedToken)
                    token = receivedToken
                    
                }else{
                    error = PhoneIdServiceError.requestFailedError("error.unexpected.response", reasonKey: "error.reason.response.does.not.contain.valid.token.info")
                    self.sendNotificationVerificationFail(error!)
                }
                
                completion(token:token, error:error)
                self.notifyClientCodeAboutError(error)
            }
        }
    }
    
    func doOnAuthenticationSucceed(token:TokenInfo){
        token.saveToKeychain()
        
        if(self.autorefreshToken){
            self.refreshMonitor?.start()
        }
        
        self.sendNotificationVerificationSuccess()
    }
    
    func loadUserInfo(completion:UserInfoRequestCompletion) {
        
        let endpoint: String = Endpoints.RequestMe.endpoint()
        self.get(endpoint, params: nil) { response in
            
            var error:NSError?
            var userInfo:UserInfo?
            
            if let responseError = response.error {
                NSLog("Failed to obtain user info due to %@", responseError)
                error = PhoneIdServiceError.requestFailedError("error.failed.request.user.info", reasonKey: responseError.localizedDescription)
                
            }else if let resultUserInfo = UserInfo.parse(response){
                userInfo = resultUserInfo
            }else{
                error = PhoneIdServiceError.inappropriateResponseError("error.user.info.unexpected.response", reasonKey:"error.reason.user.info.unexpected.response")
            }
            
            completion(userInfo:userInfo , error: error)
            self.notifyClientCodeAboutError(error)
        }
    }
    
    func loadClients(clientId:String, completion:RequestCompletion){
        
        let endpoint: String = Endpoints.ClientsList.endpoint(clientId)
        self.get(endpoint, params:nil, completion: { response in
            
            var resultError:NSError? = nil
            if let error = response.error{
                NSLog("Failed to obtain list of PhoneId clients due to \(error)")
                resultError = PhoneIdServiceError.requestFailedError("error.failed.request.clients", reasonKey: error.localizedDescription)
                
            }else if let info = response.responseJSON as? NSDictionary, appName = info["appName"] as? String {
                self.appName = appName
                self.sendNotificationAppName()
                
            }else{
                NSLog("Failed to parse appName in response \(response.responseJSON)")
                resultError = PhoneIdServiceError.inappropriateResponseError("error.unexpected.response", reasonKey: "error.reason.clients.unexpected.response")
            }
            completion(error: resultError)
            self.notifyClientCodeAboutError(resultError)
        })
        
    }
    
    public func refreshToken(completion:TokenRequestCompletion){
        
        self.checkToken("error.failed.refresh.token", success: { [unowned self] (token) -> Void in
            
            var params: Dictionary<String, AnyObject> = [:]
            params["grant_type"]="refresh_token"
            params["client_id"]=self.clientId!
            params["refresh_token"]=token.refreshToken
            
            print("request params: \(params)")
            
            
            self.post(Endpoints.RequestToken.endpoint(), params:params, completion: { response in
                
                var error:NSError?
                var token:TokenInfo?
                
                if let responseError = response.error{
                    NSLog("Failed refresh token \(responseError)")
                    error = PhoneIdServiceError.requestFailedError("error.failed.refresh.token", reasonKey: responseError.localizedDescription)
                    
                }else if let refreshedToken = TokenInfo.parse(response) {
                    token = refreshedToken
                    self.doOnAuthenticationRefreshSucceed(refreshedToken)
                }else{
                    NSLog("Failed to parse token in response \(response.responseJSON)")
                    error = PhoneIdServiceError.inappropriateResponseError("error.unexpected.response", reasonKey: "error.reason.response.does.not.contain.valid.token.info")
                }
                
                completion(token: token, error: error)
                self.notifyClientCodeAboutError(error)
            })
            
            }, fail: {(error) -> Void in
                
                completion(token: nil, error: error)
                
        })
    }
    
    public func uploadContacts(completion:RequestCompletion){
        
        self.checkToken("error.failed.refresh.token", success: {(token) -> Void in
            
            ContactsLoader().getContacts(token.numberInfo!.isoCountryCode!) { (contacts:[ContactInfo]?) -> Void in
                
                if let contacts = contacts{
                    
                    self.updateContactsIfNeeded(contacts, completion:completion)
                    
                }else{
                    completion(error: nil)
                }
            }
            
            }, fail: { (error) -> Void in
                completion(error: nil)
        })
        
    }
    
    internal func needsUpdateContacts(contacts:[ContactInfo], completion:(needsUpdate:Bool)->Void){
        
        let checksums:[String] = contacts.map({ return $0.number!.sha1()})
        
        let checksumFlat = ",".join(checksums.sort())
        
        let endpoint = Endpoints.NeedRefreshContacts.endpoint(checksumFlat.sha1())
        
        self.get(endpoint, params: nil, completion: { (response) -> Void in
            
            var result:Bool = true
            
            if let json = response.responseJSON as? NSDictionary,
                needsUpdate = json["refresh_needed"] as? Bool{
                    
                    result = needsUpdate
            }
            
            completion(needsUpdate: result)
        })
    }
    
    internal func updateContactsIfNeeded(contacts:[ContactInfo], completion:RequestCompletion){
        
        self.needsUpdateContacts(contacts, completion: { (needsUpdate) -> Void in
            
            if(needsUpdate){
                
                let params = self.wrapContactsAsHTTPFormParams(contacts)
                
                let endpoint = Endpoints.Contacts.endpoint()
                
                self.post(endpoint, params: params, completion: { (response) -> Void in
                    var error:NSError?
                    
                    if let responseError = response.error{
                        NSLog("Failed to upload contacts \(responseError)")
                        error = PhoneIdServiceError.requestFailedError("error.failed.to.upload.contacts", reasonKey: responseError.localizedDescription)
                        
                    }
                    
                    completion(error: error)
                    self.notifyClientCodeAboutError(error)
                    
                })
                
            }else{
                completion(error: nil)
            }
            
        })
    }
    
    
    private func wrapContactsAsHTTPFormParams(contacts:[ContactInfo]) -> [String:AnyObject]{
        
        let contactsDictionary = contacts.map({ return $0.asDictionary()})
        
        let serialized = try! NSJSONSerialization.dataWithJSONObject(["contacts": contactsDictionary], options: [.PrettyPrinted])
        
        let serializedAsString = NSString(data: serialized, encoding: NSUTF8StringEncoding) as! String
        
        print(serializedAsString)
        return ["contacts":serializedAsString]
    }
    
    private func checkToken(errorKey:String, success:(token:TokenInfo)->Void, fail:(error:PhoneIdServiceError)->Void){
        
        if let currentToken = self.token{
            success(token: currentToken)
        }else{
            let error = PhoneIdServiceError.requestFailedError(errorKey, reasonKey:"error.unautorized.request")
            fail(error: error)
            self.notifyClientCodeAboutError(error)
        }
    }
    
    func doOnAuthenticationRefreshSucceed(token:TokenInfo){
        token.saveToKeychain()
        self.phoneIdAuthenticationRefreshed?(token: token)
        self.sendNotificationTokenRefreshed()
    }
    
    func abortCall() {
        
        urlSession.getTasksWithCompletionHandler({
            (dataTasks, uploadTasks, downloadTasks) -> Void in
            for tasksList: [NSURLSessionTask] in [dataTasks, uploadTasks, downloadTasks] {
                for task in tasksList {
                    task.cancel();
                }
            }
        });
    }
    
    
    // MARK: - NOTIFICATIONS / CALLBACKS for client code
    func notifyClientCodeAboutError(error:NSError?){
        if(error != nil){
            self.phoneIdWorkflowErrorHappened?(error: error!)
        }
    }
    
    
    // MARK: - NOTIFICATIONS / CALLBACKS internal
    
    private func sendNotificationVerificationSuccess() {
        NSNotificationCenter
            .defaultCenter()
            .postNotificationName(Notifications.VerificationSuccess, object: nil, userInfo:nil)
    }
    
    private func sendNotificationVerificationFail(error:NSError) {
        NSNotificationCenter
            .defaultCenter()
            .postNotificationName(Notifications.VerificationFail, object: nil, userInfo: ["error":error] as [NSObject : AnyObject])
    }
    
    private func sendNotificationTokenRefreshed() {
        NSNotificationCenter
            .defaultCenter()
            .postNotificationName(Notifications.TokenRefreshed, object: nil, userInfo: nil)
    }
    
    private func sendNotificationAppName() {
        NSNotificationCenter
            .defaultCenter()
            .postNotificationName(Notifications.AppNameUpdated, object: nil, userInfo:nil)
    }
    
    // MARK  - Networking internals
    
    private func requestWithMethod(method: String, endpoint:String, queryParams: [String: String]? = nil, bodyParams: Dictionary<String,AnyObject>? = nil, headers:[String: String]?=nil, completion: NetworkingCompletion) {
        
        let URL = NSURL(string: endpoint, relativeToURL: self.apiBaseURL)!
        
        let request = NSURLRequest.requestWithURL(URL, method: method, queryParams: queryParams, bodyParams: bodyParams, headers: headers)
        
        let task:NSURLSessionDataTask! = urlSession.dataTaskWithRequest(request) { data, response, sessionError in
            
            var error = sessionError
            
            var wrappedResponse = Response(response: response, data: data, error: error)
            
            if let httpResponse = response as? NSHTTPURLResponse {
                if httpResponse.statusCode < 200 || httpResponse.statusCode >= 300 {
                    
                    if let message = (wrappedResponse.responseJSON as? NSDictionary)?.objectForKey("message") as? String {
                        error = NSError(domain: "Custom", code: 0, userInfo: [NSLocalizedDescriptionKey: message])
                    }else{
                        let description = "HTTP response was \(httpResponse.statusCode)"
                        error = NSError(domain: "Custom", code: 0, userInfo: [NSLocalizedDescriptionKey: description])
                    }
                    wrappedResponse.error = error
                }
            }
            
            dispatch_async(dispatch_get_main_queue()) {
                
                print("Response as string: \(wrappedResponse.responseString)")
                
                completion(wrappedResponse)
            }
        }
        
        task.resume()
        
    }
    
    private func defaultHeaders() -> [String:String]{
        var headers:[String: String] = [:]
        if (self.token != nil) {
            headers = [ HttpHeaderName.Authorization :"Bearer \(self.token!.accessToken!)"]
        }
        return headers
    }
    
    private func get(endpoint:String, params: [String: String]? = nil, completion: NetworkingCompletion) {
        let headers:[String: String]? = defaultHeaders()
        
        requestWithMethod(HttpMethod.Get, endpoint:endpoint, queryParams: params, headers: headers, completion: completion)
    }
    
    private func post(endpoint:String, params: Dictionary<String,AnyObject>? = nil, completion: NetworkingCompletion) {
        
        var headers = defaultHeaders()
        
        headers[HttpHeaderName.ContentType] = HttpHeaderValue.FormEncoded
        
        requestWithMethod(HttpMethod.Post, endpoint:endpoint, bodyParams: params, headers: headers, completion: completion)
    }
    
    private func postJSON(endpoint:String, params: Dictionary<String,AnyObject>? = nil, completion: NetworkingCompletion) {
        
        var headers = defaultHeaders()
        
        headers[HttpHeaderName.ContentType] = HttpHeaderValue.JsonEncoded
        
        requestWithMethod(HttpMethod.Post, endpoint:endpoint, bodyParams: params, headers: headers, completion: completion)
    }
    
}


