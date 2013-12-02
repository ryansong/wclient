//
//  SYBWeiBoURLShort.h
//  WClient
//
//  Created by Song Xiaoming on 13-11-5.
//  Copyright (c) 2013年 Song Xiaoming. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SYBWeiBoURLShort : NSObject

@property (nonatomic, strong) NSString *url_short;	//	短链接
@property (nonatomic, strong) NSString *url_long;	//	原始长链接
@property (nonatomic, assign) int url_type;	//	链接的类型，0：普通网页、1：视频、2：音乐、3：活动、5、投票
@property (nonatomic, assign) BOOL result;	//	短链的可用状态，true：可用、false：不可用。

@end
