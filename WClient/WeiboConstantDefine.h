//
//  WeiboConstantDefine.h
//  WClient
//
//  Created by Song Xiaoming on 13-9-11.
//  Copyright (c) 2013年 Song Xiaoming. All rights reserved.
//

#ifndef WClient_WeiboConstantDefine_h
#define WClient_WeiboConstantDefine_h

#define api_authorize @"https://api.weibo.com/oauth2/authorize"
#define api_access_token @"https://api.weibo.com/oauth2/access_token"
#define api_write @"https://api.weibo.com/2/statuses/update.json"



#define forcelogin @"true"

#define UIColorFromRGB(rgbValue)        [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define userImagerAeraHeight 40.0

#define kForgotpwdLink @"http://m.weibo.cn/setting/forgotpwd?vt=4"
#define kRegesterLink @"http://m.weibo.cn/reg/index?&vt=4&wm=3349&backURL=http%3A%2F%2Fm.weibo.cn%2F"

#endif

