//
//  JLGlobal.swift
//  JLMQTTnet
//
//  Created by JasonLiu on 2018/8/6.
//  Copyright © 2018年 trudian. All rights reserved.
//

import Cocoa

extension Data {
    var toString: String!{
        return String(data: self, encoding: String.Encoding.utf8)
    }
    
    var toHexString: String! {
        if let string = self.toString {
            var result = ""
            for char in string.utf8{
                result += String(format: "%02x", char)
            }
            return result
        }
        return nil
    }
}

extension String {
    var bytes: [UInt8] {
        var array = [UInt8]()
        for char in self.utf8{
            array.append(char)
        }
        return array
    }
    
    var toData: Data! {
        return self.data(using: String.Encoding.utf8)
    }
    
    var toHexData: Data! {
        get {
            var data = Data(capacity: self.count/2)
            let regex = try! NSRegularExpression(pattern: "[0-9a-f]{1,2}", options: .caseInsensitive)
            regex.enumerateMatches(in: self, range: NSMakeRange(0, utf16.count)) { match, flags, stop in
                let substring = (self as NSString).substring(with: match!.range)
                var num = UInt8(substring, radix: 16)!
                data.append(&num, count: 1)
            }
            guard data.count > 0 else { return nil }
            return data
        }
    }
}

struct PreferencesModel {
    
    init() {
        let defaults = UserDefaults.standard
        clientNumber = defaults.integer(forKey: "clientNumber")
        isHexString = defaults.integer(forKey: "isHexString")
        subscribeQosLevel = defaults.integer(forKey: "subscribeQosLevel")
        if let value = defaults.string(forKey: "subscribeTopic") {
            subscribeTopic = value
        }
        publishQosLevel = defaults.integer(forKey: "publishQosLevel")
        if let value = defaults.string(forKey: "publishTopic") {
            publishTopic = value
        }
        if let value = defaults.string(forKey: "publishMessage") {
            publishMessage = value
        }
    }
    
    func save() {
        let defaults = UserDefaults.standard
        defaults.set("\(clientNumber)", forKey: "clientNumber")
        defaults.set("\(isHexString)", forKey: "isHexString")
        defaults.set("\(subscribeQosLevel)", forKey: "subscribeQosLevel")
        defaults.set(subscribeTopic, forKey: "subscribeTopic")
        defaults.set("\(publishQosLevel)", forKey: "publishQosLevel")
        defaults.set(publishTopic, forKey: "publishTopic")
        defaults.set(publishMessage, forKey: "publishMessage")
        defaults.synchronize()
    }
    
    var clientNumber: Int = 0
    var isHexString: Int = 1
    var subscribeQosLevel: Int = 0
    var subscribeTopic: String = ""
    var publishQosLevel: Int = 0
    var publishTopic: String = ""
    var publishMessage: String = ""
}

struct MQTTModel {
    
    init() {
        let defaults = UserDefaults.standard
        if let value = defaults.string(forKey: "host") {
            host = value
        }
        port = defaults.integer(forKey: "port")
        if port == 0 {
            port = 1883
        }
        if let value = defaults.string(forKey: "username") {
            username = value
        }
        if let value = defaults.string(forKey: "password") {
            password = value
        }
        if let value = defaults.string(forKey: "clientID") {
            clientID = value
        }else {
            clientID = "MQTTnet"
        }
        keepalive = defaults.integer(forKey: "keepalive")
        if keepalive == 0 {
            port = 60
        }
        cleanSession = defaults.integer(forKey: "cleanSession")
    }
    
    func save() {
        let defaults = UserDefaults.standard
        defaults.set(host, forKey: "host")
        defaults.set("\(port)", forKey: "port")
        defaults.set(username, forKey: "username")
        defaults.set(password, forKey: "password")
        defaults.set(clientID, forKey: "clientID")
        defaults.set("\(keepalive)", forKey: "keepalive")
        defaults.set(cleanSession, forKey: "cleanSession")
        defaults.synchronize()
    }
    
    var host: String = ""
    var port: Int = 0
    var username: String = ""
    var password: String = ""
    var clientID: String = ""
    var keepalive: Int = 0
    var cleanSession: Int = 1
}
