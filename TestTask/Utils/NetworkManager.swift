//
//  NetworkManager.swift
//  TestTask
//
//  Created by Bobby numdevios on 23.05.2018.
//  Copyright © 2018 kinectpro. All rights reserved.
//

import Foundation
import Alamofire
import ObjectMapper

class NetworkManager {
    
    enum Urls:String {
        case register = "/create"
        case login = "/login"
    }
    
    static let shared = NetworkManager()
    let apiURL:String="http://api.doitserver.in.ua"
    
    func register(username:String?, email:String?, password:String?, avatar:Data?, success:@escaping () -> Void, fail:@escaping(_ errorMessage:String) -> Void ) {
        let requestURL:String=apiURL+Urls.register.rawValue
        
        let params = ["username" : username!,
                      "email":email!,
                      "password":password!] as [String : Any]
        
        Alamofire.upload(multipartFormData: {(multipartFormData) in
            
            multipartFormData.append(avatar!, withName: "avatar", fileName: "file.png", mimeType: "image/png")
            
            for (key, value) in params {
                
                multipartFormData.append(((value as? String)?.data(using: String.Encoding.utf8))!, withName: key)
            }
        },to: requestURL,
            encodingCompletion: { encodingResult in
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.responseJSON { response in
                        if let status = response.response?.statusCode {
                            if((status<300)&&(status>=200)){
                                if let result = response.result.value {
                                    let JSON = result as! NSDictionary
                                    print(JSON)
                                    if let token = JSON.object(forKey: "token"){
                                        UserDefaults.standard.set(token, forKey: "token")
                                        if let avatar = JSON.object(forKey: "avatar"){
                                            UserDefaults.standard.set(avatar, forKey: "avatar")
                                        }
                                        UserDefaults.standard.synchronize()
                                        success()
                                    }else{
                                        if let errorMessage = JSON.object(forKey: "error") {
                                            fail(errorMessage as! String)
                                        }
                                    }
                                }else{
                                    fail("Empty server response")
                                }
                            }else if status == 400{
                                let JSON = response.result.value as! NSDictionary
                                let errorDict = JSON.object(forKey: "children") as! [String:Any]
                                for item in errorDict.values {
                                    let value = item as! [String:Any]
                                    if let error = value.keys.first, error == "errors"{
                                        fail((value["errors"] as! [String]).first!)
                                    }else{
                                        fail("Wrong data!")
                                    }
                                }
                            }
                    }
                    }
                case .failure(let encodingError):
                    fail(encodingError.localizedDescription)
                }
            }
        )
    }
    
    func signIn(email:String?, password:String?, success:@escaping () -> Void, fail:@escaping(_ errorMessage:String) -> Void ) {
        let requestURL:String=apiURL+Urls.login.rawValue
        let params =  ["email":email!,"password":password!]
        
        Alamofire.request(requestURL, method: HTTPMethod.post, parameters: params, encoding: JSONEncoding.default, headers: [:]).responseJSON { response in
            if let status = response.response?.statusCode {
                if((status<300)&&(status>=200)){
                    if let result = response.result.value {
                        let JSON = result as! NSDictionary
                        print(JSON)
                        if let token = JSON.object(forKey: "token"){
                            UserDefaults.standard.set(token, forKey: "token")
                            if let avatar = JSON.object(forKey: "avatar"){
                                UserDefaults.standard.set(avatar, forKey: "avatar")
                            }
                            UserDefaults.standard.synchronize()
                            success()
                        }else{
                            if let errorMessage = JSON.object(forKey: "error") {
                                fail(errorMessage as! String)
                            }
                        }
                        
                    }else{
                        fail("Empty server response")
                    }
                }
                else if status == 400{
                    fail("Incorrect email or password!")
                }
            }else{
                fail("Is not succeed")
            }
        }
    }
}
