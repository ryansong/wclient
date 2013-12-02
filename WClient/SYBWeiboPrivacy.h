//
//  SYBWeiboPrivacy.h
//  WClient
//
//  Created by Song Xiaoming on 13-11-5.
//  Copyright (c) 2013年 Song Xiaoming. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SYBWeiboPrivacy : NSObject

@property (nonatomic,assign) int comment_type;	//	是否可以评论我的微博，0：所有人、1：关注的人、2：可信用户
@property (nonatomic,assign) int geo_type;	//	是否开启地理信息，0：不开启、1：开启
@property (nonatomic,assign) int message_type;	//	是否可以给我发私信，0：所有人、1：我关注的人、2：可信用户
@property (nonatomic,assign) int realname_type;	//	是否可以通过真名搜索到我，0：不可以、1：可以
@property (nonatomic,assign) int badge_type;	//	勋章是否可见，0：不可见、1：可见
@property (nonatomic,assign) int mobile_type;	//	是否可以通过手机号码搜索到我，0：不可以、1：可以
@property (nonatomic,assign) int webim_type;	//	是否开启webim， 0：不开启、1：开启

@end
