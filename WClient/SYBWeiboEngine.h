//
//  SYBWeiboEngine.h
//  WClient
//
//  Created by Song Xiaoming on 13-9-2.
//  Copyright (c) 2013年 Song Xiaoming. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SYBWeiboEngine:NSObject


+(NSString *) getAuthorizeCodeFromServer:(UIWebView *) view;
+(NSString *) getAccessCodeFromServer;



@end
