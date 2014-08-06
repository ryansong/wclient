//
//  SYBWeiboRetweet.h
//  WClient
//
//  Created by ryan on 14-8-6.
//  Copyright (c) 2014年 Song Xiaoming. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SYBWeiBo.h"
#import "SYBWeiBoGEO.h"

@interface SYBWeiboRetweet : NSObject

@property (nonatomic, strong) NSString *idstr;	//字符串型的微博ID
@property (nonatomic, strong) NSString *created_at;	//创建时间
@property (nonatomic, assign) long long weiboID;	//微博ID
@property (nonatomic, strong) NSString *text;	//微博信息内容
@property (nonatomic, strong) NSString *source;	//微博来源
@property (nonatomic, assign) BOOL favorited;	//是否已收藏
@property (nonatomic, assign) BOOL truncated;	//是否被截断
@property (nonatomic, assign) long long in_reply_to_status_id;	//（暂未支持）回复ID
@property (nonatomic, assign) long long in_reply_to_user_id;	//（暂未支持）回复人UID
@property (nonatomic, strong) NSString *in_reply_to_screen_name;	//（暂未支持）回复人昵称
@property (nonatomic, assign) long long mid;	//微博MID
@property (nonatomic, strong) NSString *bmiddle_pic;	//	中等尺寸图片地址
@property (nonatomic, strong) NSString *original_pic;	//	原始图片地址
@property (nonatomic, strong) NSString *thumbnail_pic;	//	缩略图片地址
@property (nonatomic, assign) int reposts_count;	//转发数
@property (nonatomic, assign) int comments_count;	//评论数
@property (nonatomic, strong) NSArray *annotations;	//微博附加注释信息
@property (nonatomic, strong) SYBWeiBoGEO *geo;	//地理信息字段
@property (nonatomic, strong) SYBWeiboUser *user;	//微博作者的用户信息字段
@property (nonatomic, strong) SYBWeiBo *retweeted_status;	//转发的微博信息字段

@end
