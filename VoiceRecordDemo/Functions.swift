//
//  Functions.swift
//  huilvchaxun
//
//  Created by qiuhong on 11/24/15.
//  Copyright © 2015 qiuhhong. All rights reserved.
//

import Foundation
import Dispatch
import UIKit
import CoreLocation
import AVFoundation

//实际位置需加上dCoordinate
let dCoordinate: CLLocationCoordinate2D = CLLocationCoordinate2D.init(latitude: -0.00193 , longitude: 0.00416)

let PI = 3.14159265358979323846
let EARTH_RADIUS = 6378.137

let screenW = UIScreen.main.bounds.width
let screenH = UIScreen.main.bounds.height

let defaults = UserDefaults.standard

//func afterDelay(seconds: Double, closure: () -> ()) {
////    let when = DispatchTime(dispatch_time_t(DispatchTime.now), Int64(seconds * Double(NSEC_PER_SEC)))
//    let delayTime = dispatch_time(DispatchTime.now(), Int64(seconds * Double(NSEC_PER_SEC)))
//    dispatch_after(delayTime, dispatch_get_main_queue(), closure)
////    
//    
////    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3.0, closure)
//}

func afterDelay(_ delay: Double, closure: @escaping () -> ()) {
    let when = DispatchTime.now() + delay
    DispatchQueue.main.asyncAfter(deadline: when, execute: closure)
}

func alertView(title: String, message: String, okActionTitle: String, cancleActionTitle: String, okHandler: ((_ action: UIAlertAction?) -> Void)?, viewController: UIViewController){
    let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
    let cancelAction = UIAlertAction(title: cancleActionTitle, style: UIAlertActionStyle.cancel, handler: nil)
    let okAction = UIAlertAction(title: okActionTitle, style: UIAlertActionStyle.default, handler: okHandler)
    alert.addAction(cancelAction)
    alert.addAction(okAction)
    viewController.present(alert, animated: true, completion: nil)
}

func alertView(title: String, message: String, okActionTitle: String, okHandler: ((_ action: UIAlertAction?) -> Void)?, viewController: UIViewController){
    let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
    let okAction = UIAlertAction(title: okActionTitle, style: UIAlertActionStyle.default, handler: okHandler)
    alert.addAction(okAction)
    viewController.present(alert, animated: true, completion: nil)
}

func realLocation(locations: [CLLocationCoordinate2D]) -> [CLLocationCoordinate2D]{
    var realLocations = [CLLocationCoordinate2D]()
    for location in locations{
        let realLocation: CLLocationCoordinate2D = CLLocationCoordinate2D.init(latitude: location.latitude + dCoordinate.latitude, longitude: location.longitude + dCoordinate.longitude)
        realLocations.append(realLocation)
    }
    return realLocations
}

func realLocation(location: CLLocationCoordinate2D) -> CLLocationCoordinate2D{
    let realLocation: CLLocationCoordinate2D = CLLocationCoordinate2D.init(latitude: location.latitude + dCoordinate.latitude, longitude: location.longitude + dCoordinate.longitude)
    return realLocation
}

func playSystemSound(){
    var soundID:SystemSoundID = 0
    let path = Bundle.main.path(forResource: "noticeMusic", ofType: "wav")
    let baseURL = NSURL(fileURLWithPath: path!)
    AudioServicesCreateSystemSoundID(baseURL, &soundID)
    AudioServicesPlaySystemSound(soundID)
}

func showDate() -> String {
    let timeFormatter = DateFormatter()
    timeFormatter.dateFormat = "YYYY-MM-dd" //"YYYY-MM-dd HH:mm"
    let date = timeFormatter.string(from: NSDate() as Date)
    return date
}

func isTelNumber(num: NSString) -> Bool {
    let mobile = "^1(3[0-9]|5[0-35-9]|8[025-9])\\d{8}$"
    let CM = "^1(34[0-8]|(3[5-9]|5[017-9]|8[278])\\d)\\d{7}$"
    let CU = "^1(3[0-2]|5[256]|8[56])\\d{8}$"
    let CT = "^1((33|53|8[09])[0-9]|349)\\d{7}$"
    let regextestmobile = NSPredicate(format: "SELF MATCHES %@",mobile)
    let regextestcm = NSPredicate(format: "SELF MATCHES %@",CM )
    let regextestcu = NSPredicate(format: "SELF MATCHES %@" ,CU)
    let regextestct = NSPredicate(format: "SELF MATCHES %@" ,CT)
    if ((regextestmobile.evaluate(with: num) == true)
        || (regextestcm.evaluate(with: num)  == true)
        || (regextestct.evaluate(with: num) == true)
        || (regextestcu.evaluate(with: num) == true)) {
        return true
    } else {
        return false
    }
}

extension UIColor {
    
    class func colorFromRGB(rgbValue: UInt, alpha: CGFloat) -> UIColor {
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: alpha
        )
    }
    
    class func RGBColor(red: Double, green: Double, blue: Double, alpha: Double) -> UIColor {
        return UIColor(red: CGFloat(red / 255), green: CGFloat(green / 255), blue: CGFloat(blue / 255), alpha: CGFloat(alpha))
    }
}

extension String {
    subscript (r: Range<Int>) -> String {
        get {
            let index_end = self.index(startIndex, offsetBy: r.upperBound)
            var str = self.substring(to: index_end)
            
            let index_start = self.index(startIndex, offsetBy: r.lowerBound)
            str = str.substring(from: index_start)
            
            return str //self[startIndex ..< endIndex]
        }
    }
}

func makeRoundedCorner(view: UIView, corners: UIRectCorner, cornerRadii: CGSize) {
    let maskPath = UIBezierPath.init(roundedRect: view.bounds, byRoundingCorners: corners, cornerRadii: cornerRadii)
    let maskLayer = CAShapeLayer()
    maskLayer.frame = view.bounds
    maskLayer.path = maskPath.cgPath
    view.layer.mask = maskLayer
}

func iPhone4() -> Bool {
    let height = UIScreen.main.bounds.size.height
    return height == 480
}

func iPhone5() -> Bool {
    let height = UIScreen.main.bounds.size.height
    return height == 568
}

func iPhone6() -> Bool {
    let height = UIScreen.main.bounds.size.height
    return height == 667
}

func iPhone6P() -> Bool {
    let height = UIScreen.main.bounds.size.height
    return height == 736
}

enum iPhoneType : Int{
    case iPhone4 = 480
    case iPhone5 = 568
    case iPhone6 = 667
    case iPhone6P = 736
}
