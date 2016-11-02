import UIKit

class HudView: UIView {
    var text = ""
    let activity = UIActivityIndicatorView()
    var label: UILabel!
    var imageView: UIImageView!
    var width: CGFloat?
  
    class func hudInView(view: UIView, animated: Bool) -> HudView {
        let hudView = HudView(frame: view.bounds)
        hudView.isOpaque = false
        view.addSubview(hudView)
        view.isUserInteractionEnabled = false
        hudView.showAnimated(animated: animated)
        return hudView
    }
  
    override func draw(_ rect: CGRect) {
        var boxWidth: CGFloat = 96
        var boxHeight: CGFloat = 96
        
        if let width = width {
            boxWidth = width
            boxHeight = width
        }
        
        let labelSpace: CGFloat = 7
        let labelAddHeight: CGFloat = 4
        
        let boxRect = CGRect(
          x: round((bounds.size.width - boxWidth) / 2),
          y: round((bounds.size.height - boxHeight) / 2),
          width: boxWidth,
          height: boxHeight)
        
        let roundedRect = UIBezierPath(roundedRect: boxRect, cornerRadius: 10)
        UIColor(white: 0.302, alpha: 0.8).setFill()
        roundedRect.fill()
       
        //进度指示器
        activity.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.whiteLarge
        activity.frame = CGRect(x: (center.x - 10), y: (center.y - 10 - boxHeight / 8), width: 20, height: 20)
//        self.addSubview(activity)
        
        
        
        
        //文字
        let attribs = [ NSFontAttributeName: UIFont.systemFont(ofSize: 14), NSForegroundColorAttributeName: UIColor.white ]
        let textSize = text.size(attributes: attribs)
//        let textPoint = CGPoint(
//          x: center.x - round(textSize.width / 2),
//          y: center.y - round(textSize.height / 2) + boxHeight / 4)
//        text.draw(at: textPoint, withAttributes: attribs)
        
        label = UILabel(frame: CGRect(x: center.x - boxWidth / 2 + labelSpace, y: center.y + boxHeight / 2 - labelSpace - textSize.height - labelAddHeight, width: boxWidth - labelSpace * 2, height: textSize.height + labelAddHeight))
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textColor = UIColor.colorFromRGB(rgbValue: 0xFFFFFF, alpha: 0.9)
        label.textAlignment = .center
        label.text = text
        label.layer.cornerRadius = textSize.height / 4
        label.layer.masksToBounds = true
        self.addSubview(label)
        
        
        //image view
        let imageWidth = (boxWidth - labelSpace * 2 - textSize.height) * 3 / 5
        imageView = UIImageView(frame: CGRect(x: center.x - imageWidth / 2, y: center.y - textSize.height / 2 - imageWidth / 2, width: imageWidth, height: imageWidth))
        imageView.image = UIImage(named: "recordNoVolume")
        imageView.contentMode = .scaleAspectFill
        self.addSubview(imageView)
    }
      
    func showAnimated(animated: Bool) {
        activity.startAnimating()
        activity.isHidden = false
        if animated {
            alpha = 0
            UIView.animate(withDuration: 0.3, animations: {
                self.alpha = 1
            })
        }
    }
        
    func hideAnimated(view: UIView,animated: Bool){
        activity.stopAnimating()
        if animated {
            alpha = 1
            UIView.animate(withDuration: 0.3, animations: {
                self.alpha = 0
            })
        }else{
            self.alpha = 0
        }
        view.isUserInteractionEnabled = true
    }
    
}


class OKView: UIView {
    var text = ""
    var imagename = "Checkmark"
    
    let activity = UIActivityIndicatorView()
    
    class func hudInView(view: UIView, animated: Bool) -> OKView {
        let hudView = OKView(frame: view.bounds)
        hudView.isOpaque = false
        view.addSubview(hudView)
        view.isUserInteractionEnabled = false
        hudView.showAnimated(animated: animated)
        return hudView
    }
    
    override func draw(_ rect: CGRect) {
        let boxWidth: CGFloat = 96
        let boxHeight: CGFloat = 96
        let boxRect = CGRect(
            x: round((bounds.size.width - boxWidth) / 2),
            y: round((bounds.size.height - boxHeight) / 2),
            width: boxWidth,
            height: boxHeight)
        let roundedRect = UIBezierPath(roundedRect: boxRect, cornerRadius: 10)
        UIColor(white: 0.3, alpha: 0.8).setFill()
        roundedRect.fill()
        if let image = UIImage(named: imagename) {
            let imagePoint = CGPoint(
                x: center.x - round(image.size.width / 2),
                y: center.y - round(image.size.height / 2) - boxHeight / 8)
            
            image.draw(at: imagePoint)
        }
        
        //文字
        let attribs = [ NSFontAttributeName: UIFont.systemFont(ofSize: 16),
                        NSForegroundColorAttributeName: UIColor.white ]
        let textSize = text.size(attributes: attribs)
        let textPoint = CGPoint(
            x: center.x - round(textSize.width / 2),
            y: center.y - round(textSize.height / 2) + boxHeight / 4)
        text.draw(at: textPoint, withAttributes: attribs)
    }
    
    func showAnimated(animated: Bool) {
        activity.startAnimating()
        activity.isHidden = false
        if animated {
            alpha = 0
            UIView.animate(withDuration: 0.3, animations: {
                self.alpha = 1
            })
        }
    }
    
    func hideAnimated(view: UIView,animated: Bool){
        activity.stopAnimating()
        if animated {
            alpha = 1
            transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: [], animations: {
                self.alpha = 0
                self.transform = CGAffineTransform(scaleX: 1, y: 1)//CGAffineTransformIdentity
                }, completion: nil)
        }else{
            self.alpha = 0
        }
        view.isUserInteractionEnabled = true
    }
    
    
}
