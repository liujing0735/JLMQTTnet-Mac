//
//  JLGlobal.swift
//  JLMQTTnet
//
//  Created by JasonLiu on 2018/8/6.
//  Copyright © 2018年 trudian. All rights reserved.
//

import Cocoa

struct MQTT {
    
    init() {
        let defaults = UserDefaults.standard
        if let value = defaults.string(forKey: "ip") {
            ip = value
        }
        if let value = defaults.string(forKey: "port") {
            port = Int(value)!
        }
        if let value = defaults.string(forKey: "username") {
            username = value
        }
        if let value = defaults.string(forKey: "password") {
            password = value
        }
        if let value = defaults.string(forKey: "clientID") {
            clientID = value
        }
        if let value = defaults.string(forKey: "keepalive") {
            keepalive = Int(value)!
        }
    }
    
    func save() {
        let defaults = UserDefaults.standard
        defaults.set(ip, forKey: "ip")
        defaults.set("\(port)", forKey: "port")
        defaults.set(username, forKey: "username")
        defaults.set(password, forKey: "password")
        defaults.set(clientID, forKey: "clientID")
        defaults.set("\(keepalive)", forKey: "keepalive")
        defaults.synchronize()
    }
    
    var ip: String = ""
    var port: Int = 0
    var username: String = ""
    var password: String = ""
    var clientID: String = ""
    var keepalive: Int = 0
}
