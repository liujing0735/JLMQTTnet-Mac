//
//  JLMQTTConfigurationPageController.swift
//  JLMQTTnet
//
//  Created by JasonLiu on 2018/8/6.
//  Copyright © 2018年 trudian. All rights reserved.
//

import Cocoa

class JLMQTTConfigurationPageController: NSPageController {
    
    @IBOutlet weak var ipAddressTextField: NSTextField!
    @IBOutlet weak var portTextField: NSTextField!
    @IBOutlet weak var usernameTextField: NSTextField!
    @IBOutlet weak var passwordTextField: NSTextField!
    @IBOutlet weak var clientIDTextField: NSTextField!
    @IBOutlet weak var keepaliveTextField: NSTextField!
    @IBOutlet weak var cleanSessionCheck: NSButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        let mqtt = MQTT()
        ipAddressTextField.stringValue = mqtt.ip
        portTextField.stringValue = "\(mqtt.port)"
        usernameTextField.stringValue = mqtt.username
        passwordTextField.stringValue = mqtt.password
        clientIDTextField.stringValue = mqtt.clientID
        keepaliveTextField.stringValue = "\(mqtt.keepalive)"
        //cleanSessionCheck
    }
    
    override func viewWillDisappear() {
        super.viewWillDisappear()
        
        var mqtt = MQTT()
        mqtt.ip = ipAddressTextField.stringValue
        mqtt.port = portTextField.integerValue
        mqtt.username = usernameTextField.stringValue
        mqtt.password = passwordTextField.stringValue
        mqtt.clientID = clientIDTextField.stringValue
        mqtt.keepalive = keepaliveTextField.integerValue
        mqtt.save()
    }
}
