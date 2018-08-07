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
    
    // Client
    @IBOutlet weak var clientNumberTextField: NSTextField!
    @IBOutlet weak var clientControlButton: NSButton!
    @IBOutlet weak var clientInfoTableView: NSTableView!
    private var clientInfos: [String] = []
    
    @IBAction func valueChangedAction(_ sender: NSSegmentedControl) {
        self.tabView.selectTabViewItem(at: sender.selectedSegment)
    }
    
    @IBAction func clientStartAction(_ sender: NSButton) {
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
        manager.addSessions(number: uint(clientNumberTextField.integerValue))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        clientInfoTableView.delegate = self
        clientInfoTableView.dataSource = self
    }
    
    // MARK: - JLMQTTManagerDelegate
    func didConnect(session: MQTTSession, error: Error!) {
        clientInfos.append(session.clientId)
        clientInfoTableView.reloadData()
        
        let now = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = formatter.string(from: now)
        
        let log = NSMutableAttributedString(string: date + " ==> " + "The " + session.clientId + " connection was successful." + "\r\n")
        logTextView.textStorage?.append(log)
        let range = NSMakeRange(session.clientId.lengthOfBytes(using: String.Encoding.utf8), 0)
        logTextView.scrollRangeToVisible(range)
    }
    
    func didSubscribe(session: MQTTSession, error: Error!, gQoss: [NSNumber]!) {
        
    }
    
    func didUnsubscribe(session: MQTTSession, error: Error!) {
        
    }
    
    func didPublishData(session: MQTTSession, error: Error!) {
        
    }
    
    func message(session: MQTTSession, data: Data!, topic: String, qos: MQTTQosLevel, retained: Bool, mid: UInt32) {
        
    }
    
    // MARK: - NSTableViewDelegate, NSTableViewDataSource
    func numberOfRows(in tableView: NSTableView) -> Int {
        return clientInfos.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        let identifier = tableColumn?.identifier
        if let cell = tableView.makeView(withIdentifier: identifier!, owner: nil) as? NSTableCellView {
            if identifier?.rawValue == "IndexTableViewCell" {
                cell.textField?.stringValue = "\(row + 1)"
            }else {
                cell.textField?.stringValue = clientInfos[row]
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
