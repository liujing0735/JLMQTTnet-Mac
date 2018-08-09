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

struct MQTTModel {
    
    init() {
        let defaults = UserDefaults.standard
        if let value = defaults.string(forKey: "host") {
            host = value
        }
        port = defaults.integer(forKey: "port")
        if let value = defaults.string(forKey: "username") {
            username = value
        }
        if let value = defaults.string(forKey: "password") {
            password = value
        }
        if let value = defaults.string(forKey: "clientID") {
            clientID = value
        }
        keepalive = defaults.integer(forKey: "keepalive")
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
