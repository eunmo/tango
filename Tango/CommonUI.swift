//
//  CommonUI.swift
//  Tango
//
//  Created by Eunmo Yang on 6/14/18.
//  Copyright © 2018 Eunmo Yang. All rights reserved.
//

import UIKit

class CommonUI {
    static let red = UIColor.systemRed
    static let orange = UIColor.systemOrange
    static let yellow = UIColor.systemYellow
    static let green = UIColor.systemGreen
    static let blue = UIColor.systemBlue
    
    static func setViewMask(view: UIView, isHollow: Bool) {
        let width = view.bounds.width
        let height = view.bounds.height
        let radius: CGFloat = 25
        let diameter = radius * 2
        let borderWidth: CGFloat = 10
        
        let path = UIBezierPath(roundedRect: view.bounds, cornerRadius: radius)
        
        if (isHollow) {
            let innerRect = CGRect(x: borderWidth, y: borderWidth, width: width - 2 * borderWidth, height: height - 2 * borderWidth)
            let innerPath = UIBezierPath(roundedRect: innerRect, cornerRadius: radius - borderWidth)
            path.append(innerPath)
            
            let rect = CGRect(x: width / 2 - radius, y: height / 2 - radius, width: diameter, height: diameter)
            let circlePath  = UIBezierPath(ovalIn: rect)
            path.append(circlePath)
        }
        
        let maskLayer = CAShapeLayer()
        maskLayer.frame = view.bounds
        maskLayer.fillRule = CAShapeLayerFillRule.evenOdd
        maskLayer.path = path.cgPath
        
        view.layer.mask = maskLayer
    }
}
