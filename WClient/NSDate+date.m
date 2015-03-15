//
//  NSDate+date.m
//  WClient
//
//  Created by Song Xiaoming on 2/20/15.
//  Copyright (c) 2015 Song Xiaoming. All rights reserved.
//

#define d @"EEEEDDHHmmssTyyyyMMDD"


#import "NSDate+date.h"

@implementation NSDate (date)

- (NSDate *)dateFromString:(NSString *)dateString
{
    NSDateFormatter *dateFormater = [[NSDateFormatter alloc] init];
    
    dateFormater.dateFormat = d;
    
    
  return [dateFormater dateFromString:dateString];
}

@end
