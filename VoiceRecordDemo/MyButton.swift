//
//  MyButton.swift
//  VoiceRecordDemo
//
//  Created by qiuhong on 02/11/2016.
//  Copyright © 2016 CETCME. All rights reserved.
//

import UIKit

@IBDesignable
class MyButton: UIButton {

    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        self.layer.cornerRadius = rect.height / 5
        
        self.layer.borderColor = UIColor.lightGray.cgColor
        self.layer.borderWidth = 1 / 2
        
        self.layer.masksToBounds = true
    }
    

}
