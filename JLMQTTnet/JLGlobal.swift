//
//  JLGlobal.swift
//  JLMQTTnet
//
//  Created by JasonLiu on 2018/8/6.
//  Copyright © 2018年 trudian. All rights reserved.
//

import Cocoa

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
