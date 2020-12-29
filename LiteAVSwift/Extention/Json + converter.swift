//
//  JsonConverter.swift
//  LiteAVSwift
//
//  Created by kaoji on 2020/5/3.
//  Copyright © 2020 kaoji. All rights reserved.
//

import UIKit

extension Dictionary {
    func toString(dictionary:Dictionary<String,Any>) -> String {
        if (!JSONSerialization.isValidJSONObject(dictionary)) {
            print("无法解析出JSONString")
            return ""
        }
        let data : NSData! = try? JSONSerialization.data(withJSONObject: dictionary, options: []) as NSData?
        let JSONString = NSString(data:data as Data,encoding: String.Encoding.utf8.rawValue)
        return JSONString! as String
    }
    
    func toJson(jsonString:String) -> Dictionary<String,Any> {
        let jsonData:Data = jsonString.data(using: .utf8)!
        
        let dict = try? JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers)
        if dict != nil {
            return dict as! Dictionary<String,Any>
        }
        debugPrint("[Error] json serialization failed!")
        return Dictionary<String,Any>()
    }
    
    func toData(dictionary:Dictionary<String,Any>) -> Data {

        let data = try? JSONSerialization.data(withJSONObject: dictionary, options: .prettyPrinted)
        if data != nil {
            return data!
        }
        return Data()
    }
}
