//
//  APPMacro.h
//  WClient
//
//  Created by Song Xiaoming on 3/3/14.
//  Copyright (c) 2014 Song Xiaoming. All rights reserved.
//

#ifndef WClient_APPMacro_h
#define WClient_APPMacro_h

static NSString *const CLIENT_ID = @"261263576";
static NSString *const CLIENT_SECRET = @"6597bf2ba67b745e6af1c5b7f4b33e6e";
static NSString *const redirect_uri = @"https://api.weibo.com/oauth2/default.html";
static NSString *const response_type = @"code";

static NSString *const COMESFROM = @"来自";
static NSString *const LIKE = @"like";


static NSString *const Comment = @"Comment";
static NSString *const Retweet = @"Retweet";

#define SSKeyChina_UID @"uid"
#define SSKeyChina_Service @"WClient"

typedef enum{
    SYBRunEnviromentOffLine = 0,
    SYBRunEnviromentOnline,
    
} SYBRunEnviroment;

typedef NS_ENUM(NSUInteger, SYBCommentOriType  ){
    SYBCommentOriComment,
    SYBCommentOriRetweet,
};

static SYBRunEnviroment const ENV = SYBRunEnviromentOnline;

#endif
