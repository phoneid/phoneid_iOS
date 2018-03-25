//
//  PhoneIdService.swift
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



import UIKit
import libPhoneNumber_iOS


public typealias RequestCompletion = (_ error:NSError?) -> Void
public typealias UserInfoRequestCompletion = (_ userInfo:UserInfo?,_ error:NSError?) -> Void
public typealias TokenRequestCompletion = (_ token:TokenInfo?,_ error:NSError?) -> Void
public typealias ContactsUpdateRequestCompletion = (_ numberOfUpdatedContacts:NSInteger,_ error:NSError?) -> Void
public typealias PhoneNumberHintCompletion = (_ phoneNumber:String?, _ error:NSError?) -> Void

public typealias PhoneIdAuthenticationSucceed = (_ token:TokenInfo) -> Void
public typealias PhoneIdWorkflowErrorHappened = (_ error:NSError) -> Void
public typealias PhoneIdAuthenticationCancelled = () -> Void

public typealias PhoneIdWorkflowNumberInputCompleted = (_ numberInfo:NumberInfo) -> Void
public typealias PhoneIdWorkflowVerificationCodeInputCompleted = (_ verificationCode:String) -> Void
public typealias PhoneIdWorkflowCountryCodeSelected = (_ countryCode:String) -> Void

open class PhoneIdService: NSObject {
    
    @objc open class var sharedInstance: PhoneIdService {
        struct Static { static let instance: PhoneIdService = PhoneIdService() }
        return Static.instance
    }
    
    @objc open var componentFactory:ComponentFactory!
    @objc open var phoneIdAuthenticationSucceed: PhoneIdAuthenticationSucceed?
    @objc open var phoneIdAuthenticationCancelled: PhoneIdAuthenticationCancelled?
    @objc open var phoneIdAuthenticationRefreshed: PhoneIdAuthenticationSucceed?
    @objc open var phoneIdWorkflowErrorHappened: PhoneIdWorkflowErrorHappened?
        
    @objc open var phoneIdWorkflowNumberInputCompleted:PhoneIdWorkflowNumberInputCompleted?
    @objc open var phoneIdWorkflowVerificationCodeInputCompleted:PhoneIdWorkflowVerificationCodeInputCompleted?
    @objc open var phoneIdWorkflowCountryCodeSelected:PhoneIdWorkflowCountryCodeSelected?

    
    @objc open var phoneIdDidLogout:(() -> Void)?
    @objc open var phoneIdDidGotPhoneNumberHint:((String) -> Void)?
    
    @objc open var isLoggedIn: Bool {
        get {
            return token != nil ? self.token!.isValid() : false
        }
    }
    
    @objc open var token: TokenInfo? {
        get {
            return TokenInfo.loadFromKeyChain()
        }
    }
    
    @objc open internal(set) var appName: String?
    @objc open internal(set) var clientId: String?
    @objc open internal(set) var autorefreshToken: Bool = true
    @objc internal var sessionCode:String?
    @objc internal var sessionId:String?
    @objc open internal(set) var phoneNumberHint:String? {
        didSet{
            if let number = self.phoneNumberHint {
                phoneIdDidGotPhoneNumberHint?(number)
            }
        }
    }
    internal var phoneNumberHintParsed:NumberInfo? {
        var result:NumberInfo?
        if let hint = phoneNumberHint {
            let number = hint.replacingOccurrences(of: "_", with: "0")
            let parsed = NumberInfo(numberE164:number)
            if let countryCode = parsed.phoneCountryCode {
                parsed.phoneNumber = hint.replacingOccurrences(of: "_", with: "").replacingOccurrences(of:countryCode, with: "")
            }
            result = parsed
            
        }
        return result
         
    }
    
    internal var urlSession: URLSession!;
    internal var refreshMonitor: PhoneIdRefreshMonitor!;
    
    fileprivate var contactsLoader:ContactsLoader!
    fileprivate var apiBaseURL:URL!
    fileprivate var phoneUtil: NBPhoneNumberUtil {return NBPhoneNumberUtil.sharedInstance()}
    
    override init(){
        super.init()
        componentFactory = DefaultComponentFactory()
        contactsLoader = ContactsLoader()
        let configuration = URLSessionConfiguration.default
        configuration.urlCache = URLCache(memoryCapacity: 0, diskCapacity: 0, diskPath: nil)
        urlSession = URLSession(configuration: configuration)
        apiBaseURL = Constants.baseURL as URL!
        
    }
    
    convenience init(baseURL:URL) {
        self.init()
        apiBaseURL = baseURL
    }
    
    @objc open func configureClient(_ id: String, autorefresh:Bool = true) {
        self.autorefreshToken = autorefresh
        self.clientId = id;
        self.sessionCode = nil
        
        if(autorefresh){
            refreshMonitor = PhoneIdRefreshMonitor(phoneIdService:self)
            if(self.isLoggedIn){
                refreshMonitor.start()
            }
        }
    }
    
    
    @objc open func logout() {
        
        self.refreshMonitor?.stop()
        self.token?.removeFromKeychain();
        self.sessionId = nil
        self.sessionCode = nil
        NotificationCenter.default
            .post(name: Notification.Name(rawValue: Notifications.DidLogout), object: nil, userInfo:nil)
        phoneIdDidLogout?()
    }
    
    // MARK: - API
    
    func tryResolveNumber(){
        self.requestAuthenticationCodeViaNetwork(completion: { (error) in
            if let sessionCode = self.sessionCode, let clientId = self.clientId, error==nil {
                self.requestPhoneNumberHint(sessionCode: sessionCode, clientId: clientId, { (phoneNumberHint, error) in
                    self.phoneNumberHint = phoneNumberHint
                })
            }
            // just ignore, we will fallback to sms/voice solution instead
        })
    }
    
    func loginOrRequestCodeViaSMS(_ info: NumberInfo, loggedIn:@escaping RequestCompletion, completion:@escaping RequestCompletion){
        if let sessionCode = sessionCode {
            
            self.tryLoginWithSessionCode(sessionCode: sessionCode, info:info, loggedIn:loggedIn , completion: completion)
        }else{
            self.requestAuthenticationCode(info, completion: completion)
        }
    }
    
    func tryLoginWithSessionCode(sessionCode:String, info:NumberInfo, loggedIn:@escaping RequestCompletion,  completion:@escaping RequestCompletion){
        
        self.verifyAuthentication(sessionCode: sessionCode, info: info){
            [unowned self] (token, error) -> Void in
            if self.isLoggedIn && error == nil{
                loggedIn(nil)
            }else {
                print("Failed to authenticate with session_code due to error:\(error)")
                //Fall back to request code:
                self.requestAuthenticationCode(info, completion: completion)
            }
        }
        
    }
    
    func requestAuthenticationCodeViaNetwork(completion:@escaping RequestCompletion){

        self._requestAuthenticationCode(nil, channel: .network, completion: completion)
    }
    
    func requestAuthenticationCode(_ info: NumberInfo, channel:AuthChannels = .sms, completion:@escaping RequestCompletion){
        self._requestAuthenticationCode(info, channel: channel, completion: completion)
    }
    
    fileprivate func _requestAuthenticationCode(_ info: NumberInfo?, channel:AuthChannels, completion:@escaping RequestCompletion) {
        
        let sessionId = self.sessionId ?? UUID().uuidString
        var params = ["channel":channel.value, "session_id":sessionId]
        
        if let info = info {
            
            let validation = info.isValid()
            guard validation.result else{
                completion(validation.error);
                self.notifyClientCodeAboutError(validation.error)
                return
            }
            
            let number = info.e164Format()!
            
            params["number"] = number
        }
        
        guard let clientId = clientId else{
            let error = PhoneIdServiceError.requestFailedError("error.failed.to.request.authentication", reasonKey:"error.client.id.not.found")
            completion(error);
            self.notifyClientCodeAboutError(error)
            return
        }
        params["client_id"] = clientId
        
        if let lang = (Locale.current as NSLocale).object(forKey: NSLocale.Key.languageCode) as? String{
          params["lang"] = Locale.canonicalLanguageIdentifier(from: lang)
        }

        self.post(Endpoints.requestCode.endpoint(), params:params as Dictionary<String, AnyObject>?, completion: { response in
            
            var error:NSError?=nil
            if let responseError = response.error {
                print("Failed to request PhoneId authentication code due to \(responseError))")
                error = PhoneIdServiceError.requestFailedError("error.failed.request.auth.code", reasonKey:responseError.localizedDescription)
                
            }else if let info = response.responseJSON as? NSDictionary{
                let responseCode = info["result"] as? Int
                let sessionCode = info["session_code"] as? String
                self.sessionId = sessionId
                
                if(responseCode==0){
                    print("Request authentication code success:\(String(describing: responseCode)), info: \(info)")
                } else if sessionCode != nil {
                    self.sessionCode = sessionCode
                    print("Have got sessionCode:\(String(describing: sessionCode)), info: \(info)")
                    
                } else {
                    let message = "No request success marker in response \(String(describing: response.responseJSON))"
                    print(message)
                    error = PhoneIdServiceError.requestFailedError("error.unexpected.response", reasonKey: "error.reason.auth.unexpected.response")
                }
            }
            
            completion(error)
            self.notifyClientCodeAboutError(error)
        })
        
    }
    
    @objc open func requestPhoneNumberHint(sessionCode:String, clientId:String,_ completion:@escaping PhoneNumberHintCompletion) {
        
        let endpoint: String = Endpoints.requestPhoneNumberHint.endpoint()
        let params = ["session_code":sessionCode, "client_id":clientId]
        self.get(endpoint, params: params) { response in
            
            var error:NSError?
            var phoneNumber:String?
            if let responseError = response.error {
                print("Failed to get phone_number hint due to %@", responseError)
                error = PhoneIdServiceError.requestFailedError("error.failed.request.user.info", reasonKey: responseError.localizedDescription)
                
            }else if let result = response.responseJSON as? [String:String] {
                phoneNumber = result["phoneNumber"]
            }else{
                error = PhoneIdServiceError.inappropriateResponseError("error.user.info.unexpected.response", reasonKey:"error.reason.user.info.unexpected.response")
            }
            
            completion(phoneNumber, error)
        }
    }

    func verifyAuthentication(sessionCode: String, info: NumberInfo, completion:@escaping TokenRequestCompletion) {
        self.verifyAuthentication(nil, sessionCode: sessionCode, info: info, completion: completion)
    }
    
    func verifyAuthentication(verifyCode: String, info: NumberInfo, completion:@escaping TokenRequestCompletion) {
        self.verifyAuthentication(verifyCode, sessionCode: nil, info: info, completion: completion)
    }
    
    private func verifyAuthentication(_ verifyCode: String?, sessionCode:String?, info: NumberInfo, completion:@escaping TokenRequestCompletion) {
        
        let validation = info.isValid()
        guard validation.result else{
            completion(nil, validation.error);
            self.notifyClientCodeAboutError(validation.error)
            return
        }
        
        if let number: String = info.e164Format(){
            
            var params: Dictionary<String, AnyObject> = [:]
            
            if let verifyCode = verifyCode {
                params["grant_type"] = "password" as AnyObject?
                
                params["password"] = verifyCode as AnyObject?
            }
        
            if let sessionCode = sessionCode {
                params["grant_type"] = "network" as AnyObject?
                params["session_code"] = sessionCode as AnyObject?
                params["number"] = number as AnyObject?
            }
            
            params["username"] = number as AnyObject?
            
            if let sessionId = self.sessionId {
                params["session_id"] = sessionId as AnyObject?
            }
            if let clientId = clientId {
                params["client_id"] = clientId as AnyObject?
            }
            
            
            print("request params: \(params)")
            
            self.post(Endpoints.requestToken.endpoint(), params:params) { response in
                
                var error:NSError?
                var token:TokenInfo?
                
                if let responseError = response.error {
                    print("Failed to verify code %@", responseError)
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
                
                completion(token, error)
                self.notifyClientCodeAboutError(error)
            }
        }
    }
    
    func doOnAuthenticationSucceed(_ token:TokenInfo){
        token.saveToKeychain()
        
        if(self.autorefreshToken){
            self.refreshMonitor?.start()
        }
        
        self.sendNotificationVerificationSuccess()
    }
    
    @objc open func loadMyProfile(_ completion:@escaping UserInfoRequestCompletion) {
        
        let endpoint: String = Endpoints.requestMe.endpoint()
        self.get(endpoint, params: nil) { response in
            
            var error:NSError?
            var userInfo:UserInfo?
            
            if let responseError = response.error {
                print("Failed to obtain user info due to %@", responseError)
                error = PhoneIdServiceError.requestFailedError("error.failed.request.user.info", reasonKey: responseError.localizedDescription)
                
            }else if let resultUserInfo = UserInfo.parse(response){
                userInfo = resultUserInfo
            }else{
                error = PhoneIdServiceError.inappropriateResponseError("error.user.info.unexpected.response", reasonKey:"error.reason.user.info.unexpected.response")
            }
            
            completion(userInfo , error)
            self.notifyClientCodeAboutError(error)
        }
    }
    
    
    
    @objc open func updateUserProfile(_ userInfo:UserInfo, completion:@escaping RequestCompletion){
        let endpoint: String = Endpoints.requestMe.endpoint()
        
        self.post(endpoint, params: userInfo.asDictionary() as Dictionary<String, AnyObject>?) { (response) -> Void in
            var error:NSError?
            if let responseError = response.error {
                print("Failed to update user info due to %@", responseError)
                error = PhoneIdServiceError.requestFailedError("error.failed.update.user.info", reasonKey: responseError.localizedDescription)
                completion(error)
                self.notifyClientCodeAboutError(error)
            }else if let image  = userInfo.updatedImage{                
                self.updateUserAvatar(image, completion: { (error) -> Void in
                    completion(error)
                    self.notifyClientCodeAboutError(error)
                })
            }else{
                completion(error)
                self.notifyClientCodeAboutError(error)
            }
            

        }
    }
    
    @objc open func updateUserAvatar(_ image:UIImage, completion:@escaping RequestCompletion){
        let endpoint: String = Endpoints.uploadAvatar.endpoint()
        
        var params: Dictionary<String, AnyObject> = [:]
        
        params["uploadfile"] = image
        self.post(endpoint, params:params) { (response) -> Void in
            completion(response.error)
        }
    }
    
    
    func loadClients(_ clientId:String, completion:@escaping RequestCompletion){
        
        let endpoint: String = Endpoints.clientsList.endpoint(clientId)
        self.get(endpoint, params:nil, completion: { response in
            
            var resultError:NSError? = nil
            if let error = response.error{
                print("Failed to obtain list of PhoneId clients due to \(error)")
                resultError = PhoneIdServiceError.requestFailedError("error.failed.request.clients", reasonKey: error.localizedDescription)
                
            }else if let info = response.responseJSON as? NSDictionary, let appName = info["appName"] as? String {
                self.appName = appName
                self.sendNotificationAppName()
                
            }else{
                print("Failed to parse appName in response \(String(describing: response.responseJSON))")
                resultError = PhoneIdServiceError.inappropriateResponseError("error.unexpected.response", reasonKey: "error.reason.clients.unexpected.response")
            }
            completion(resultError)
            self.notifyClientCodeAboutError(resultError)
        })
        
    }
    
    @objc open func refreshToken(_ completion:@escaping TokenRequestCompletion){
        
        self.checkToken("error.failed.refresh.token", success: { [unowned self] (token) -> Void in
            
            var params: Dictionary<String, AnyObject> = [:]
            params["grant_type"]="refresh_token" as AnyObject?
            params["client_id"]=self.clientId! as AnyObject?
            params["refresh_token"]=token.refreshToken as AnyObject?
            
            print("request params: \(params)")
            
            
            self.post(Endpoints.requestToken.endpoint(), params:params, completion: { response in
                
                var error:NSError?
                var token:TokenInfo?
                
                if let responseError = response.error{
                    print("Failed refresh token \(responseError)")
                    error = PhoneIdServiceError.requestFailedError("error.failed.refresh.token", reasonKey: responseError.localizedDescription)
                    
                }else if let refreshedToken = TokenInfo.parse(response) {
                    token = refreshedToken
                    self.doOnAuthenticationRefreshSucceed(refreshedToken)
                }else{
                    print("Failed to parse token in response \(String(describing: response.responseJSON))")
                    error = PhoneIdServiceError.inappropriateResponseError("error.unexpected.response", reasonKey: "error.reason.response.does.not.contain.valid.token.info")
                }
                
                completion(token, error)
                self.notifyClientCodeAboutError(error)
            })
            
            }, fail: {(error) -> Void in
                
                completion(nil, error)
                
        })
    }
    
    @objc open func uploadContacts(debugMode:Bool = false, completion:@escaping ContactsUpdateRequestCompletion){
        
        self.checkToken("error.failed.refresh.token", success: { [unowned self] (token) -> Void in
            
            self.contactsLoader.getContacts(token.numberInfo!.isoCountryCode!) { (contacts:[ContactInfo]?) -> Void in
                
                if let contacts = contacts{
                    
                    self.updateContactsIfNeeded(contacts, debugMode:debugMode, completion:completion)
                    
                }else{
                    completion(0, nil)
                }
            }
            
            }, fail: { (error) -> Void in
                completion(0, nil)
        })
        
    }
    
    internal func needsUpdateContacts(_ contacts:[ContactInfo], completion:@escaping (_ needsUpdate:Bool)->Void){
        
        let checksums:[String] = contacts.map({ return $0.number!.sha1()})
        
        let checksumFlat = checksums.sorted().joined(separator: ",")
        
        let endpoint = Endpoints.needRefreshContacts.endpoint(checksumFlat.sha1())
        
        self.get(endpoint, params: nil, completion: { (response) -> Void in
            
            var result:Bool = true
            
            if let json = response.responseJSON as? NSDictionary,
                let needsUpdate = json["refresh_needed"] as? Bool{
                    
                    result = needsUpdate
            }
            
            completion(result)
        })
    }
    
    internal func updateContactsIfNeeded(_ contacts:[ContactInfo], debugMode:Bool, completion:@escaping ContactsUpdateRequestCompletion){
        
        self.needsUpdateContacts(contacts, completion: { (needsUpdate) -> Void in
            
            if(needsUpdate){
                
                let params = self.wrapContactsAsHTTPFormParams(contacts, debugMode:debugMode)
                
                let endpoint = Endpoints.contacts.endpoint()
                
                self.post(endpoint, params: params, completion: { (response) -> Void in
                    var error:NSError?
                    var numberOfUpdatedContacts = 0
                    if let responseError = response.error{
                        print("Failed to upload contacts \(responseError)")
                        error = PhoneIdServiceError.requestFailedError("error.failed.to.upload.contacts", reasonKey: responseError.localizedDescription)
                        
                    }else if let json = response.responseJSON as? NSDictionary, let number = json["received"] as? NSInteger{
                        numberOfUpdatedContacts = number
                    }
                    
                    completion(numberOfUpdatedContacts, error)
                    
                    self.notifyClientCodeAboutError(error)
                    
                })
                
            }else{
                completion(0, nil)
            }
            
        })
    }
    
    
    fileprivate func wrapContactsAsHTTPFormParams(_ contacts:[ContactInfo], debugMode:Bool) -> [String:AnyObject]{
        
        let contactsDictionary = contacts.map({ return debugMode ? $0.asDebugDictionary() : $0.asDictionary() })
        
        let serialized = try! JSONSerialization.data(withJSONObject: ["contacts": contactsDictionary], options: [.prettyPrinted])
        
        let serializedAsString = String(data: serialized, encoding: String.Encoding.utf8)

        return ["contacts":serializedAsString as AnyObject]
    }
    
    fileprivate func checkToken(_ errorKey:String, success:(_ token:TokenInfo)->Void, fail:(_ error:PhoneIdServiceError)->Void){
        
        if let currentToken = self.token{
            success(currentToken)
        }else{
            let error = PhoneIdServiceError.requestFailedError(errorKey, reasonKey:"error.unautorized.request")
            fail(error)
            self.notifyClientCodeAboutError(error)
        }
    }
    
    func doOnAuthenticationRefreshSucceed(_ token:TokenInfo){
        token.saveToKeychain()
        self.phoneIdAuthenticationRefreshed?(token)
        self.sendNotificationTokenRefreshed()
    }
    
    func abortCall() {
        
        urlSession.getTasksWithCompletionHandler({
            (dataTasks, uploadTasks, downloadTasks) -> Void in
            let tasksLists:[[URLSessionTask]] = [dataTasks, uploadTasks, downloadTasks]
            for tasksList: [URLSessionTask] in tasksLists {
                for task in tasksList {
                    task.cancel();
                }
            }
        });
    }
    
    
    // MARK: - NOTIFICATIONS / CALLBACKS for client code
    func notifyClientCodeAboutError(_ error:NSError?){
        if(error != nil){
            self.phoneIdWorkflowErrorHappened?(error!)
        }
    }
    
    
    // MARK: - NOTIFICATIONS / CALLBACKS internal
    
    fileprivate func sendNotificationVerificationSuccess() {
        NotificationCenter.default
            .post(name: Notification.Name(rawValue: Notifications.VerificationSuccess), object: nil, userInfo:nil)
    }
    
    fileprivate func sendNotificationVerificationFail(_ error:NSError) {
        NotificationCenter.default
            .post(name: Notification.Name(rawValue: Notifications.VerificationFail), object: nil, userInfo: ["error":error] as [AnyHashable: Any])
    }
    
    fileprivate func sendNotificationTokenRefreshed() {
        NotificationCenter.default
            .post(name: Notification.Name(rawValue: Notifications.TokenRefreshed), object: nil, userInfo: nil)
    }
    
    fileprivate func sendNotificationAppName() {
        NotificationCenter.default
            .post(name: Notification.Name(rawValue: Notifications.AppNameUpdated), object: nil, userInfo:nil)
    }
    
    // MARK  - Networking internals
    
    fileprivate func requestWithMethod(_ method: String, endpoint:String, queryParams: [String: String]? = nil, bodyParams: Dictionary<String,AnyObject>? = nil, headers:[String: String]?=nil, completion: @escaping NetworkingCompletion) {
        
        let URL = Foundation.URL(string: endpoint, relativeTo: self.apiBaseURL)!
        
        let request = URLRequest.requestWithURL(URL, method: method, queryParams: queryParams, bodyParams: bodyParams, headers: headers)
        
        let task:URLSessionDataTask! = urlSession.dataTask(with: request, completionHandler: { data, response, sessionError in
            
            var error = sessionError
            
            var wrappedResponse = Response(response: response, data: data, error: error as NSError?)
            
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode < 200 || httpResponse.statusCode >= 400 {
                    
                    if let message = (wrappedResponse.responseJSON as? NSDictionary)?.object(forKey: "message") as? String {
                        error = NSError(domain: "Custom", code: 0, userInfo: [NSLocalizedDescriptionKey: message])
                    }else{
                        let description = "HTTP response was \(httpResponse.statusCode)"
                        error = NSError(domain: "Custom", code: 0, userInfo: [NSLocalizedDescriptionKey: description])
                    }
                    wrappedResponse.error = error as NSError?
                }
            }
            
            DispatchQueue.main.async {
                
                print("Response as string: \(String(describing: wrappedResponse.responseString))")
                
                completion(wrappedResponse)
            }
        }) 
       
        task.resume()
        
    }
    
    fileprivate func defaultHeaders() -> [String:String]{
        var headers:[String: String] = [:]
        if (self.token != nil) {
            headers = [ HttpHeaderName.Authorization :"Bearer \(self.token!.accessToken!)"]
        }
        return headers
    }
    
    fileprivate func get(_ endpoint:String, params: [String: String]? = nil, completion: @escaping NetworkingCompletion) {
        let headers:[String: String]? = defaultHeaders()
        
        requestWithMethod(HttpMethod.Get, endpoint:endpoint, queryParams: params, headers: headers, completion: completion)
    }
    
    fileprivate func post(_ endpoint:String, params: Dictionary<String,AnyObject>? = nil, completion: @escaping NetworkingCompletion) {
        
        var headers = defaultHeaders()
        
        headers[HttpHeaderName.ContentType] = HttpHeaderValue.FormEncoded
        
        requestWithMethod(HttpMethod.Post, endpoint:endpoint, bodyParams: params, headers: headers, completion: completion)
    }
    
    fileprivate func postJSON(_ endpoint:String, params: Dictionary<String,AnyObject>? = nil, completion: @escaping NetworkingCompletion) {
        
        var headers = defaultHeaders()
        
        headers[HttpHeaderName.ContentType] = HttpHeaderValue.JsonEncoded
        
        requestWithMethod(HttpMethod.Post, endpoint:endpoint, bodyParams: params, headers: headers, completion: completion)
    }
    
}


