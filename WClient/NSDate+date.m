//
//  NSDate+date.m
//  WClient
//
//  Created by Song Xiaoming on 2/20/15.
//  Copyright (c) 2015 Song Xiaoming. All rights reserved.
//

#define d @"EEEEDDHHmmssTyyyyMMDD"
#define DateFormatter_CreateAt @"EEE MMM dd HH:mm:ss Z yyyy"


#define seconds_per_min 60
#define seconds_per_hour (60*60)
#define seconds_per_day (60*60*24)

#import "NSDate+date.h"

@implementation NSDate (date)

+ (NSDate *)dateWithString:(NSString *)dateString
{
    NSDateFormatter *dateFormater = [[NSDateFormatter alloc] init];
    
    dateFormater.dateFormat = d;
    
    
  return [dateFormater dateFromString:dateString];
}

+ (NSDate *)dateWithCreateAt:(NSString *)dateString {
    NSDateFormatter *dateFormater = [[NSDateFormatter alloc] init];
    [dateFormater setDateFormat:DateFormatter_CreateAt];
    return [dateFormater dateFromString:dateString];
}

- (NSString *)sinceDate {
    NSTimeInterval interval = [[NSDate date] timeIntervalSinceDate:self];
    
    if (interval < seconds_per_min) {
        return [NSString stringWithFormat:@"%.f 秒前", interval];
    } else if (interval < seconds_per_hour) {
        return [NSString stringWithFormat:@"%.f 分钟前", interval/seconds_per_min];
    } else if (interval < seconds_per_day) {
        return [NSString stringWithFormat:@"%.f 小时前", interval/seconds_per_hour];
    } else {
        if ([self isThisYear]) {
            return [NSDateFormatter localizedStringFromDate:self dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterShortStyle];
        } else {
           return [NSDateFormatter localizedStringFromDate:self dateStyle:NSDateFormatterLongStyle timeStyle:NSDateFormatterShortStyle];
        }
    }
}

- (BOOL)isThisYear{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSCalendarUnit unit = NSCalendarUnitYear;
    
    NSInteger thisYear = [calendar component:unit fromDate:[NSDate date]];
    NSInteger year = [calendar component:unit fromDate:self];
    
    return thisYear == year;
}

@end
