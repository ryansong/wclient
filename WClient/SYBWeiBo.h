//
//  SYBWeiBo.h
//  WClient
//
//  Created by Song Xiaoming on 13-9-16.
//  Copyright (c) 2013年 Song Xiaoming. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SYBWeiboUser.h"
#import "SYBWeiboPrivacy.h"
#import "SYBWeiBoGEO.h"

@interface SYBWeiBo : NSObject<NSCoding>

@property (nonatomic, strong) NSString *created_at;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSAttributedString *attributedText;
@property (nonatomic, assign) long long weiboId;
@property (nonatomic, assign) long long mid;
@property (nonatomic, strong) NSString *source;
@property (nonatomic, assign) BOOL favorited;
@property (nonatomic, assign) BOOL truncated;
@property (nonatomic, strong) NSString *in_reply_to_status_id;
@property (nonatomic, strong) NSString *in_reply_to_user_id;
@property (nonatomic, strong) NSString *in_reply_to_screen_name;
@property (nonatomic, strong) NSString *thumbnail_pic;
@property (nonatomic, strong) NSString *bmiddle_pic;	//	中等尺寸图片地址，没有时不返回此字段
@property (nonatomic, strong) NSString *original_pic; //	string	原始图片地址，没有时不返回此字段
@property (nonatomic, strong) SYBWeiBoGEO *geo;//	地理信息字段 详细
@property (nonatomic, strong) SYBWeiboUser *user;	//	微博作者的用户信息字段 详细
@property (nonatomic, strong) SYBWeiBo *retweeted_status;	//object	被转发的原微博信息字段，当该微博为转发微博时返回 详细
@property (nonatomic, assign) int reposts_count;	//	转发数
@property (nonatomic, assign) int comments_count;	//	评论数
@property (nonatomic, assign) int attitudes_count;	//	表态数
@property (nonatomic, assign) int mlevel;	//	暂未支持
@property (nonatomic, strong) NSDictionary *visible;	//	微博的可见性及指定可见分组信息。该object中type取值，0：普通微博，1：私密微博，3：指定分组微博，4：密友微博；list_id为分组的组号
@property (nonatomic, strong) NSArray *pic_urls;	//	微博配图地址。多图时返回多图链接。无配图返回“[]”
@property (nonatomic, strong) NSArray *ad; // array

@property (nonatomic, assign) BOOL hasRepo;
@property (nonatomic, assign) BOOL hasPic;

@end
