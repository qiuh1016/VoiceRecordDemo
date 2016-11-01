//
//  ViewController.swift
//  VoiceRecordDemo
//
//  Created by qiuhong on 01/11/2016.
//  Copyright © 2016 CETCME. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    var audioRecorder: AVAudioRecorder!
    var audioPlayer: AVAudioPlayer!

    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var speakerSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
          }
    
    func directoryURL() -> URL? {
        
        //根据时间设置存储文件名
        let currentDateTime = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "ddMMyyyyHHmmss"
        let recordingName = formatter.string(from: currentDateTime) + ".caf"
        print(recordingName)
        
        let fileManager = FileManager.default
        let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirectory = urls[0] as NSURL
        let soundURL = documentDirectory.appendingPathComponent(recordingName)//将音频文件名称追加在可用路径上形成音频文件的保存路径
        
        return soundURL
    }

    @IBAction func startRecord(_ sender: AnyObject) {
        startRecord()
    }
    
    func startRecord() {
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
    
    @IBAction func stopRecord(_ sender: AnyObject) {
        stopRecord()
    }
    
    func stopRecord() {
        audioRecorder.stop()
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setActive(false)
            print("stop!!")
        } catch {
        }

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
        startRecord()
        hudView = HudView.hudInView(view: self.view, animated: false)
        hudView.text = "Slide up to cancel"
        hudView.width = self.view.bounds.width * 2 / 5
    }
    
    @IBAction func touchUpInside(_ sender: AnyObject) {
        stopRecord()
        hudView.hideAnimated(view: self.view, animated: false)
    }
    
    @IBAction func touchDragExit(_ sender: AnyObject) {
        hudView.label.text = "Release to cancel"
        hudView.label.backgroundColor = UIColor.red
    }
    
    @IBAction func touchDragInside(_ sender: AnyObject) {
        hudView.label.text = "Slide up to cancel"
        hudView.label.backgroundColor = UIColor.clear
    }
    
    @IBAction func touchUpOutside(_ sender: AnyObject) {
        hudView.hideAnimated(view: self.view, animated: false)
        stopRecord()
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

