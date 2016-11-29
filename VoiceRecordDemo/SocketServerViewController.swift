//
//  SocketServerViewController.swift
//  VoiceRecordDemo
//
//  Created by qiuhong on 29/11/2016.
//  Copyright © 2016 CETCME. All rights reserved.
//

import UIKit
import CocoaAsyncSocket

class SocketServerViewController: UIViewController {

    @IBOutlet weak var textView: UITextView!
    var serverSocket: GCDAsyncSocket?
    var clientSocket: GCDAsyncSocket?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        serverSocket = GCDAsyncSocket(delegate: self, delegateQueue: DispatchQueue.main)
        do {
            try serverSocket?.accept(onPort: 9999)
            textView.text = textView.text + "listen successful" + "\n"
        } catch _ {
            print("failed")
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func send(_ sender: AnyObject) {
        clientSocket?.write("this is a msg send from server!".data(using: .utf8)!, withTimeout: -1, tag: 0)
    }

}

extension SocketServerViewController: GCDAsyncSocketDelegate {
    func socket(_ sock: GCDAsyncSocket, didAcceptNewSocket newSocket: GCDAsyncSocket) {
        textView.text = textView.text + "connect successful" + "\n"
        clientSocket = newSocket
        clientSocket!.readData(withTimeout: -1, tag: 0)
    }
    func socket(_ sock: GCDAsyncSocket, didRead data: Data, withTag tag: Int) {
        clientSocket?.write("yishoudao data".data(using: .utf8)!, withTimeout: -1, tag: 0)
        textView.text = textView.text + String(data: data, encoding: .utf8)! + "\n"
        clientSocket!.readData(withTimeout: -1, tag: 0)
    }
}
