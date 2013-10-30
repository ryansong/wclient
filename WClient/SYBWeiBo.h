//
//  SYBWeiBo.h
//  WClient
//
//  Created by Song Xiaoming on 13-9-16.
//  Copyright (c) 2013年 Song Xiaoming. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SYBWeiBo : NSObject

@property (nonatomic, strong) NSString *created_at;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, assign) long weiboId;
@property (nonatomic, assign) long mid;
@property (nonatomic, strong) NSString *source;


@end
