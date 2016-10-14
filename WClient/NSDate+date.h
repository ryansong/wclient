//
//  NSDate+date.h
//  WClient
//
//  Created by Song Xiaoming on 2/20/15.
//  Copyright (c) 2015 Song Xiaoming. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (date)

+ (NSDate *)dateWithString:(NSString *)dateString;
+ (NSDate *)dateWithCreateAt:(NSString *)dateString;
- (NSString *)sinceDate;

@end
