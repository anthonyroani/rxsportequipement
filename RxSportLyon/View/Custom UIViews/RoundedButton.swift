//
//  RoundedButton.swift
//  RxSportLyon
//
//  Created by Anthony Roani on 20/02/2019.
//  Copyright © 2019 Anthony Roani. All rights reserved.
//

import UIKit

@IBDesignable
class RoundedButton : UIButton {
    
    var imageWidthConstraint : NSLayoutConstraint!
    var imageHeightConstraint : NSLayoutConstraint!
    
    @IBInspectable var imageWidth: CGFloat = 16.0 {
        didSet {
            imageWidthConstraint.constant = imageWidth
        }
    }
    
    @IBInspectable var imageHeight : CGFloat = 16.0 {
        didSet {
            imageHeightConstraint.constant = imageHeight
        }
    }
    
    @IBInspectable var imageOpacity : Float = 1.0 {
        didSet {
            rightImageView?.layer.opacity = imageOpacity
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
            layer.masksToBounds = cornerRadius > 0
        }
    }
    
    @IBInspectable var borderColor: UIColor = .clear {
        didSet {
            layer.borderColor = borderColor.cgColor
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 0.0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable var highlightColor : UIColor = UIColor.white {
        didSet {
            UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
            UIGraphicsGetCurrentContext()!.setFillColor(highlightColor.cgColor)
            UIGraphicsGetCurrentContext()!.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
            let colorImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            setBackgroundImage(colorImage, for: state)
        }
    }
    
    var rightImageView : UIImageView? = nil
    
    @IBInspectable var rightImageName: String = ""  {
        didSet {
            
            // Constraints to the view
            rightImageView = UIImageView()
            rightImageView!.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview(rightImageView!)
            
            let trailingConstraint = NSLayoutConstraint(item: rightImageView!, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: -10)
            let centerVerticallyConstraint = NSLayoutConstraint(item: rightImageView!, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0)
            imageHeightConstraint = NSLayoutConstraint(item:rightImageView!, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: imageHeight)
            imageWidthConstraint = NSLayoutConstraint(item:rightImageView!, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: imageWidth)
            
            self.addConstraints([trailingConstraint, centerVerticallyConstraint ,imageHeightConstraint, imageWidthConstraint])
            
            rightImageView!.image = UIImage(named: rightImageName)
            rightImageView!.tintColor = UIColor.white
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.layer.masksToBounds = false
    }
    
}
