//
//  JLMQTTMainViewController.swift
//  JLMQTTnet
//
//  Created by JasonLiu on 2018/8/6.
//  Copyright © 2018年 trudian. All rights reserved.
//

import Cocoa

class JLMQTTMainViewController: NSViewController, JLMQTTManagerDelegate, NSTableViewDelegate, NSTableViewDataSource {
    
    @IBOutlet weak var segmentedControl: NSSegmentedControl!
    @IBOutlet weak var tabView: NSTabView!
    @IBOutlet var logTextView: NSTextView!
    var logs: [String] = []
    
    // subscribe
    @IBOutlet weak var numberTextField: NSTextField!
    @IBOutlet weak var connectButton: NSButton!
    @IBOutlet weak var clientTableView: NSTableView!
    @IBOutlet weak var subscribeTopicTextField: NSTextField!
    @IBOutlet weak var subscribeQosLevel: NSPopUpButton!
    @IBOutlet weak var subscribeButton: NSButton!
    private var clients: [String] = []
    
    // publish
    @IBOutlet weak var publishButton: NSButton!
    @IBOutlet weak var publishTopicTextField: NSTextField!
    @IBOutlet weak var publishQosLevel: NSPopUpButton!
    @IBOutlet weak var publishMessageTextView: NSTextView!
    @IBOutlet weak var hexCheckButton: NSButton!
    
    @IBAction func valueChangedAction(_ sender: NSSegmentedControl) {
        self.tabView.selectTabViewItem(at: sender.selectedSegment)
    }
    
    @IBAction func connectButtonAction(_ sender: NSButton) {
        if sender.title == "Connect" {
            sender.title = "Disconnect"
            let manager = JLMQTTManager.shared
            manager.addSessions(number: uint(numberTextField.integerValue))
        }else {
            sender.title = "Connect"
            let manager = JLMQTTManager.shared
            manager.disconnect()
        }
    }
    
    @IBAction func subscribeButtonAction(_ sender: NSButton) {
        let topic = subscribeTopicTextField.stringValue
        if topic != "" {
            let topics = topic.components(separatedBy: ",")
            let index = subscribeQosLevel.indexOfSelectedItem
            let qos: MQTTQosLevel = MQTTQosLevel(rawValue: UInt8(index))!
            let manager = JLMQTTManager.shared
            manager.subscribeQos = qos
            manager.addTopics(topics: topics)
        }
    }
    
    @IBAction func publishButtonAction(_ sender: NSButton) {
        let topic = publishTopicTextField.stringValue
        if topic != "" {
            let topics = topic.components(separatedBy: ",")
            let message = publishMessageTextView.string
            var data = message.toData
            let hex = hexCheckButton.state.rawValue
            if hex == 1 ? true : false {
                data = message.toHexData
            }
            let index = publishQosLevel.indexOfSelectedItem
            let qos: MQTTQosLevel = MQTTQosLevel(rawValue: UInt8(index))!
            let manager = JLMQTTManager.shared
            manager.publishQos = qos
            manager.publishData(data: data!, topics: topics)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        clientTableView.delegate = self
        clientTableView.dataSource = self
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
        let mqtt = MQTTModel()
        let manager = JLMQTTManager.shared
        manager.host = mqtt.host
        manager.port = UInt32(mqtt.port)
        manager.userName = mqtt.username
        manager.password = mqtt.password
        manager.clientId = mqtt.clientID
        manager.keepAliveInterval = UInt16(mqtt.keepalive)
        manager.cleanSessionFlag = true
        manager.delegate = self
        manager.connect()
        
        let preferences = PreferencesModel()
        numberTextField.integerValue = preferences.clientNumber
        subscribeTopicTextField.stringValue = preferences.subscribeTopic
        subscribeQosLevel.selectItem(at: preferences.subscribeQosLevel)
        publishTopicTextField.stringValue = preferences.publishTopic
        publishQosLevel.selectItem(at: preferences.publishQosLevel)
        publishMessageTextView.string = preferences.publishMessage
        hexCheckButton.state = NSControl.StateValue(rawValue: preferences.isHexString)
    }
    
    override func viewWillDisappear() {
        super.viewWillDisappear()
        
        var preferences = PreferencesModel()
        preferences.clientNumber = numberTextField.integerValue
        preferences.subscribeTopic = subscribeTopicTextField.stringValue
        preferences.subscribeQosLevel = subscribeQosLevel.indexOfSelectedItem
        preferences.publishTopic = publishTopicTextField.stringValue
        preferences.publishQosLevel = publishQosLevel.indexOfSelectedItem
        preferences.publishMessage = publishMessageTextView.string
        preferences.isHexString = hexCheckButton.state.rawValue
        preferences.save()
    }
    
    // MARK: - JLMQTTManagerDelegate
    func didConnect(session: MQTTSession, error: Error!) {
        clients.append(session.clientId)
        clientTableView.reloadData()
        
        let now = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = formatter.string(from: now)
        
        var log = ""
        var color = NSColor.white
        if error == nil {
            log = date + " ==> " + "[Connect] " + session.clientId + " connection was successful" + "\r\n"
            color = NSColor.green
        }else {
            log = date + " ==> " + "[Connect] " + session.clientId + " connection was failed: \(String(describing: error))" + "\r\n"
            color = NSColor.red
        }
        let attributed = NSMutableAttributedString(string: log)//NSAttributedString(string: log)
        attributed.addAttributes([NSAttributedString.Key.foregroundColor: color], range: NSRange(location: 0, length: attributed.length))
//        let range = (log as NSString).range(of: "[Connect]")
//        attributed.addAttributes([NSAttributedString.Key.foregroundColor: NSColor.red], range: range)
        
        DispatchQueue.main.async {
            self.logTextView.textStorage?.append(attributed)
            self.logTextView.scrollRangeToVisible(NSMakeRange(self.logTextView.string.lengthOfBytes(using: String.Encoding.utf8), 0))
        }
    }
    
    func didDisconnect(session: MQTTSession, error: Error!) {
        if let index = clients.firstIndex(of: session.clientId) {
            clients.remove(at: index)
            clientTableView.reloadData()
        }
        
        let now = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = formatter.string(from: now)
        
        var log = ""
        var color = NSColor.white
        if error == nil {
            log = date + " ==> " + "[Disconnect] " + session.clientId + " disconnection was successful" + "\r\n"
            color = NSColor.green
        }else {
            log = date + " ==> " + "[Disconnect] " + session.clientId + " disconnection was failed: \(String(describing: error))" + "\r\n"
            color = NSColor.red
        }
        let attributed = NSMutableAttributedString(string: log)
        attributed.addAttributes([NSAttributedString.Key.foregroundColor: color], range: NSRange(location: 0, length: attributed.length))
        
        DispatchQueue.main.async {
            self.logTextView.textStorage?.append(attributed)
            self.logTextView.scrollRangeToVisible(NSMakeRange(self.logTextView.string.lengthOfBytes(using: String.Encoding.utf8), 0))
        }
    }
    
    func didSubscribe(session: MQTTSession, error: Error!, topic: String, gQoss: [NSNumber]!) {
        let now = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = formatter.string(from: now)
        
        var log = ""
        var color = NSColor.white
        if error == nil {
            log = date + " ==> " + "[Subscribe] " + session.clientId + " subscribe to the " + topic + " successfully" + "\r\n"
            color = NSColor.green
        }else {
            log = date + " ==> " + "[Subscribe] " + session.clientId + " subscribe to the " + topic + " failed: \(String(describing: error))" + "\r\n"
            color = NSColor.red
        }
        let attributed = NSMutableAttributedString(string: log)
        attributed.addAttributes([NSAttributedString.Key.foregroundColor: color], range: NSRange(location: 0, length: attributed.length))
        
        DispatchQueue.main.async {
            self.logTextView.textStorage?.append(attributed)
            self.logTextView.scrollRangeToVisible(NSMakeRange(self.logTextView.string.lengthOfBytes(using: String.Encoding.utf8), 0))
        }
    }
    
    func didUnsubscribe(session: MQTTSession, error: Error!, topic: String) {
        
    }
    
    func didPublishData(session: MQTTSession, error: Error!, topic: String) {
        
    }
    
    func message(session: MQTTSession, data: Data!, topic: String, qos: MQTTQosLevel, retained: Bool, mid: UInt32) {

        let now = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = formatter.string(from: now)
        
        var log = ""
        if let message = data.toString {
            log = date + " ==> " + "[Receive] clientId = " + session.clientId + ", topic = " + topic + ", message = " + message + "\r\n"
        }
        let hex = hexCheckButton.state.rawValue
        if hex == 1 ? true : false {
            if let message = data.toHexString {
                log = date + " ==> " + "[Receive] clientId = " + session.clientId + ", topic = " + topic + ", message = " + message + "\r\n"
            }
        }
        let attributed = NSMutableAttributedString(string: log)
        attributed.addAttributes([NSAttributedString.Key.foregroundColor: NSColor.blue], range: NSRange(location: 0, length: attributed.length))
        
        DispatchQueue.main.async {
            self.logTextView.textStorage?.append(attributed)
            self.logTextView.scrollRangeToVisible(NSMakeRange(self.logTextView.string.lengthOfBytes(using: String.Encoding.utf8), 0))
        }
    }
    
    // MARK: - NSTableViewDelegate, NSTableViewDataSource
    func numberOfRows(in tableView: NSTableView) -> Int {
        return clients.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        let identifier = tableColumn?.identifier
        if let cell = tableView.makeView(withIdentifier: identifier!, owner: nil) as? NSTableCellView {
            if identifier?.rawValue == "IndexTableViewCell" {
                cell.textField?.stringValue = "\(row + 1)"
            }else {
                cell.textField?.stringValue = clients[row]
            }
            return cell
        }
        return nil
    }
    
    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        return true
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        
    }

}
