//
//  API.swift
//  Shifree
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
    let shifreeBase = GetShifreeHost() + "api/"
    let portfolioBase = GetPortfolioHost() + "api/"
    let shifreeAPIVersion = "v1/"
    let portfolioAPIVersion = "v1/"
    let keychain = Keychain()
    let indicator = Indicator()
    
    private func postNoAuth(url: String, params: [String:Any]) -> Promise<JSON> {
        indicator.start()
        
        let promise = Promise<JSON> { seal in
            Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding(options: [])).validate(statusCode: 200..<600).responseJSON { (response) in
                self.indicator.stop()
                
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    print("***** GET Auth API Results *****")
                    print(json)
                    print("***** GET Auth API Results *****")
                    
                    if isHTTPStatus2XX(statusCode: response.response?.statusCode) && !json["code"].exists() {
                        seal.fulfill(json)
                    }else {
                        let err_msg = json["msg"].stringValue + "[" + String(json["code"].intValue) + "]"
                        seal.reject(NSError(domain: err_msg, code: (response.response?.statusCode)!))
                    }
                case .failure(_):
                    let err_msg = "エラーが発生しました[-1]"
                    seal.reject(NSError(domain: err_msg, code: (response.response?.statusCode)!))
                }
            }
        }
        return promise
    }
    
    private func getAuth(url: String) -> Promise<JSON> {
        indicator.start()
        
        let user = try! keychain.get("userCode")
        let password = try! keychain.get("password")
        
        let promise = Promise<JSON> { seal in
            Alamofire.request(url, method: .get).authenticate(user: user!, password: password!).validate(statusCode: 200..<600).responseJSON { (response) in
                self.indicator.stop()
                
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    print("***** GET Auth API Results *****")
//                    print(json)
                    print("***** GET Auth API Results *****")
                    
                    if isHTTPStatus2XX(statusCode: response.response?.statusCode) && !json["code"].exists() {
                        seal.fulfill(json)
                    }else {
                        let err_msg = json["msg"].stringValue + "[" + String(json["code"].intValue) + "]"
                        seal.reject(NSError(domain: err_msg, code: (response.response?.statusCode)!))
                    }
                case .failure(_):
                    let err_msg = "エラーが発生しました[-1]"
                    seal.reject(NSError(domain: err_msg, code: (response.response?.statusCode)!))
                }
            }
        }
        return promise
    }
    
    private func postPutDeleteAuth(url: String, params: [String:Any], httpMethod: HTTPMethod) -> Promise<JSON> {
        indicator.start()
        
        let user = try! keychain.get("userCode")
        let password = try! keychain.get("password")
        
        let promise = Promise<JSON> { seal in
            Alamofire.request(url, method: httpMethod, parameters: params, encoding: JSONEncoding(options: [])).authenticate(user: user!, password: password!).validate(statusCode: 200..<600).responseJSON { (response) in
                self.indicator.stop()
                
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    print("***** GET Auth API Results *****")
                    print(json)
                    print("***** GET Auth API Results *****")
                    
                    if isHTTPStatus2XX(statusCode: response.response?.statusCode) && !json["code"].exists() {
                        seal.fulfill(json)
                    }else {
                        let err_msg = json["msg"].stringValue + "[" + String(json["code"].intValue) + "]"
                        seal.reject(NSError(domain: err_msg, code: (response.response?.statusCode)!))
                    }
                case .failure(_):
                    let err_msg = "エラーが発生しました[-1]"
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
        return postNoAuth(url: shifreeBase + shifreeAPIVersion + endPoint, params: params)
    }
    
    func login() -> Promise<JSON> {
        let endPoint = "login"
        return getAuth(url: shifreeBase + shifreeAPIVersion + endPoint)
    }
}



// MARK: - Company API
extension API {
    func getThreshold() -> Promise<JSON> {
        let endPoint = "company"
        return getAuth(url: shifreeBase + shifreeAPIVersion + endPoint)
    }
}



// MARK: - Comment API
extension API {
    func updateComment(text: String, id: Int) -> Promise<JSON> {
        let endPoint = "comment/" + String(id)
        let params = ["text": text] as [String:Any]
        return postPutDeleteAuth(url: shifreeBase + shifreeAPIVersion + endPoint, params: params, httpMethod: .put)
    }
    
    func addComment(text: String, id: Int) -> Promise<JSON> {
        let endPoint = "comment"
        let params = [
            "text": text,
            "table_id": id
            ] as [String:Any]
        return postPutDeleteAuth(url: shifreeBase + shifreeAPIVersion + endPoint, params: params, httpMethod: .post)
    }
}



// MARK: - UserShift API
extension API {
    func getUserShift(start: String, end: String) -> Promise<JSON> {
        let endPoint = "usershift"
        let getQuery = "?start=" + start + "&end=" + end
        return getAuth(url: shifreeBase + shifreeAPIVersion + endPoint + getQuery)
    }
    
    func updateUserShift(shifts: [[String:Any]]) -> Promise<JSON> {
        let endPoint = "usershift"
        let params = [
            "shifts": shifts
            ] as [String:Any]
        
        return postPutDeleteAuth(url: shifreeBase + shifreeAPIVersion + endPoint, params: params, httpMethod: .put)
    }
    
    func updateUnknownUserShift(updates: [[String:Any]]) -> Promise<JSON> {
        let endPoint = "usershift/unknowns"
        let params = [
            "updates": updates
        ] as [String: Any]
        return postPutDeleteAuth(url: shifreeBase + shifreeAPIVersion + endPoint, params: params, httpMethod: .put)
    }
}


// MARK: - Tables API
extension API {
    func getFileTable() -> Promise<JSON> {
        let endPoint = "tables"
        return getAuth(url: shifreeBase + shifreeAPIVersion + endPoint)
    }
    
    func getFileTableDetail(id: Int) -> Promise<JSON> {
        let endPoint = "tables/" + String(id)
        return getAuth(url: shifreeBase + shifreeAPIVersion + endPoint)
    }
    
    func updateTableTitle(id: Int, params: [String:String]) -> Promise<JSON> {
        let endPoint = "tables/" + String(id)
        return postPutDeleteAuth(url: shifreeBase + shifreeAPIVersion + endPoint, params: params, httpMethod: .put)
    }
    
    func deleteTable(id: Int) -> Promise<JSON> {
        let endPoint = "tables/" + String(id)
        return postPutDeleteAuth(url: shifreeBase + shifreeAPIVersion + endPoint, params: [:], httpMethod: .delete)
    }
    
    func importShift(number:String, start:String, end:String, title:String, sameLine:String, username:String, join:String, dayShift:String, file:URL) -> Promise<JSON> {
        let endPoint = "table"
        let url = shifreeBase + shifreeAPIVersion + endPoint
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
                        .validate(statusCode: 200..<600)
                        .responseJSON { response in
                            self.indicator.stop()
                            
                            switch response.result {
                            case .success(let value):
                                let json = JSON(value)
                                print("***** GET Auth API Results *****")
                                print(json)
                                print("***** GET Auth API Results *****")
                                if isHTTPStatus2XX(statusCode: response.response?.statusCode) {
                                    seal.fulfill(json)
                                }else {
                                    let err_msg = json["msg"].stringValue + "[" + String(json["code"].intValue) + "]"
                                    seal.reject(NSError(domain: err_msg, code: (response.response?.statusCode)!))
                                }
                            case .failure(_):
                                let err_msg = "エラーが発生しました[-1]"
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
        return getAuth(url: shifreeBase + shifreeAPIVersion + endPoint)
    }
    
    func reCalcSalary() -> Promise<JSON> {
        let endPoint = "salary"
        return postPutDeleteAuth(url: shifreeBase + shifreeAPIVersion + endPoint, params: [:], httpMethod: .put)
    }
}


// MARK: - Shift API
extension API {
    func getUserCompanyShiftNames() -> Promise<JSON> {
        let endPoint = "shift"
        return getAuth(url: shifreeBase + shifreeAPIVersion + endPoint)
    }
    
    func updateShift(adds:[[String:Any]], updates:[[String:Any]], deletes:[Int]) -> Promise<JSON> {
        let endPoint = "shift"
        let params = [
            "adds": adds,
            "updates": updates,
            "deletes": deletes
            ] as [String:Any]
        return postPutDeleteAuth(url: shifreeBase + shifreeAPIVersion + endPoint, params: params, httpMethod: .put)
    }
}


// MARK: - Setting Color API
extension API {
    func updateShiftCategoryColor(schemes:[[String:Any]]) -> Promise<JSON> {
        let endPoint = "setting/color"
        let params = ["schemes": schemes] as [String:Any]
        return postPutDeleteAuth(url: shifreeBase + shifreeAPIVersion + endPoint, params: params, httpMethod: .put)
    }
    
    func getShiftCategoryColor() -> Promise<JSON>  {
        let endPoint = "setting/color"
        return getAuth(url: shifreeBase + shifreeAPIVersion + endPoint)
    }
}


// MARK: - Setting Users API
extension API {
    func getUserList() -> Promise<JSON> {
        let endPoint = "setting/users"
        return getAuth(url: shifreeBase + shifreeAPIVersion + endPoint)
    }
    
    func updateUserList(adds:[[String:Any]], updates:[[String:Any]], deletes:[String]) -> Promise<JSON> {
        let endPoint = "setting/users"
        let params = [
            "adds": adds,
            "updates": updates,
            "deletes": deletes
            ] as [String:Any]
        return postPutDeleteAuth(url: shifreeBase + shifreeAPIVersion + endPoint, params: params, httpMethod: .put)
    }
}



// MARK: - Setting ShiftCategory API
extension API {
    func getShiftCategory() -> Promise<JSON> {
        let endPoint = "setting/shiftcategory"
        return getAuth(url: shifreeBase + shifreeAPIVersion + endPoint)
    }
    
    func updateShiftCategory(adds:[String], updates:[[String:Any]], deletes:[Int]) -> Promise<JSON> {
        let endPoint = "setting/shiftcategory"
        let params = [
            "adds": adds,
            "updates": updates,
            "deletes": deletes
            ] as [String:Any]
        return postPutDeleteAuth(url: shifreeBase + shifreeAPIVersion + endPoint, params: params, httpMethod: .put)
    }
}


// MARK: - Setting Password API
extension API {
    func updatePassword(new: String) -> Promise<JSON> {
        let endPoint = "setting/password"
        let params = ["new_password": new] as [String:Any]
        return postPutDeleteAuth(url: shifreeBase + shifreeAPIVersion + endPoint, params: params, httpMethod: .put)
    }
}


// MARK: - Setting Wage API
extension API {
    func getUserWage() -> Promise<JSON> {
        let endPoint = "setting/wage"
        return getAuth(url: shifreeBase + shifreeAPIVersion + endPoint)
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
        return postPutDeleteAuth(url: shifreeBase + shifreeAPIVersion + endPoint, params: params, httpMethod: .put)
    }
}


// MARK: - Setting Username API
extension API {
    func updateUserName(newUserName: String) -> Promise<JSON> {
        let endPoint = "setting/username"
        let params = ["username": newUserName] as [String:Any]
        return postPutDeleteAuth(url: shifreeBase + shifreeAPIVersion + endPoint, params: params, httpMethod: .put)
    }
}


// MARK: - Setting Follow API
extension API {
    func getFollowUserAndCompanyUsers() -> Promise<JSON> {
        let endPoint = "setting/follow"
        return getAuth(url: shifreeBase + shifreeAPIVersion + endPoint)
    }
    
    func updateFollow(username: String) -> Promise<JSON> {
        let endPoint = "setting/follow"
        let params = ["username": username] as [String:Any]
        return postPutDeleteAuth(url: shifreeBase + shifreeAPIVersion + endPoint, params: params, httpMethod: .put)
    }
}



// MARK: - UserShift Memo API
extension API {
    func updateMemo(userShiftID: Int, text: String) -> Promise<JSON> {
        let endPoint = "usershift/memo/" + String(userShiftID)
        let params = [
            "text": text
            ] as [String:Any]
        
        return postPutDeleteAuth(url: shifreeBase + shifreeAPIVersion + endPoint, params: params, httpMethod: .put)
    }
}



// MARK: - Notification API
extension API {
    func getNotification() -> Promise<JSON> {
        let endPoint = "setting/notification"
        return getAuth(url: shifreeBase + shifreeAPIVersion + endPoint)
    }
    
    func updateNotification(isShiftImport: Bool, isComment: Bool, isUpdateShift: Bool) -> Promise<JSON> {
        let endPoint = "setting/notification"
        let params = [
            "is_shift_import": isShiftImport,
            "is_comment": isComment,
            "is_update_shift": isUpdateShift
            ] as [String:Any]
        return postPutDeleteAuth(url: shifreeBase + shifreeAPIVersion + endPoint, params: params, httpMethod: .put)
    }
}


// MARK: - Notification API
extension API {
    func updateToken(token: String) -> Promise<JSON> {
        let endPoint = "token"
        let params = [
            "token": token
            ] as [String:Any]
        return postPutDeleteAuth(url: shifreeBase + shifreeAPIVersion + endPoint, params: params, httpMethod: .put)
    }
}



// MARK: - Contact API
extension API {
    func postContact(params: [String:String]) -> Promise<JSON> {
        let endPoint = "contact/"
        return postNoAuth(url: portfolioBase + portfolioAPIVersion + endPoint, params: params)
    }
}


// MARK: - Export API
extension API {
    func getExportInitData() -> Promise<JSON> {
        let endPoint = "setting/export/init"
        return getAuth(url: shifreeBase + shifreeAPIVersion + endPoint)
    }
    
    func getExportShiftData(userID: Int, tableID: Int) -> Promise<JSON> {
        let endPoint = "setting/export/shift?user_id=\(userID)&table_id=\(tableID)"
        return getAuth(url: shifreeBase + shifreeAPIVersion + endPoint)
    }
}


// MARK: - Search Shift API
extension API {
    func getShiftSearchInitData() -> Promise<JSON> {
        let endPoint = "usershift/search/init"
        return getAuth(url: shifreeBase + shifreeAPIVersion + endPoint)
    }
    
    func getShiftSearchResults(userID: Int, categoryID: Int, tableID: Int, shiftID: Int) -> Promise<JSON> {
        let endPoint = "usershift/search/shift?user_id=\(userID)&category_id=\(categoryID)&table_id=\(tableID)&shift_id=\(shiftID)"
        return getAuth(url: shifreeBase + shifreeAPIVersion + endPoint)
    }
}



// MARK: - Analytics API
extension API {
    func getAnalyticsData(range: String) -> Promise<JSON> {
        let endPoint = "usershift/analytics?range=\(range)"
        return getAuth(url: shifreeBase + shifreeAPIVersion + endPoint)
    }
}
