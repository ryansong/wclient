//
//  SYBWeiboAttitude.h
//  WClient
//
//  Created by ryan on 14-8-6.
//  Copyright (c) 2014年 Song Xiaoming. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SYBWeiboUser.h"
#import "SYBWeibo.h"

@interface SYBWeiboAttitude : NSObject

@property (nonatomic, assign) long long attitudeID;
@property (nonatomic, strong) NSString *created_at;
@property (nonatomic, strong) NSString *attitude;
@property (nonatomic, strong) NSString *last_attitude;
@property (nonatomic, strong) NSString *source;
@property (nonatomic, strong) SYBWeiboUser *user;
@property (nonatomic, strong) SYBWeiBo *status;
@property (nonatomic, assign) BOOL hasvisible;
@property (nonatomic, assign) int previous_cursor;
@property (nonatomic, assign) long long next_cursor;
@property (nonatomic, assign) int total_number;

@end
