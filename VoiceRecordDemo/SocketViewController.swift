//
//  SocketViewController.swift
//  VoiceRecordDemo
//
//  Created by qiuhong on 03/11/2016.
//  Copyright © 2016 CETCME. All rights reserved.
//

import UIKit
import CocoaAsyncSocket

//class SocketViewController: UIViewController {
//
//    @IBOutlet weak var textField: UITextField!
//    @IBOutlet weak var sendButton: UIButton!
//
//    
//    var socket: GCDAsyncSocket?
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        
//     
//    }
//
//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//        // Dispose of any resources that can be recreated.
//    }
//    
//    @IBAction func connect(_ sender: AnyObject) {
//        socket = GCDAsyncSocket(delegate: self, delegateQueue: DispatchQueue.main)
//        do {
//            print("to connect")
//            try socket?.connect(toHost: "192.168.0.212", onPort: 9999)
//        } catch _ {
//            print("connect failed")
//        }
//    }
//    @IBAction func send(_ sender: AnyObject) {
//        let data = "123".data(using: .utf8)!
//        socket?.write(data, withTimeout: -1, tag: 0)
//    }
//
//}
//
//extension SocketViewController: GCDAsyncSocketDelegate {
//    func socket(_ sock: GCDAsyncSocket, didConnectToHost host: String, port: UInt16) {
//        print("connect successful")
//        self.socket?.readData(withTimeout: -1, tag: 0)
//    }
//    
//    func socket(_ sock: GCDAsyncSocket, didRead data: Data, withTag tag: Int) {
//        let msg = String(data: data, encoding: .utf8)
//        print("get server msg: \(msg)")
//        self.socket?.readData(withTimeout: -1, tag: 0)
//    }
//    
//    func socket(_ sock: GCDAsyncSocket, didWriteDataWithTag tag: Int) {
//        if tag == 0 {
//            print("send successful")
//        }
//    }
//}

class SocketViewController: UIViewController {
    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    
    let PORT: UInt32 = 9999
    let HOST: CFString = "192.168.0.138" as CFString
    let BUFFER_SIZE = 1024
    
    var flag = -1
    var inputStream: InputStream?
    var outputStream: OutputStream?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
    }
    
    func initNetworkCommunication() {
        var readStream: Unmanaged<CFReadStream>?
        var writeStream: Unmanaged<CFWriteStream>?
        
        CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault,
                                           HOST, PORT, &readStream, &writeStream)
        
        self.inputStream = readStream!.takeUnretainedValue()
        self.inputStream!.delegate = self
        self.inputStream!.schedule(in: RunLoop.current, forMode: .commonModes)
        
        self.inputStream!.open()
        
        self.outputStream = writeStream!.takeUnretainedValue()
        self.outputStream!.delegate = self
        self.outputStream!.schedule(in: RunLoop.current, forMode: .commonModes)
        
        self.outputStream!.open()
    }
    
    @IBAction func connect(_ sender: AnyObject) {
        flag = 1
        initNetworkCommunication()
    }
    
    @IBAction func send(_ sender: AnyObject) {
        flag = 0
        initNetworkCommunication()
    }
    
}

extension SocketViewController: StreamDelegate {
  
    func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
        var event: String?
        switch eventCode {
        case Stream.Event.openCompleted:
            event = "openCompleted"
        case Stream.Event.hasBytesAvailable:
            event = "hasBytesAvailable"
            if flag == 1 && aStream == self.inputStream {
                let input = NSMutableData()
                let buf = UnsafeMutablePointer<UInt8>.allocate(capacity: BUFFER_SIZE)
                var len = 0
                while self.inputStream!.hasBytesAvailable {
                    len = self.inputStream!.read(buf, maxLength: BUFFER_SIZE)
                    if len > 0 {
                        input.append(buf, length: len)
                    }
                }
                let resultString = String(data: input as Data, encoding: .utf8)
                print(resultString)
            }
        case Stream.Event.hasSpaceAvailable:
            event = "hasSpaceAvailable"
            if flag == 0 && aStream == self.outputStream {
                let sendString = "i am ios socket"
                var data = sendString.data(using: .utf8, allowLossyConversion: true)!
//                self.outputStream!.write(UnsafePointer<UInt8>(data.bytes), maxLength: data.count)
                
                data.withUnsafeBytes({ (p: UnsafePointer<UInt8>) -> Void in
                    self.outputStream!.write(p, maxLength: data.count)
                })
            
                self.close()
            }
        case Stream.Event.errorOccurred:
            event = "errorOccurred"
            self.close()
        case Stream.Event.endEncountered:
            event = "endEncountered"
        default:
            event = "unknown"
            self.close()
        }
        print(event)
    }
    
    func close() {
        self.inputStream!.close()
        self.inputStream!.remove(from: RunLoop.current, forMode: .commonModes)
        self.inputStream!.delegate = nil
        
        self.outputStream!.close()
        self.outputStream!.remove(from: RunLoop.current, forMode: .commonModes)
        self.outputStream!.delegate = nil
    }
    
    
}






















