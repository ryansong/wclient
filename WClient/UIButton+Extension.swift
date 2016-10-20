//
//  UIButton+Extension.swift
//  WClient
//
//  Created by xiaomingsong on 10/18/16.
//  Copyright © 2016 Song Xiaoming. All rights reserved.
//

import Foundation

extension UIButton {
    func set(title:String) -> Void {
        self.setTitle(title, for: .normal)
    }
    
    func set(color:UIColor) -> Void {
        self.setTitleColor(color, for: .normal)
    }
}
