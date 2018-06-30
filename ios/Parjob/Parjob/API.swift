//
//  API.swift
//  Parjob
//
//  Created by 岩見建汰 on 2018/06/23.
//  Copyright © 2018年 Kenta Iwami. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import PromiseKit
import KeychainAccess


class API {
    let base = "http://127.0.0.1:5000/api/"
    let version = "v1/"
    let keychain = Keychain()
    
    fileprivate func postNoAuth(url: String, params: [String:Any]) -> Promise<JSON> {
        let promise = Promise<JSON> { seal in
            Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding(options: [])).responseJSON { (response) in
                guard let obj = response.result.value else { return seal.reject(response.error!)}
                let json = JSON(obj)

                if IsHTTPStatus(statusCode: response.response?.statusCode) {
                    print("***** POST No Auth API Results *****")
                    print(json)
                    print("***** POST No Auth API Results *****")
                    seal.fulfill(json)
                }else {
                    let err_msg = json["msg"].stringValue + "[" + String(json["code"].intValue) + "]"
                    seal.reject(NSError(domain: err_msg, code: (response.response?.statusCode)!))
                }
            }
        }
        return promise
    }
    
    fileprivate func getAuth(url: String) -> Promise<JSON> {
        let user = try! keychain.get("userCode")
        let password = try! keychain.get("password")
        
        let promise = Promise<JSON> { seal in
            Alamofire.request(url, method: .get).authenticate(user: user!, password: password!).responseJSON { (response) in
                guard let obj = response.result.value else { return seal.reject(response.error!)}
                let json = JSON(obj)
                
                if IsHTTPStatus(statusCode: response.response?.statusCode) {
                    print("***** GET Auth API Results *****")
                    print(json)
                    print("***** GET Auth API Results *****")
                    seal.fulfill(json)
                }else {
                    let err_msg = json["msg"].stringValue + "[" + String(json["code"].intValue) + "]"
                    seal.reject(NSError(domain: err_msg, code: (response.response?.statusCode)!))
                }
            }
        }
        return promise
    }
    
    fileprivate func postPutDeleteAuth(url: String, params: [String:Any], httpMethod: HTTPMethod) -> Promise<JSON> {
        let user = try! keychain.get("userCode")
        let password = try! keychain.get("password")
        
        let promise = Promise<JSON> { seal in
            Alamofire.request(url, method: httpMethod, parameters: params, encoding: JSONEncoding(options: [])).authenticate(user: user!, password: password!).responseJSON { (response) in
                guard let obj = response.result.value else { return seal.reject(response.error!)}
                let json = JSON(obj)
                
                if IsHTTPStatus(statusCode: response.response?.statusCode) {
                    print("***** " + httpMethod.rawValue + " Auth API Results *****")
                    print(json)
                    print("***** " + httpMethod.rawValue + " Auth API Results *****")
                    seal.fulfill(json)
                }else {
                    let err_msg = json["msg"].stringValue + "[" + String(json["code"].intValue) + "]"
                    seal.reject(NSError(domain: err_msg, code: (response.response?.statusCode)!))
                }
            }
        }
        return promise
    }
}

extension API {
    func signUp(params: [String:Any]) -> Promise<JSON> {
        let endPoint = "auth"
        return postNoAuth(url: base + version + endPoint, params: params)
    }
    
    func login() -> Promise<JSON> {
        let endPoint = "login"
        return getAuth(url: base + version + endPoint)
    }
    
    func getUserShift(start: String, end: String) -> Promise<JSON> {
        let endPoint = "usershift"
        let getQuery = "?start=" + start + "&end=" + end
        return getAuth(url: base + version + endPoint + getQuery)
    }
    
    func getUserCompanyShiftNames() -> Promise<JSON> {
        let endPoint = "shift"
        return getAuth(url: base + version + endPoint)
    }
    
    func updateMemo(userShiftID: Int, text: String) -> Promise<JSON> {
        let endPoint = "usershift/memo/" + String(userShiftID)
        let params = [
            "text": text
        ] as [String:Any]
        
        return postPutDeleteAuth(url: base + version + endPoint, params: params, httpMethod: .put)
    }
    
    func updateUserShift(shifts: [[String:Any]]) -> Promise<JSON> {
        let endPoint = "usershift"
        let params = [
            "shifts": shifts
            ] as [String:Any]
        
        return postPutDeleteAuth(url: base + version + endPoint, params: params, httpMethod: .put)
    }
}
