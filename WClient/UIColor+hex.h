//
//  UIColor+hex.h
//  WClient
//
//  Created by Song Xiaoming on 13-11-30.
//  Copyright (c) 2013年 Song Xiaoming. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (hex)

+ (UIColor *) colorWithHex:(NSInteger)hexValue alpha:(CGFloat)alphaValue;
+ (UIColor *) ColorWithHex:(NSInteger)hexValue;
@end
