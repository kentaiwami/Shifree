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


class API {
    let base = "http://127.0.0.1:5000/api/"
    let version: String
    let endPoint: String
    
    init(version: String, endPoint: String) {
        self.version = version + "/"
        self.endPoint = endPoint
    }
    
    func SignUp(companyCode: String, userCode: String, userName: String, password: String) -> Promise<JSON> {
        let params = [
            "company_code": companyCode,
            "user_code": userCode,
            "username": userName,
            "password": password
            ] as [String : Any]
        let urlString = base + version + endPoint
        
        let promise = Promise<JSON> { seal in
            Alamofire.request(urlString, method: .post, parameters: params, encoding: JSONEncoding(options: [])).responseJSON { (response) in
                guard let obj = response.result.value else { return seal.reject(response.error!)}
                let json = JSON(obj)
                
                if IsHTTPStatus(statusCode: response.response?.statusCode) {
                    print("***** SignUp API Results *****")
                    print(json)
                    print("***** SignUp API Results *****")
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
