//
//  PTTViewController.swift
//  VoiceRecordDemo
//
//  Created by qiuhong on 23/11/2016.
//  Copyright © 2016 CETCME. All rights reserved.
//

import UIKit
import AVFoundation

private let kButtonWidth: CGFloat = 35
private let kButtonViewHeight: CGFloat = 100
private let kButtonToContainerSpace: CGFloat = 16
private let kTalkButtonToBottomSpace: CGFloat = 5
private let kTalkButtonWidth: CGFloat = 68
private let kTalkWaveWidth: CGFloat = 60

private let kButtonViewBackgroundColor = UIColor.lightGray   //UIColor.colorFromRGB(rgbValue: 0x000000, alpha: 0.2)
private let kRecordViewBackgroundColor = UIColor.colorFromRGB(rgbValue: 0xB2D4FD, alpha: 1)  //UIColor.colorFromRGB(rgbValue: 0x9DB6DF, alpha: 1) //UIColor.green
private let kStateLabelPrepareColor = UIColor.colorFromRGB(rgbValue: 0xFFD600, alpha: 1)
private let kStateLabelSpeakColor = UIColor.colorFromRGB(rgbValue: 0x46FCBF, alpha: 1)

private let kMinRecordTime = 0.5

class PTTViewController: UIViewController {
    
    var shutButton: UIButton!
    var foldButton: UIButton!
    var talkButton: UIButton!
    var talkWave:   UIImageView!
    var recordView: UIView!
    var stateLabel: UILabel!
    
    var width: CGFloat!
    var height: CGFloat!
    
    var isRecordViewEnable = false
    var isShuted = false
    var talkOver = false
    
    var talkWaveDefaultTransform: CGAffineTransform!
    
    var recordStartTime: TimeInterval!
    var recordStopTime: TimeInterval!
    
    var audioRecorder: AVAudioRecorder!
    var audioPlayer: AVAudioPlayer!
    
    var detectTimer: Timer?
    
    var voiceWaveView: YSCNewVoiceWaveView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let authStatus = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeAudio)
        if authStatus == .notDetermined {
            print("未申请")
        } else if authStatus == .denied || authStatus == .restricted{
            print("拒绝，引导开启")
        } else if authStatus == .authorized {
            print("有权限")
        }
        
        width = self.view.bounds.width
        height = self.view.bounds.height

        initView()
        talkWaveDefaultTransform = self.talkWave.transform
        
        self.foldButton.transform = self.foldButton.transform.rotated(by: CGFloat(M_PI))
        self.recordView.center.y -= self.recordView.frame.height
        
    }

    func initView() {
        
        //button view
        let buttonView = UIView(frame: CGRect(x: 0, y: 0, width: width, height: kButtonViewHeight))
        buttonView.backgroundColor = kButtonViewBackgroundColor
        
        shutButton = UIButton(type: .custom)
        shutButton.setBackgroundImage(#imageLiteral(resourceName: "shut_button_green"), for: .normal)
        shutButton.frame = CGRect(
            x: kButtonToContainerSpace,
            y: (kButtonViewHeight - kButtonWidth) / 2 + kButtonToContainerSpace,
            width: kButtonWidth,
            height: kButtonWidth)
        shutButton.addTarget(self, action: #selector(PTTViewController.shutButtonTapped), for: .touchUpInside)
        buttonView.addSubview(shutButton)
        
        foldButton = UIButton(type: .custom)
        foldButton.setBackgroundImage(#imageLiteral(resourceName: "fold_button"), for: .normal)
        foldButton.frame = CGRect(
            x: width - kButtonToContainerSpace - kButtonWidth,
            y: (kButtonViewHeight - kButtonWidth) / 2 + kButtonToContainerSpace,
            width: kButtonWidth,
            height: kButtonWidth)
        foldButton.addTarget(self, action: #selector(PTTViewController.foldButtonTapped), for: .touchUpInside)
        buttonView.addSubview(foldButton)
        
        stateLabel = UILabel(frame: CGRect(
            x: shutButton.frame.maxX + 10,
            y: shutButton.frame.minY,
            width: foldButton.frame.minX - shutButton.frame.maxX - 20,
            height: shutButton.frame.height))
        stateLabel.font = UIFont.boldSystemFont(ofSize: 14)
        stateLabel.text = "Press button to speak"
        stateLabel.textColor = UIColor.white
        stateLabel.textAlignment = .center
        stateLabel.alpha = 0
        buttonView.addSubview(stateLabel)
        
        self.view.addSubview(buttonView)
        
        //record view
        recordView = UIView(frame: CGRect(
            x: 0,
            y: buttonView.bounds.maxY,
            width: width,
            height: height - kButtonViewHeight))
        recordView.backgroundColor = kRecordViewBackgroundColor
        self.view.addSubview(recordView)
        self.view.bringSubview(toFront: buttonView)
        
        talkButton = UIButton(type: .custom)
        talkButton.frame = CGRect(
            x: (width - kTalkWaveWidth) / 2,
            y: recordView.frame.height - kTalkButtonWidth - kTalkButtonToBottomSpace,
            width: kTalkButtonWidth,
            height: kTalkButtonWidth)
        talkButton.setBackgroundImage(#imageLiteral(resourceName: "talk_button"), for: .normal)
        talkButton.addTarget(self, action: #selector(PTTViewController.talkButtonTouchDown), for: .touchDown)
        talkButton.addTarget(self, action: #selector(PTTViewController.talkButtonTouchUpInsideAndOutside), for: .touchUpInside)
        talkButton.addTarget(self, action: #selector(PTTViewController.talkButtonTouchUpInsideAndOutside), for: .touchUpOutside)
        recordView.addSubview(talkButton)
        
        talkWave = UIImageView(frame: CGRect(
            x: talkButton.frame.minX + (kTalkButtonWidth - kTalkWaveWidth) / 2,
            y: talkButton.frame.minY + (kTalkButtonWidth - kTalkWaveWidth) / 2,
            width: kTalkWaveWidth,
            height: kTalkWaveWidth))
        talkWave.image = #imageLiteral(resourceName: "talk_wave")
        recordView.addSubview(talkWave)
        recordView.bringSubview(toFront: talkButton)
        
        //voice wave 
        let voiceWaveParentView = UIView(frame: CGRect(x: 0, y: (recordView.bounds.height - 320 - kTalkWaveWidth) / 2, width: width, height: 320))
        recordView.addSubview(voiceWaveParentView)
        
        voiceWaveView = YSCNewVoiceWaveView()
        voiceWaveView.setVoiceWaveNumber(6)
        voiceWaveView.show(inParentView: voiceWaveParentView)
        voiceWaveView.backgroundColor = UIColor.clear
        voiceWaveView.startVoiceWave()
        
        
        let updateVolumeTimer = Timer(timeInterval: 0.1, target: self, selector: #selector(PTTViewController.updateVolume), userInfo: nil, repeats: true)
        RunLoop.current.add(updateVolumeTimer, forMode: .commonModes)
        
        
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
            try audioSession.setCategory(AVAudioSessionCategoryRecord)   //AVAudioSessionCategoryPlayAndRecord
            try audioRecorder = AVAudioRecorder(url: self.directoryURL()!, settings: recordSettings)//初始化实例
            audioRecorder.prepareToRecord()//准备录音
            audioRecorder.isMeteringEnabled = true
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
        
        self.stateLabel.text = "Start speaking"
        self.stateLabel.textColor = kStateLabelSpeakColor
  
    }

    func stopRecord() {
        
        
        
        audioRecorder.stop()
        audioRecorder = nil
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            playSystemSound(name: "talkroom_press", suffix: "mp3")
        } catch  {
            
        }
        
        print("timer invalidate")
        
        detectTimer?.invalidate()
        detectTimer = nil
        
//        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
//            self.talkWave.transform = self.talkWaveDefaultTransform
//            }, completion: nil)
        
//        recordStopTime = Date().timeIntervalSince1970
        
//        if recordStopTime - recordStartTime < kMinRecordTime {
//            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
//            let alert = UIAlertController(title: "提示", message: "录制时间太短，未能保存文件!", preferredStyle: .alert)
//            alert.addAction(okAction)
//            present(alert, animated: true, completion: nil)
//        }
        
        
//        let audioSession = AVAudioSession.sharedInstance()
//        do {
//            try audioSession.setActive(false)
//            print("stop!!")
//            
//        } catch {
//        }
        
//        if recordStopTime - recordStartTime < kMinRecordTime {
//            audioRecorder.deleteRecording()
//        }
        
        
        
        
        
        
    }
    
    func startPlaying() {
        if (!audioRecorder.isRecording){
            do {
                try audioPlayer = AVAudioPlayer(contentsOf: audioRecorder.url)
                try AVAudioSession().setCategory(AVAudioSessionCategoryPlayback) //扬声器播放 听筒：try AVAudioSession().setCategory(AVAudioSessionCategoryPlayAndRecord)
                audioPlayer.play()
                print("play!!")
            } catch {
            }
        }
    }
    
    func pausePlaying() {
        if (!audioRecorder.isRecording){
            do {
                try audioPlayer = AVAudioPlayer(contentsOf: audioRecorder.url)
                audioPlayer.pause()
                print("pause!!")
            } catch {
            }
        }
    }

    func talkButtonTouchDown() {
        
        //state label
        stateLabel.text = "Preparing..."
        stateLabel.textColor = kStateLabelPrepareColor
//        afterDelay(0.3, closure: {
//            if !self.talkOver {
//                self.stateLabel.text = "Start speaking"
//                self.stateLabel.textColor = kStateLabelSpeakColor
//            }
//        })
    
        //sound
        playSystemSound(name: "talkroom_press", suffix: "mp3")
        afterDelay(0.2, closure: {
            playSystemSound(name: "talkroom_begin", suffix: "mp3")
        })
        
        afterDelay(0.4, closure: {
            Thread(target: self, selector: #selector(PTTViewController.startRecord), object: nil).start()
        })
        
        
//        detectTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(PTTViewController.updateVolume), userInfo: nil, repeats: true)
//        detectTimer!.fire()
//        
        talkOver = false


        
        //test talk wave
//        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
//            self.talkWave.transform = self.talkWave.transform.scaledBy(x: 7, y: 7)
//            }, completion: { Void in
//                UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
//                    self.talkWave.transform = self.talkWaveDefaultTransform
//                    }, completion: nil)
//        })
    }
    

    func talkButtonTouchUpInsideAndOutside() {
        playSystemSound(name: "talkroom_press", suffix: "mp3")
        
        Thread(target: self, selector: #selector(PTTViewController.stopRecord), object: nil).start()
        
        talkOver = true
        stateLabel.text = "Press button to speak"
        stateLabel.textColor = UIColor.white
    }
    
    var lastScale: CGFloat = 1
    
    func updateVolume() {
        
        
        if audioRecorder != nil {
            audioRecorder.updateMeters()
            
            let normalizedValue = pow(10, self.audioRecorder.averagePower(forChannel: 0) / 20)
            self.voiceWaveView.changeVolume(CGFloat(normalizedValue))
            
            print(normalizedValue)
            
            //            let averagePower = audioRecorder.averagePower(forChannel: 0)
            //            let peakPower = audioRecorder.averagePower(forChannel: 0)
            //            let scale = Int((peakPower + 160) / 16) - 2
            //
            //
            //            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
            //                self.talkWave.transform = self.talkWave.transform.scaledBy(x: CGFloat(scale) / self.lastScale, y: CGFloat(scale) / self.lastScale)
            //                }, completion: { Void in
            //                    self.lastScale = CGFloat(scale)
            //            })
            ////            print("averagePower: \(averagePower), peakPower: \(peakPower)")
            //            print("scale: \(scale)")
            
        }
        
    }

    
    func foldButtonTapped() {
        
        UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseOut, animations: {
            self.foldButton.transform = self.foldButton.transform.rotated(by: CGFloat(M_PI))
            if self.isRecordViewEnable {
                self.recordView.center.y -= self.recordView.frame.height
                self.stateLabel.alpha = 0
            } else {
                self.recordView.center.y += self.recordView.frame.height
                self.stateLabel.alpha = 1
            }
            }, completion: { Void in
                self.isRecordViewEnable = !self.isRecordViewEnable
        })
    }
    
    func shutButtonTapped() {
        self.isShuted = !self.isShuted
        self.shutButton.setBackgroundImage(isShuted ? #imageLiteral(resourceName: "shut_button_red") : #imageLiteral(resourceName: "shut_button_green"), for: .normal)
    }

    
    func playSound(name: String, suffix: String) {
        do {
            let path = Bundle.main.path(forResource: name, ofType: suffix)
            let baseURL = URL(fileURLWithPath: path!)
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try audioPlayer = AVAudioPlayer(contentsOf: baseURL)
        } catch {
        }
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
