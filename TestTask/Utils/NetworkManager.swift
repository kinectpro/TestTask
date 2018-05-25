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
    //c4d7a141d9fedb337e9c1d5200591f7d
    enum Urls:String {
        case register = "/create"
        case login = "/login"
        case all = "/all"
        case addImage = "/image"
        case gif = "/gif"
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
    
    func getAll( success:@escaping (_ data:[ImageModel]) -> Void, fail:@escaping(_ errorMessage:String) -> Void){
        guard let userToken = UserDefaults.standard.object(forKey: "token") else {return}
        let requestURL:String = apiURL+Urls.all.rawValue
        let headers: HTTPHeaders = [
            "token": userToken as! String,
            "Accept": "application/json"
        ]
        
        Alamofire.request(requestURL, headers: headers).responseJSON { response in
            if let status = response.response?.statusCode {
                if((status<300)&&(status>=200)){
                    if let result = response.result.value{
                        let JSON = result as! [String:Any]
                        print(result)
                        let JSONArray = JSON["images"] as! Array <[String:Any]>
                        let images = Mapper<ImageModel>().mapArray(JSONArray: JSONArray)
                        success(images)
                    }
                    else{
                        fail("Empty server response")
                    }
                }else if status == 403{
                    fail("Invalid access token")
                }
            }else{
                fail("Is not succeed")
            }
        }
    }
    
    func getGif(weather:String, success:@escaping (_ url:String) -> Void, fail:@escaping(_ errorMessage:String) -> Void){
        guard let userToken = UserDefaults.standard.object(forKey: "token") else {return}
        let requestURL:String = apiURL+Urls.gif.rawValue
        let headers: HTTPHeaders = [
            "token": userToken as! String,
            "Accept": "application/json"
        ]
        let params =  ["weather":weather]
        Alamofire.request(requestURL, parameters:params, headers: headers).responseJSON { response in
            if let status = response.response?.statusCode {
                if((status<300)&&(status>=200)){
                    if let result = response.result.value{
                        let JSON = result as! [String:Any]
                        print(JSON["gif"] as! String)
                        if let url = JSON["gif"]{
                            success(url as! String)
                        }
                    }
                    else{
                        fail("Empty server response")
                    }
                }else if status == 403{
                    fail("Invalid access token")
                }
            }else{
                fail("Is not succeed")
            }
        }
    }
    
    func saveImage(image:ItemModel?, success:@escaping () -> Void, fail:@escaping(_ errorMessage:String) -> Void ) {
        guard let userToken = UserDefaults.standard.object(forKey: "token") else {return}

        let requestURL:String = apiURL+Urls.addImage.rawValue
        
        let headers: HTTPHeaders = [
            "token": userToken as! String, //c4d7a141d9fedb337e9c1d5200591f7d
            "Accept": "application/json"
        ]
        let params = image?.toJSON()
        
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            for (key, value) in params! {
                multipartFormData.append(((value as? String)?.data(using: String.Encoding.utf8))!, withName: key)
            }
            multipartFormData.append((image?.image)!, withName: "image", fileName: "file.png", mimeType: "image/png")
        }, to:requestURL,  method : .post, headers:headers)
        { (result) in
            switch result {
            case .success(let upload, _, _):
                upload.responseJSON { response in
                    if let status = response.response?.statusCode {
                        if((status<300)&&(status>=200)){
                            if response.result.value != nil {
                                success()
                            }else{
                                fail("Empty server response")
                            }
                        }else if status == 400{
                            let JSON = response.result.value as! NSDictionary
                            print(JSON)
                            let errorDict = JSON.object(forKey: "children") as! [String:Any]
                            for item in errorDict.values {
                                let value = item as! [String:Any]
                                if let error = value.keys.first, error == "errors"{
                                    fail((value["errors"] as! [String]).first!)
                                }
                            }
                        }else if status == 403  {
                            let JSON = response.result.value as! NSDictionary
                            if let error = JSON["error"] {
                                print(error)
                                fail(error as! String)
                            }
                        }
                    }
                }
            case .failure(let encodingError):
                fail(encodingError.localizedDescription)
            }
            print(result)
        }
    }
}
