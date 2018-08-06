//
//  JLMQTTMainViewController.swift
//  JLMQTTnet
//
//  Created by JasonLiu on 2018/8/6.
//  Copyright © 2018年 trudian. All rights reserved.
//

import Cocoa
import Pods_JLMQTTnet

class JLMQTTMainViewController: NSViewController {
    
    @IBOutlet weak var segmentedControl: NSSegmentedControl!
    @IBOutlet weak var tabView: NSTabView!
    @IBOutlet weak var logTextView: NSScrollView!
    
    // Client
    @IBOutlet weak var clientNumberTextField: NSTextField!
    @IBOutlet weak var clientControlButton: NSButton!
    @IBOutlet weak var clientInfoTableView: NSScrollView!
    
    @IBAction func valueChangedAction(_ sender: NSSegmentedControl) {
        self.tabView.selectTabViewItem(at: sender.selectedSegment)
    }
    
    @IBAction func clientStartAction(_ sender: NSButton) {
        let mqtt = MQTT()
        let transport = MQTTCFSocketTransport()
        transport.host = "118.89.44.197"//mqtt.ip
        transport.port = UInt32(mqtt.port)
    
        let session = MQTTSession()
        session?.transport = transport
        session?.userName = mqtt.username
        session?.password = mqtt.password
        session?.clientId = mqtt.clientID
        session?.keepAliveInterval = UInt16(mqtt.keepalive)
        session?.cleanSessionFlag = true
        session?.connect(connectHandler: { (error) in
            
        })
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
}
