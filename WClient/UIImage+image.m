//
//  UIImage+image.m
//  WClient
//
//  Created by Song Xiaoming on 4/12/15.
//  Copyright (c) 2015 Song Xiaoming. All rights reserved.
//

#import "UIImage+image.h"

@implementation UIImage (image)


+ (UIImage *)createImageWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}
@end
