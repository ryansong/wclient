//
//  UIColor+Extension.swift
//  WClient
//
//  Created by xiaomingsong on 10/13/16.
//  Copyright © 2016 Song Xiaoming. All rights reserved.
//

import Foundation

extension UIColor {
    static func color(with hexValue:Int) -> UIColor {
        
        let hex:CGFloat = 255
        
        return UIColor.init(red: ((CGFloat)((hexValue & 0xFF0000) >> 16))/hex,
                            green: ((CGFloat)((hexValue & 0xFF00) >> 16)) / hex,
                            blue: ((CGFloat)((hexValue & 0xFF) >> 16)) / hex,
                            alpha: 1.0)
    }
}
