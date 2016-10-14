//
//  NSString+Extension.swift
//  WClient
//
//  Created by xiaomingsong on 10/13/16.
//  Copyright © 2016 Song Xiaoming. All rights reserved.
//

import Foundation


extension String {
    
    func attributedTwitter(of context:String, color:UIColor?, font:UIFont) -> NSAttributedString {
        let attStr = NSMutableAttributedString.init(string: self);
        var textColor = color
        
        if (textColor == nil) {
            textColor = UIColor.color(with:0x3498DB);
        }
        
//        var range = NSMakeRange(NSNotFound, NSNotFound);
//        var local:Int = 0
//        var muText = context
//        let regEx = ALABEL_EXPRESSION
        
        return attStr
    }

    
}
