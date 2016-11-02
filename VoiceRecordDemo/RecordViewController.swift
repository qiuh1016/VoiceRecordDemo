//
//  ViewController.swift
//  VoiceRecordDemo
//
//  Created by qiuhong on 01/11/2016.
//  Copyright © 2016 CETCME. All rights reserved.
//

import UIKit
import AVFoundation

class RecordViewController: UIViewController {
    
    var audioRecorder: AVAudioRecorder!
    var audioPlayer: AVAudioPlayer!

    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var speakerSwitch: UISwitch!
    
    var backColor: UIColor!
    
    var recordStartTime: TimeInterval!
    var recordStopTime: TimeInterval!
    
    var recordCancel = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let authStatus = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeAudio)
        if authStatus == .notDetermined {
            print("未申请")
        } else if authStatus == .denied || authStatus == .restricted{
            print("拒绝，引导开启")
        } else if authStatus == .authorized {
            print("有权限")
        }
        
        backColor = recordButton.backgroundColor
        
    }
    
    func directoryURL() -> URL? {
        
        //根据时间设置存储文件名
        let currentDateTime = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMddHHmmss"
        let recordingName = formatter.string(from: currentDateTime) + ".caf"
        print(recordingName)
        
        let fileManager = FileManager.default
        let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirectory = urls[0] as NSURL
        let soundURL = documentDirectory.appendingPathComponent(recordingName)//将音频文件名称追加在可用路径上形成音频文件的保存路径
        
        return soundURL
    }
    
    func startRecord() {
        
        recordStartTime = Date().timeIntervalSince1970
        
        let recordSettings = [
            AVSampleRateKey : NSNumber(value: Float(44100.0)),//声音采样率
            AVFormatIDKey : NSNumber(value: Int32(kAudioFormatMPEG4AAC)),//编码格式
            AVNumberOfChannelsKey : NSNumber(value: 1),//采集音轨
            AVEncoderAudioQualityKey : NSNumber(value: Int32(AVAudioQuality.medium.rawValue))]//音频质量
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try audioRecorder = AVAudioRecorder(url: self.directoryURL()!, settings: recordSettings)//初始化实例
            audioRecorder.prepareToRecord()//准备录音
        } catch {
        }
        
        if !audioRecorder.isRecording {//判断是否正在录音状态
            let audioSession = AVAudioSession.sharedInstance()
            do {
                try audioSession.setActive(true)
                audioRecorder.record()
                print("record!")
            } catch {
            }
        }
    }
    
    func stopRecord() {
        
        recordStopTime = Date().timeIntervalSince1970
        
        if recordStopTime - recordStartTime < 1 && !recordCancel {
            
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            let alert = UIAlertController(title: "提示", message: "录制时间太短，未能保存文件!", preferredStyle: .alert)
            alert.addAction(okAction)
            present(alert, animated: true, completion: nil)
            
            
        }
        
        audioRecorder.stop()
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setActive(false)
            print("stop!!")
        } catch {
        }
        
        if recordStopTime - recordStartTime < 1 && !recordCancel {
            do {
                try FileManager.default.removeItem(at: audioRecorder.url)
            } catch {
            }
        }
        
//        if recordStopTime - recordStartTime < 1 && !recordCancel {
//            
//            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
//            let alert = UIAlertController(title: "提示", message: "录制时间太短，未能保存文件!", preferredStyle: .alert)
//            alert.addAction(okAction)
//            present(alert, animated: true, completion: nil)
//            
//            do {
//                try FileManager.default.removeItem(at: audioRecorder.url)
//            } catch {
//            }
//        }

    }
    
    @IBAction func startPlaying(_ sender: AnyObject) {
        if (!audioRecorder.isRecording){
            do {
                try audioPlayer = AVAudioPlayer(contentsOf: audioRecorder.url)
                //切换扬声器和听筒
                if speakerSwitch.isOn {
                    try AVAudioSession().setCategory(AVAudioSessionCategoryPlayback)
                } else {
                    try AVAudioSession().setCategory(AVAudioSessionCategoryPlayAndRecord)
                }
                audioPlayer.play()
                print("play!!")
            } catch {
            }
        }
    }
    
    @IBAction func pausePlaying(_ sender: AnyObject) {
        if (!audioRecorder.isRecording){
            do {
                try audioPlayer = AVAudioPlayer(contentsOf: audioRecorder.url)
                audioPlayer.pause()
                print("pause!!")
            } catch {
            }
        }
    }
    
    var hudView: HudView!

    @IBAction func touchDown(_ sender: AnyObject) {
        
        hudView = HudView.hudInView(view: self.view, animated: false)
        hudView.text = "Slide up to cancel"
        hudView.width = self.view.bounds.width * 2 / 5
        
        recordButton.backgroundColor = UIColor.lightGray
        
//        startRecord()
        Thread(target: self, selector: #selector(RecordViewController.startRecord), object: nil).start()
    }
    
    @IBAction func touchUpInside(_ sender: AnyObject) {
        
        
        
        hudView.hideAnimated(view: self.view, animated: false)
        
        recordButton.backgroundColor = backColor
        
//        stopRecord()
        recordCancel = false
        Thread(target: self, selector: #selector(RecordViewController.stopRecord), object: nil).start()
    }
    
    @IBAction func touchDragExit(_ sender: AnyObject) {
        hudView.label.text = "Release to cancel"
        hudView.imageView.image = UIImage(named: "recall")
        hudView.label.backgroundColor = UIColor.red
    }
    
    @IBAction func touchDragInside(_ sender: AnyObject) {
        hudView.label.text = "Slide up to cancel"
        hudView.imageView.image = UIImage(named: "record")
        hudView.label.backgroundColor = UIColor.clear
    }
    
    @IBAction func touchUpOutside(_ sender: AnyObject) {
        hudView.hideAnimated(view: self.view, animated: false)
        
        recordButton.backgroundColor = backColor
        
        recordCancel = true
        Thread(target: self, selector: #selector(RecordViewController.stopRecord), object: nil).start()
        
        do {
            try FileManager.default.removeItem(at: audioRecorder.url)
        } catch {
        }
        
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "filesSegue" {
            let vc = segue.destination as! FilesTableViewController
            vc.speakerSwitchIsOn = speakerSwitch.isOn
        }
    }
    
    


}

