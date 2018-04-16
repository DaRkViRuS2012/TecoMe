
//
//  ApiManager.swift
//
//  Created by Molham Mahmoud on 25/04/16.
//  Copyright © 2016. All rights reserved.
//

import SwiftyJSON
import Alamofire

/// - Api store do all Networking stuff
///     - build server request 
///     - prepare params
///     - and add requests headers
///     - parse Json response to App data models
///     - parse error code to Server error object
///


enum url {
    case login
    case invoke
    
    
    
    var process:String {
        switch self {
        case .login:
            return "login"
        case .invoke:
            return "invoke"
        }
    }
}


class ApiManager: NSObject {

    typealias Payload = (MultipartFormData) -> Void
    
    /// frequent request headers
    var headers: HTTPHeaders{
        get{
            let httpHeaders = [
                "Content-Type": "application/json; charset=utf-8"
            ]
            return httpHeaders
        }
    }
    

    let baseURL = "https://www.lutfi-co.com/smart/api/api.php"
    let iosbaseURL = "https://www.lutfi-co.com/smart/api/iosapi.php"
    
    //MARK: Shared Instance
    static let shared: ApiManager = ApiManager()
    
    private override init(){
        super.init()
    }    
   
    // MARK: Authorization

    /// User login request
    func userLogin(email: String, password: String, completionBlock: @escaping (_ success: Bool, _ error: ServerError?, _ user:AppUser?) -> Void) {
        // url & parameters
        let signInURL = "\(baseURL)"
        let parameters : [String : Any] = [
            "process":url.login.process,
            "username": email,
            "password": password,
             "device" :"ios"
        ]
        print(parameters)
        // build request
        Alamofire.request(signInURL, method: .post, parameters: parameters ).responseString { (responseObject) -> Void in
            print(responseObject)
            if responseObject.result.isSuccess {
               
                let jsonResponse = JSON(responseObject.result.value!)
                print(jsonResponse)
                if let code = responseObject.response?.statusCode, code >= 400 {
                    let serverError = ServerError(json: jsonResponse) ?? ServerError.unknownError
                    completionBlock(false , serverError, nil)
                } else {
                    // parse response to data model >> user object
                    if let dic = jsonResponse.rawString()?.data(using: String.Encoding.utf8){
                        let json = JSON(dic)
                    if let code = json["success"].int ,code == 10{
                        let user = AppUser(json: json)
                        DataStore.shared.me = user
                        completionBlock(true , nil, user)
                        
                    }else{
                        
                        let serverError = ServerError(json: jsonResponse) ?? ServerError.unknownError
                        completionBlock(false , serverError, nil)
                        
                        }
                        
                    }
                }
            }
            // Network error request time out or server error with no payload
            if responseObject.result.isFailure {
                 if let code = responseObject.response?.statusCode, code >= 400 {
                    completionBlock(false, ServerError.unknownError, nil)
                 } else {
                    completionBlock(false, ServerError.connectionError, nil)
                }
            }
        }
    }
    
    /// User Signup request
    func userSignup(user: AppUser, password: String, completionBlock: @escaping (_ success: Bool, _ error: ServerError?, _ user:AppUser?) -> Void) {
        // url & parameters
        guard password.length>0,
            let _ = user.email
            else {
                return
        }
        
        let signUpURL = "\(baseURL)/accounts"
        
        let parameters : [String : Any] = [
            "name": user.fullName!,
            "email": user.email!,
            "password": password,
            "device" :"ios"
            
        ]
        
        print(parameters)
        // build request
        Alamofire.request(signUpURL, method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { (responseObject) -> Void in
            print(responseObject)
            if responseObject.result.isSuccess {
                
                let jsonResponse = JSON(responseObject.result.value!)
                if let code = responseObject.response?.statusCode, code >= 400 {
                    let serverError = ServerError(json: jsonResponse) ?? ServerError.unknownError
                    completionBlock(false , serverError, nil)
                } else {
                    // parse response to data model >> user object
                    let user = AppUser(json: jsonResponse)
                    DataStore.shared.me = user
                    completionBlock(true , nil, user)
                }
            }
            // Network error request time out or server error with no payload
            if responseObject.result.isFailure {
                if let code = responseObject.response?.statusCode, code >= 400 {
                    let jsonResponse = JSON(responseObject.result.value!)
                    completionBlock(false, ServerError(json: jsonResponse) ?? ServerError.unknownError, nil)
                } else {
                    completionBlock(false, ServerError.connectionError, nil)
                }
            }
        }
    }
    
    
    
    // handle invoke
    
    /// User login request
    func invoke(userId: String, words: String, completionBlock: @escaping (_ success: Bool, _ error: ServerError?, _ result:[Command]) -> Void) {
        // url & parameters
        
        
        let signInURL = "\(iosbaseURL)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        
        
        let parameters : [String : String] = [
            "process":url.invoke.process,
            "userId": userId,
            "words": words,
            "lang"  : AppConfig.langCode
        ]
        print(parameters)
        var request1 = URLRequest(url: URL(string: signInURL!)!)
        request1.httpMethod = "POST"
        
    // start of do
        do{
        
        var request = try URLEncoding().encode(request1, with: parameters)
        let httpBody = NSString(data: request.httpBody!, encoding: String.Encoding.utf8.rawValue)!
        request.httpBody = httpBody.replacingOccurrences(of: "%5B%5D=", with: "=").data(using: .utf8)
       // request1.setValue("charset=utf-8", forHTTPHeaderField: "Content-Type")
       // request1.httpBody = try! JSONSerialization.data(withJSONObject: parameters)
      
//        do {
//             Alamofire.ParameterEncoding.encode(.)
//            let alamofireRequest = try Alamofire.URLEncoding().encode(request1 as URLRequestConvertible, with: parameters)
//            Alamofire.request(alamofireRequest).responseString  { (responseObject) -> Void in
//                print(responseObject)
//                if responseObject.result.isSuccess {
//                    let jsonResponse = JSON(responseObject.result.value!)
//                    print(jsonResponse)
//                    if let code = responseObject.response?.statusCode, code >= 400 {
//                        let serverError = ServerError(json: jsonResponse) ?? ServerError.unknownError
//                        completionBlock(false , serverError, [])
//                    } else {
//                        // parse response to data model >> user object
//                        if let dic = jsonResponse.rawString()?.data(using: String.Encoding.utf8){
//                            let json = JSON(dic)
//                            if let code = json["success"].int ,code == 10{
//                                var result:[Command] = []
//                                if let array = json["commands"].array{
//
//                                    result = array.map{Command(json:$0)}
//                                }
//
//                                completionBlock(true , nil,result)
//
//
//                            }else{
//
//                                let serverError = ServerError(json: jsonResponse) ?? ServerError.unknownError
//                                completionBlock(false , serverError, [])
//
//                            }
//
//                        }
//
//                    }
//                }
//                // Network error request time out or server error with no payload
//                if responseObject.result.isFailure {
//                    if let code = responseObject.response?.statusCode, code >= 400 {
//                        completionBlock(false, ServerError.unknownError, [])
//                    } else {
//                        completionBlock(false, ServerError.connectionError, [])
//                    }
//                }
//            }
//        } catch {
//
//        }
//
        
        // build request
        Alamofire.request(signInURL!,method:.post,parameters:parameters).responseString  { (responseObject) -> Void in
          //  Alamofire.request(request).responseString(encoding: String.Encoding.utf8)  { (responseObject) -> Void in
            print(responseObject)
            if responseObject.result.isSuccess {
                let jsonResponse = JSON(responseObject.result.value!)
                print(jsonResponse)
                if let code = responseObject.response?.statusCode, code >= 400 {
                    
                    let serverError = ServerError(json: jsonResponse) ?? ServerError.unknownError
                    completionBlock(false , serverError, [])
                } else {
                    // parse response to data model >> user object
                    if let dic = jsonResponse.rawString()?.data(using: String.Encoding.utf8){
                        let json = JSON(dic)
                    if let code = json["success"].int ,code == 10{
                        var result:[Command] = []
                        if let array = json["commands"].array{

                            result = array.map{Command(json:$0)}
                        }
                        

                        completionBlock(true , nil,result)


                    }else{

                        let serverError = ServerError(json: json) ?? ServerError.unknownError
                        completionBlock(false , serverError, [])

                        }

                    }

                }
            }
            // Network error request time out or server error with no payload
            if responseObject.result.isFailure {
                if let code = responseObject.response?.statusCode, code >= 400 {
                    completionBlock(false, ServerError.unknownError, [])
                } else {
                    completionBlock(false, ServerError.connectionError, [])
                }
            }
        }
            
            // end of Do
        }catch{
            print(error)
        }
    }
    

}


/**
 Server error represents custome errors types from back end
 */
struct ServerError {
    
    static let errorCodeConnection = 50
    
    public var errorName:String?
    public var status: Int?
    public var code:Int!
    public var message:String?
    
    public var type:ErrorType {
        get{
            return ErrorType(rawValue: code) ?? .unknown
        }
    }
    
    /// Server erros codes meaning according to backend
    enum ErrorType:Int {
        case connection = 50
        case unknown = -111
        case authorization = 900
        case alreadyExists = 422
        case socialLoginFailed = -110
		case notRegistred = 102
        case missingInputData = 104
        case expiredVerifyCode = 107
        case invalidVerifyCode = 108
        case userNotFound = 109
        case loginFaild = 401
        case userNotVerified = 403
        
        /// Handle generic error messages
        /// **Warning:** it is not localized string
        var errorMessage:String {
            switch(self) {
                case .unknown:
                    return "ERROR_UNKNOWN".localized
                case .connection:
                    return "ERROR_NO_CONNECTION".localized
                case .authorization:
                    return "ERROR_NOT_AUTHORIZED".localized
                case .alreadyExists:
                    return "ERROR_SIGNUP_EMAIL_EXISTS".localized
				case .notRegistred:
                    return "ERROR_SIGNIN_WRONG_CREDIST".localized
                case .missingInputData:
                    return "ERROR_MISSING_INPUT_DATA".localized
                case .expiredVerifyCode:
                    return "ERROR_EXPIRED_VERIFY_CODE".localized
                case .invalidVerifyCode:
                    return "ERROR_INVALID_VERIFY_CODE".localized
                case .userNotFound:
                    return "ERROR_RESET_WRONG_EMAIL".localized
                case .loginFaild:
                    return "ERROR_LOGIN_FAILD".localized
                case .userNotVerified:
                    return "ERROR_UNVERIFIED_EMAIL".localized
                default:
                    return "ERROR_UNKNOWN".localized
            }
        }
    }
    
    public static var connectionError: ServerError{
        get {
            var error = ServerError()
            error.code = ErrorType.connection.rawValue
            return error
        }
    }
    
    public static var unknownError: ServerError{
        get {
            var error = ServerError()
            error.code = ErrorType.unknown.rawValue
            return error
        }
    }
    
    public static var socialLoginError: ServerError{
        get {
            var error = ServerError()
            error.code = ErrorType.socialLoginFailed.rawValue
            return error
        }
    }
    
    public init() {
    }
    
    public init?(json: JSON) {
        guard let errorCode = json["success"].int else {
            return nil
        }
        code = errorCode
        if let errorString = json["name"].string{ errorName = errorString}
        if let statusCode = json["statusCode"].int{ status = statusCode}
        if let msg = json["message"].string{ message = msg }
    }
}


