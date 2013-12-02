//
//  UIColor+hex.m
//  WClient
//
//  Created by Song Xiaoming on 13-11-30.
//  Copyright (c) 2013年 Song Xiaoming. All rights reserved.
//

#import "UIColor+hex.h"

@implementation UIColor (hex)

+ (UIColor *)colorWithHex:(NSInteger )hexValue alpha:(CGFloat)alphaValue
{
    return [UIColor colorWithRed:((float)((hexValue & 0xFF0000) >> 16))/255.0
                            green:((float)((hexValue & 0xFF00) >> 8))/255.0
                             blue:(float)(hexValue & 0xFF)/255.0 alpha:alphaValue];
}

+ (UIColor *)ColorWithHex:(NSInteger)hexValue
{
    return [UIColor colorWithHex:hexValue alpha:1.0];
}
@end