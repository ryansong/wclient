//
//  SYBWeiBoComment.h
//  WClient
//
//  Created by Song Xiaoming on 13-11-5.
//  Copyright (c) 2013年 Song Xiaoming. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SYBWeiboUser.h"
#import "SYBWeiBo.h"

@interface SYBWeiBoComment : NSObject

@property (nonatomic, strong) NSString *created_at;	//	评论创建时间
@property (nonatomic, assign) long commentID;	//评论的ID
@property (nonatomic, strong) NSString *text;	//	评论的内容
@property (nonatomic, strong) NSString *source;	//	评论的来源
@property (nonatomic, strong) NSString *user;	//	评论作者的用户信息字段 详细
@property (nonatomic, strong) NSString *mid;	//	评论的MID
@property (nonatomic, strong) NSString *idstr;	//	字符串型的评论ID
@property (nonatomic, strong) SYBWeiBo *status;	//	评论的微博信息字段 详细
@property (nonatomic, strong) SYBWeiBoComment *reply_comment;	//	评论来源评论，当本评论属于对另一评论的回复时返回此字段

@end
