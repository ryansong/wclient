//
//  UIView+Extension.swift
//  WClient
//
//  Created by xiaomingsong on 10/14/16.
//  Copyright © 2016 Song Xiaoming. All rights reserved.
//

import Foundation

extension UIView {
    func setCorner(radius:Float) -> Void {
        let path:UIBezierPath = UIBezierPath.init(roundedRect: self.bounds, cornerRadius: CGFloat(radius))
        let shaper = CAShapeLayer()
        shaper.frame = self.bounds
        shaper.path = path.cgPath
        shaper.rasterizationScale = UIScreen.main.scale
        self.layer.mask = shaper
    }
}
