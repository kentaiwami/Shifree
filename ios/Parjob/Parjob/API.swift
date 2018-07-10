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
    let base = GetHost() + "api/"
    let version = "v1/"
    let keychain = Keychain()
    let indicator = Indicator()
    
    fileprivate func postNoAuth(url: String, params: [String:Any]) -> Promise<JSON> {
        indicator.start()
        
        let promise = Promise<JSON> { seal in
            Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding(options: [])).responseJSON { (response) in
                self.indicator.stop()
                
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
        indicator.start()
        
        let user = try! keychain.get("userCode")
        let password = try! keychain.get("password")
        
        let promise = Promise<JSON> { seal in
            Alamofire.request(url, method: .get).authenticate(user: user!, password: password!).responseJSON { (response) in
                self.indicator.stop()
                
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
        indicator.start()
        
        let user = try! keychain.get("userCode")
        let password = try! keychain.get("password")
        
        let promise = Promise<JSON> { seal in
            Alamofire.request(url, method: httpMethod, parameters: params, encoding: JSONEncoding(options: [])).authenticate(user: user!, password: password!).responseJSON { (response) in
                self.indicator.stop()
                
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


// MARK: - Auth Login API
extension API {
    func signUp(params: [String:Any]) -> Promise<JSON> {
        let endPoint = "auth"
        return postNoAuth(url: base + version + endPoint, params: params)
    }
    
    func login() -> Promise<JSON> {
        let endPoint = "login"
        return getAuth(url: base + version + endPoint)
    }
}



// MARK: - Company API
extension API {
    func getThreshold() -> Promise<JSON> {
        let endPoint = "company"
        return getAuth(url: base + version + endPoint)
    }
}



// MARK: - Comment API
extension API {
    func updateComment(text: String, id: Int) -> Promise<JSON> {
        let endPoint = "comment/" + String(id)
        let params = ["text": text] as [String:Any]
        return postPutDeleteAuth(url: base + version + endPoint, params: params, httpMethod: .put)
    }
    
    func addComment(text: String, id: Int) -> Promise<JSON> {
        let endPoint = "comment"
        let params = [
            "text": text,
            "table_id": id
            ] as [String:Any]
        return postPutDeleteAuth(url: base + version + endPoint, params: params, httpMethod: .post)
    }
}



// MARK: - UserShift API
extension API {
    func getUserShift(start: String, end: String) -> Promise<JSON> {
        let endPoint = "usershift"
        let getQuery = "?start=" + start + "&end=" + end
        return getAuth(url: base + version + endPoint + getQuery)
    }
    
    func updateUserShift(shifts: [[String:Any]]) -> Promise<JSON> {
        let endPoint = "usershift"
        let params = [
            "shifts": shifts
            ] as [String:Any]
        
        return postPutDeleteAuth(url: base + version + endPoint, params: params, httpMethod: .put)
    }
}


// MARK: - Tables API
extension API {
    func getFileTable() -> Promise<JSON> {
        let endPoint = "tables"
        return getAuth(url: base + version + endPoint)
    }
    
    func getFileTableDetail(id: Int) -> Promise<JSON> {
        let endPoint = "tables/" + String(id)
        return getAuth(url: base + version + endPoint)
    }
    
    func deleteTable(id: Int) -> Promise<JSON> {
        let endPoint = "tables/" + String(id)
        return postPutDeleteAuth(url: base + version + endPoint, params: [:], httpMethod: .delete)
    }
    
    func importShift(number:String, start:String, end:String, title:String, sameLine:String, username:String, join:String, dayShift:String, file:URL) -> Promise<JSON> {
        let endPoint = "table"
        let url = base + version + endPoint
        let user = try! keychain.get("userCode")
        let password = try! keychain.get("password")
        
        indicator.start()
        
        let promise = Promise<JSON> { seal in
            Alamofire.upload(
                multipartFormData: { multipartFormData in
                    multipartFormData.append(number.data(using: .utf8)!, withName: "number")
                    multipartFormData.append(start.data(using: .utf8)!, withName: "start")
                    multipartFormData.append(end.data(using: .utf8)!, withName: "end")
                    multipartFormData.append(title.data(using: .utf8)!, withName: "title")
                    multipartFormData.append(sameLine.data(using: .utf8)!, withName: "same_line_threshold")
                    multipartFormData.append(username.data(using: .utf8)!, withName: "username_threshold")
                    multipartFormData.append(join.data(using: .utf8)!, withName: "join_threshold")
                    multipartFormData.append(dayShift.data(using: .utf8)!, withName: "day_shift_threshold")
                    multipartFormData.append(file, withName: "file")
            },
                to: url,
                encodingCompletion: { encodingResult in
                    switch encodingResult {
                    case .success(let upload, _, _):
                        upload
                        .authenticate(user: user!, password: password!)
                        .responseJSON { response in
                            self.indicator.stop()
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
                    case .failure(let encodingError):
                        self.indicator.stop()
                        seal.reject(encodingError)
                    }
            }
            )
        }
        
        return promise
    }
}


// MARK: - Salary API
extension API {
    func getSalary() -> Promise<JSON> {
        let endPoint = "salary"
        return getAuth(url: base + version + endPoint)
    }
    
    func reCalcSalary() -> Promise<JSON> {
        let endPoint = "salary"
        return postPutDeleteAuth(url: base + version + endPoint, params: [:], httpMethod: .put)
    }
}


// MARK: - Shift API
extension API {
    func getUserCompanyShiftNames() -> Promise<JSON> {
        let endPoint = "shift"
        return getAuth(url: base + version + endPoint)
    }
    
    func updateShift(adds:[[String:Any]], updates:[[String:Any]], deletes:[Int]) -> Promise<JSON> {
        let endPoint = "shift"
        let params = [
            "adds": adds,
            "updates": updates,
            "deletes": deletes
            ] as [String:Any]
        return postPutDeleteAuth(url: base + version + endPoint, params: params, httpMethod: .put)
    }
}


// MARK: - Setting Color API
extension API {
    func updateShiftCategoryColor(schemes:[[String:Any]]) -> Promise<JSON> {
        let endPoint = "setting/color"
        let params = ["schemes": schemes] as [String:Any]
        return postPutDeleteAuth(url: base + version + endPoint, params: params, httpMethod: .put)
    }
    
    func getShiftCategoryColor() -> Promise<JSON>  {
        let endPoint = "setting/color"
        return getAuth(url: base + version + endPoint)
    }
}


// MARK: - Setting Users API
extension API {
    func getUserList() -> Promise<JSON> {
        let endPoint = "setting/users"
        return getAuth(url: base + version + endPoint)
    }
    
    func updateUserList(adds:[[String:Any]], updates:[[String:Any]], deletes:[String]) -> Promise<JSON> {
        let endPoint = "setting/users"
        let params = [
            "adds": adds,
            "updates": updates,
            "deletes": deletes
            ] as [String:Any]
        return postPutDeleteAuth(url: base + version + endPoint, params: params, httpMethod: .put)
    }
}



// MARK: - Setting ShiftCategory API
extension API {
    func getShiftCategory() -> Promise<JSON> {
        let endPoint = "setting/shiftcategory"
        return getAuth(url: base + version + endPoint)
    }
    
    func updateShiftCategory(adds:[String], updates:[[String:Any]], deletes:[Int]) -> Promise<JSON> {
        let endPoint = "setting/shiftcategory"
        let params = [
            "adds": adds,
            "updates": updates,
            "deletes": deletes
            ] as [String:Any]
        return postPutDeleteAuth(url: base + version + endPoint, params: params, httpMethod: .put)
    }
}


// MARK: - Setting Password API
extension API {
    func updatePassword(new: String) -> Promise<JSON> {
        let endPoint = "setting/password"
        let params = ["new_password": new] as [String:Any]
        return postPutDeleteAuth(url: base + version + endPoint, params: params, httpMethod: .put)
    }
}


// MARK: - Setting Wage API
extension API {
    func getUserWage() -> Promise<JSON> {
        let endPoint = "setting/wage"
        return getAuth(url: base + version + endPoint)
    }
    
    func updateUserWage(daytimeStart: String, daytimeEnd: String, nightStart: String, nightEnd: String, daytimeWage: Int, nightWage: Int) -> Promise<JSON> {
        let endPoint = "setting/wage"
        let params = [
            "daytime_start": daytimeStart,
            "daytime_end": daytimeEnd,
            "night_start": nightStart,
            "night_end": nightEnd,
            "daytime_wage": daytimeWage,
            "night_wage": nightWage
            ] as [String:Any]
        return postPutDeleteAuth(url: base + version + endPoint, params: params, httpMethod: .put)
    }
}


// MARK: - Setting Username API
extension API {
    func updateUserName(newUserName: String) -> Promise<JSON> {
        let endPoint = "setting/username"
        let params = ["username": newUserName] as [String:Any]
        return postPutDeleteAuth(url: base + version + endPoint, params: params, httpMethod: .put)
    }
}



// MARK: - UserShift Memo API
extension API {
    func updateMemo(userShiftID: Int, text: String) -> Promise<JSON> {
        let endPoint = "usershift/memo/" + String(userShiftID)
        let params = [
            "text": text
            ] as [String:Any]
        
        return postPutDeleteAuth(url: base + version + endPoint, params: params, httpMethod: .put)
    }
}
