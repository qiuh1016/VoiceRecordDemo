//
//  ViewController.swift
//  VoiceRecordDemo
//
//  Created by qiuhong on 01/11/2016.
//  Copyright © 2016 CETCME. All rights reserved.
//

import UIKit
import AVFoundation

private let kMinRecordTime = 0.5

class RecordViewController: UIViewController, AVAudioRecorderDelegate {
    
    var audioRecorder: AVAudioRecorder!
    var audioPlayer: AVAudioPlayer!

    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var speakerSwitch: UISwitch!
    
    @IBOutlet weak var talkButton: UIButton!
    @IBOutlet weak var talkWave: UIImageView!
    
    var backColor: UIColor!
    
    var recordStartTime: TimeInterval!
    var recordStopTime: TimeInterval!
    
    var recordCancel = false
    
    var audioRecognizer = ARAudioRecognizer()
    
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
        recordButton.setTitleColor(UIColor.colorFromRGB(rgbValue: 0x000000, alpha: 0.6), for: .normal)
        
        audioRecognizer = ARAudioRecognizer.init(sensitivity: 0.7, frequency: 0.03)
        audioRecognizer.delegate = self
        
        defaultTransform = self.talkWave.transform
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
        
        if recordStopTime - recordStartTime < kMinRecordTime && !recordCancel {
            
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
        
        if recordStopTime - recordStartTime < kMinRecordTime && !recordCancel {
//            do {
//                try FileManager.default.removeItem(at: audioRecorder.url)
//            } catch {
//            }
            audioRecorder.deleteRecording()
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
        
        recordButton.backgroundColor = UIColor.colorFromRGB(rgbValue: 0x000000, alpha: 0.1)
        
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
        hudView.imageView.image = UIImage(named: "recall_2")
        hudView.label.backgroundColor = UIColor.colorFromRGB(rgbValue: 0xDF102A, alpha: 0.7)
    }
    
    @IBAction func touchDragInside(_ sender: AnyObject) {
        hudView.label.text = "Slide up to cancel"
        hudView.imageView.image = UIImage(named: "recordNoVolume")
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
    
    
    @IBAction func talkButtonTapped(_ sender: AnyObject) {
        if defaultTransform != nil {
            self.talkWave.transform = defaultTransform!
        }
    }
    
    var defaultTransform: CGAffineTransform?
    
    @IBAction func talkButtonTouchDown(_ sender: AnyObject) {
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
            self.talkWave.transform = self.talkWave.transform.scaledBy(x: 5.3, y: 5.3)
            }, completion: { Void in
                UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
                    self.talkWave.transform = self.talkWave.transform.scaledBy(x: 0.6, y: 0.6)
                    }, completion: { Void in
                        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
                            self.talkWave.transform = self.talkWave.transform.scaledBy(x: 1.6, y: 1.6)
                            }, completion: { Void in
                                UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
                                    self.talkWave.transform = self.defaultTransform!
                                    }, completion: nil)
                        })
                })
        })
    }

    
    
    

}

extension RecordViewController: ARAudioRecognizerDelegate {
    func audioRecognized(_ recognizer: ARAudioRecognizer!) {
        print("audioRecognized")
    }
    
    func audioLevelUpdated(_ recognizer: ARAudioRecognizer!, averagePower: Float, peakPower: Float) {
//        print("peakPower: \(peakPower + 50)")
        let peak = averagePower + 50
        
        let scale = Int(peak / 10)
        if scale > 0 {
            self.talkWave.transform = defaultTransform!
            UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseOut, animations: {
                self.talkWave.transform = self.talkWave.transform.scaledBy(x: CGFloat(scale) + 1, y: CGFloat(scale) + 1)
                }, completion: nil)
        }
        print(scale)
        
    }
    
//    func audioLevelUpdated(_ recognizer: ARAudioRecognizer!, level lowPassResults: Float) {
////        print("lowpassresultes: \(lowPassResults)")
//        let peak = lowPassResults
//        
//        var scale: CGFloat = 0
//        
//        
//        
//        if (peak > 0.8) {
//            scale = 6
//        } else if (peak > 0.6) {
//            scale = 5
//        } else if (peak > 0.4) {
//            scale = 4
//        } else if (peak > 0.2) {
//            scale = 3
//        } else if (peak > 0.1) {
//            scale = 2
//        } else{
//            scale = 1
//        }
//        
//        self.talkWave.transform = defaultTransform!
//        UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseOut, animations: {
//            self.talkWave.transform = self.talkWave.transform.scaledBy(x: scale, y: scale)
//            }, completion: nil)
//    }
}

