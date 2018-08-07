//
//  JLMQTTConfigurationPageController.swift
//  JLMQTTnet
//
//  Created by JasonLiu on 2018/8/6.
//  Copyright © 2018年 trudian. All rights reserved.
//

import Cocoa

class JLMQTTConfigurationPageController: NSPageController {
    
    @IBOutlet weak var hostTextField: NSTextField!
    @IBOutlet weak var portTextField: NSTextField!
    @IBOutlet weak var usernameTextField: NSTextField!
    @IBOutlet weak var passwordTextField: NSTextField!
    @IBOutlet weak var clientIDTextField: NSTextField!
    @IBOutlet weak var keepaliveTextField: NSTextField!
    @IBOutlet weak var cleanSessionCheck: NSButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        let mqtt = MQTTModel()
        hostTextField.stringValue = mqtt.host
        portTextField.stringValue = "\(mqtt.port)"
        usernameTextField.stringValue = mqtt.username
        passwordTextField.stringValue = mqtt.password
        clientIDTextField.stringValue = mqtt.clientID
        keepaliveTextField.stringValue = "\(mqtt.keepalive)"
        cleanSessionCheck.state = NSControl.StateValue(rawValue: mqtt.cleanSession)
    }
    
    override func viewWillDisappear() {
        super.viewWillDisappear()
        
        var mqtt = MQTTModel()
        mqtt.host = hostTextField.stringValue
        mqtt.port = portTextField.integerValue
        mqtt.username = usernameTextField.stringValue
        mqtt.password = passwordTextField.stringValue
        mqtt.clientID = clientIDTextField.stringValue
        mqtt.keepalive = keepaliveTextField.integerValue
        mqtt.cleanSession = cleanSessionCheck.state.rawValue
        mqtt.save()
    }
}
