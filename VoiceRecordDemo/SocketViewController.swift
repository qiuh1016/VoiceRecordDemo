//
//  SocketViewController.swift
//  VoiceRecordDemo
//
//  Created by qiuhong on 03/11/2016.
//  Copyright © 2016 CETCME. All rights reserved.
//

import UIKit
import SocketIO


class SocketViewController: UIViewController {

    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var sendButton: UIButton!

    var socket: SocketIOClient!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.socket = SocketIOClient(socketURL: URL(fileURLWithPath: "http://localhost:3000"))
        
        self.addHandlers()
        self.socket.connect()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func addHandlers() {
        // Our socket handlers go here
        self.socket.onAny {
            print("Got event: \($0.event), with items: \($0.items)")
        }
        
//        self.socket.on("startGame") {[weak self] data, ack in
//            self?.handleStart()
//            return
//        }
//        
//        self.socket.on("win") {[weak self] data, ack in
//            if let name = data[0] as? String, let typeDict = data[1] as? NSDictionary {
//                self?.handleWin(name, type: typeDict)
//            }
//        }
//        
//        self.socket.on("gameReset") {data, ack in
//            ack(false)
//        }
    }
    
    @IBAction func sendButtonTapped(_ sender: AnyObject) {
//        let coord:(x:Int, y:Int)
//
//        // Long switch statement that determines what coord should be
//        
//        self.socket.emit("playerMove", coord.x, coord.y)
        
        self.socket.emit("chat message", "123")
    }
    
    
     /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
 
}
