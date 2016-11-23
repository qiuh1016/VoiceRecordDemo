//
//  PTTViewController.swift
//  VoiceRecordDemo
//
//  Created by qiuhong on 23/11/2016.
//  Copyright © 2016 CETCME. All rights reserved.
//

import UIKit

let kButtonWidth: CGFloat = 35
let kButtonViewHeight: CGFloat = 100
let kButtonToContainerSpace: CGFloat = 16
let kTalkButtonToBottomSpace: CGFloat = 5
let kTalkButtonWidth: CGFloat = 68
let kTalkWaveWidth: CGFloat = 60

let kButtonViewBackgroundColor = UIColor.lightGray //UIColor.colorFromRGB(rgbValue: 0x000000, alpha: 0.3)
let kRecordViewBackgroundColor = UIColor.colorFromRGB(rgbValue: 0xB2D4FD, alpha: 1)  //UIColor.colorFromRGB(rgbValue: 0x9DB6DF, alpha: 1) //UIColor.green
let kStateLabelPrepareColor = UIColor.colorFromRGB(rgbValue: 0xFFD600, alpha: 1)
let kStateLabelSpeakColor = UIColor.colorFromRGB(rgbValue: 0x46FCBF, alpha: 1)

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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        width = self.view.bounds.width
        height = self.view.bounds.height

        initView()
        talkWaveDefaultTransform = self.talkWave.transform
        
        self.foldButton.transform = self.foldButton.transform.rotated(by: CGFloat(M_PI))
        self.recordView.center.y -= self.recordView.frame.height
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        buttonView.addSubview(stateLabel)
        
        self.view.addSubview(buttonView)
        
        //record view
        recordView = UIView(frame: CGRect(
            x: 0,
            y: buttonView.bounds.maxY,
            width: width,
            height: height - kButtonViewHeight))
        recordView.backgroundColor = kRecordViewBackgroundColor
        
        talkButton = UIButton(type: .custom)
        talkButton.frame = CGRect(
            x: (width - kTalkWaveWidth) / 2,
            y: recordView.frame.height - kTalkButtonWidth - kTalkButtonToBottomSpace,
            width: kTalkButtonWidth,
            height: kTalkButtonWidth)
        talkButton.setBackgroundImage(#imageLiteral(resourceName: "talk_button"), for: .normal)
        talkButton.addTarget(self, action: #selector(PTTViewController.talkButtonTouchDown), for: .touchDown)
        talkButton.addTarget(self, action: #selector(PTTViewController.talkButtonTouchUpInside), for: .touchUpInside)
        talkButton.addTarget(self, action: #selector(PTTViewController.talkButtonTouchUpInside), for: .touchUpOutside)
        recordView.addSubview(talkButton)
        
        talkWave = UIImageView(frame: CGRect(
            x: talkButton.frame.minX + (kTalkButtonWidth - kTalkWaveWidth) / 2,
            y: talkButton.frame.minY + (kTalkButtonWidth - kTalkWaveWidth) / 2,
            width: kTalkWaveWidth,
            height: kTalkWaveWidth))
        talkWave.image = #imageLiteral(resourceName: "talk_wave")
        recordView.addSubview(talkWave)
        recordView.bringSubview(toFront: talkButton)
        
        self.view.addSubview(recordView)
        self.view.bringSubview(toFront: buttonView)

    }
    
    func talkButtonTouchDown() {
        
        talkOver = false
        playSystemSound(name: "talkroom_begin", suffix: "mp3")
        
        //state label
        stateLabel.text = "Preparing..."
        stateLabel.textColor = kStateLabelPrepareColor
        afterDelay(0.4, closure: {
            if !self.talkOver {
                self.stateLabel.text = "Start speaking"
                self.stateLabel.textColor = kStateLabelSpeakColor
            }
        })
        
        //talk wave
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
            self.talkWave.transform = self.talkWave.transform.scaledBy(x: 7, y: 7)
            }, completion: { Void in
                UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
                    self.talkWave.transform = self.talkWaveDefaultTransform
                    }, completion: nil)
        })
    }

    func talkButtonTouchUpInside() {
        playSystemSound(name: "talkroom_press", suffix: "mp3")
        talkOver = true
        stateLabel.text = "Press button to speak"
        stateLabel.textColor = UIColor.white
    }
    
    func foldButtonTapped() {
        
        UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseOut, animations: {
            self.foldButton.transform = self.foldButton.transform.rotated(by: CGFloat(M_PI))
            if self.isRecordViewEnable {
                self.recordView.center.y -= self.recordView.frame.height
            } else {
                self.recordView.center.y += self.recordView.frame.height
            }
            }, completion: { Void in
                self.isRecordViewEnable = !self.isRecordViewEnable
        })
    }
    
    func shutButtonTapped() {
        self.isShuted = !self.isShuted
        self.shutButton.setBackgroundImage(isShuted ? #imageLiteral(resourceName: "shut_button_red") : #imageLiteral(resourceName: "shut_button_green"), for: .normal)
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
