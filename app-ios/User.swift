//
//  User.swift
//  protonpay-ios
//
//  Created by Sinan Ulkuatam on 4/6/16.
//  Copyright © 2016 Sinan Ulkuatam. All rights reserved.
//

import Foundation
import SwiftyJSON
import Alamofire

class User {
    
    let username: String
    let email: String
    let first_name: String
    let last_name: String
    let cust_id: String
    
    required init(username: String, email: String, first_name: String, last_name: String, cust_id: String) {
        self.username = username
        self.email = email
        self.first_name = first_name
        self.last_name = last_name
        self.cust_id = cust_id
    }
    
    class func getUserAccounts(completionHandler: ([User]?, NSError?) -> Void) {
        // request to api to get account data as json, put in list and table
        // curl -X GET -i -H "Content-Type: application/json" -d '{"access_token": ""}' http://192.168.1.232:5001/v1/users/list
        
        let parameters : [String : AnyObject] = [:]
        
        let headers : [String : String] = [:]
        
        let endpoint = apiUrl + "/v1/user/list"
        
        Alamofire.request(.GET, endpoint, parameters: parameters, encoding: .URL, headers: headers)
            .responseJSON { response in
                switch response.result {
                case .Success:
                    print("success")
                    if let value = response.result.value {
                        let data = JSON(value)
                        var userItemsArray = [User]()
                        let accounts = data["users"].arrayValue
                        print(data["users"].arrayValue)
                        for jsonItem in accounts {
                            let username = jsonItem["username"].stringValue
                            let email = jsonItem["email"].stringValue
                            let first_name = jsonItem["first_name"].stringValue
                            let last_name = jsonItem["last_name"].stringValue
                            let cust_id = jsonItem["cust_id"].stringValue
                            let item = User(username: username, email: email, first_name: first_name, last_name: last_name, cust_id: cust_id)
                            userItemsArray.append(item)
                        }
                        completionHandler(userItemsArray, response.result.error)
                    }
                case .Failure(let error):
                    print(error)
                }
        }
    }
}