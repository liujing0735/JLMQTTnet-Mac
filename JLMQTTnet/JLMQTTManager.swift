//
//  JLMQTTManager.swift
//  JLMQTTnet
//
//  Created by JasonLiu on 2018/8/7.
//  Copyright © 2018年 trudian. All rights reserved.
//

import Cocoa

protocol JLMQTTManagerDelegate {
    func didConnect(session: MQTTSession, error: Error!)
    func didSubscribe(session: MQTTSession, error: Error!, gQoss: [NSNumber]!)
    func didUnsubscribe(session: MQTTSession, error: Error!)
    func didPublishData(session: MQTTSession, error: Error!)
    func message(session: MQTTSession, data: Data!, topic: String, qos: MQTTQosLevel, retained: Bool, mid: UInt32)
}

class JLMQTTManager: NSObject, MQTTSessionDelegate {
    
    static let shared = JLMQTTManager.init()
    private override init() {
        topicSet = []
        sessions = []
    }
    private var sessions: [MQTTSession]!
    private var topicSet: Set<String>!
    private var _random: Int = Int(arc4random() % 999) + 100
    private var random: Int {
        get {
            return _random
        }
    }
    private var _sessionIndex: Int = 0
    private var sessionIndex: Int {
        get {
            _sessionIndex += 1
            return _sessionIndex
        }
    }
    
    let operationQueue = OperationQueue()
    let sessionLock = NSLock()
    let topicSetLock = NSLock()
    
    var delegate: JLMQTTManagerDelegate!
    var host: String = ""
    var port: uint32 = 0
    var userName: String = ""
    var password: String = ""
    var clientId: String = ""
    var keepAliveInterval: uint16 = 0
    var cleanSessionFlag: Bool = true
    var subscribeQos: MQTTQosLevel = .exactlyOnce
    var publishQos: MQTTQosLevel = .exactlyOnce
    
    func addSession() {
        let blockOperation = BlockOperation {
            let transport = MQTTCFSocketTransport()
            transport.host = self.host
            transport.port = self.port
            
            let session = MQTTSession()
            session?.transport = transport
            session?.userName = self.userName
            session?.password = self.password
            session?.clientId = self.clientId + "_" + "\(self.random)" + String(format: "%03d", self.sessionIndex)
            session?.keepAliveInterval = self.keepAliveInterval
            session?.cleanSessionFlag = self.cleanSessionFlag

            self.connect(session: session!)
            
            self.sessionLock.lock()
            self.sessions.append(session!)
            self.sessionLock.unlock()
        }
        operationQueue.addOperation(blockOperation)
    }
    
    func addSessions(number: uint) {
        //let blockOperation = BlockOperation {
            for _ in 0..<number {
                self.addSession()
            }
        //}
        //operationQueue.addOperation(blockOperation)
    }
    
    func addTopic(topic: String) {
        topicSet.insert(topic)
        for session in sessions {
            if session.status == .connected {
                subscribe(session: session, topic: topic)
            }
        }
    }
    
    func addTopics(topics: [String]) {
        for topic in topics {
            self.topicSetLock.lock()
            topicSet.insert(topic)
            self.topicSetLock.unlock()
            for session in sessions {
                if session.status == .connected {
                    subscribe(session: session, topic: topic)
                }
            }
        }
    }

    func removeTopic(topic: String) {
        self.topicSetLock.lock()
        topicSet.remove(topic)
        self.topicSetLock.unlock()
        for session in sessions {
            if session.status == .connected {
                unsubscribe(session: session, topic: topic)
            }
        }
    }
    
    func removeTopics(topics: [String]) {
        for topic in topics {
            self.topicSetLock.lock()
            topicSet.remove(topic)
            self.topicSetLock.unlock()
            for session in sessions {
                if session.status == .connected {
                    unsubscribe(session: session, topic: topic)
                }
            }
        }
    }
    
    func removeAllTopic() {
        for topic in topicSet {
            for session in sessions {
                if session.status == .connected {
                    unsubscribe(session: session, topic: topic)
                }
            }
        }
        self.topicSetLock.lock()
        topicSet.removeAll()
        self.topicSetLock.unlock()
    }
    
    private func connect(session: MQTTSession) {
        if session.status == .created {
            session.delegate = self
            session.connectAndWaitTimeout(30)
        }
    }
    
    func connect() {
        for session in sessions {
            connect(session: session)
        }
    }
    
    private func disconnect(session: MQTTSession) {
        if session.status == .connected {
            session.close()
        }
    }
    
    func disconnect() {
        for session in sessions {
            disconnect(session: session)
        }
        self.sessionLock.lock()
        sessions.removeAll()
        self.sessionLock.unlock()
    }
    
    func handleEvent(_ session: MQTTSession!, event eventCode: MQTTSessionEvent, error: Error!) {
        switch eventCode {
        case .connected:
            if delegate != nil {
                delegate.didConnect(session: session, error: error)
            }
            for topic in topicSet {
                subscribe(session: session, topic: topic)
            }
            break
        case .connectionClosed:
            connect()
            break
        case .connectionClosedByBroker:
            break
        default:
            break
        }
    }
    
    private func subscribe(session: MQTTSession, topic: String) {
        session.subscribe(toTopic: topic, at: subscribeQos) { (error, gQoss) in
            if self.delegate != nil {
                self.delegate.didSubscribe(session: session, error: error, gQoss: gQoss)
            }
        }
    }
    
    private func unsubscribe(session: MQTTSession, topic: String) {
        session.unsubscribeTopic(topic) { (error) in
            if self.delegate != nil {
                self.delegate.didUnsubscribe(session: session, error: error)
            }
        }
    }
    
    func newMessage(withFeedback session: MQTTSession!, data: Data!, onTopic topic: String!, qos: MQTTQosLevel, retained: Bool, mid: UInt32) -> Bool {
        
        if delegate != nil {
            delegate.message(session: session, data: data, topic: topic, qos: qos, retained: retained, mid: mid)
        }
        
        if qos == .exactlyOnce || qos == .atMostOnce {
            return true
        } else {
            return false
        }
    }
    
    func publishData(session: MQTTSession!, data: Data, topic: String) {
        publishData(session: session, data: data, topic: topic, retain: true, qos: publishQos)
    }
    
    func publishData(session: MQTTSession!, data: Data, topic: String, retain: Bool) {
        publishData(session: session, data: data, topic: topic, retain: retain, qos: publishQos)
    }
    
    func publishData(session: MQTTSession!, data: Data, topic: String, retain: Bool, qos: MQTTQosLevel) {
        if session.status == .connected {
            session.publishData(data, onTopic: topic, retain: retain, qos: qos) { (error) in
                if self.delegate != nil {
                    self.delegate.didPublishData(session: session, error: error)
                }
            }
        }
    }
}
