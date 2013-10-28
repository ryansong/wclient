//
//  SYBWeiboEngine.m
//  WClient
//
//  Created by Song Xiaoming on 13-9-2.
//  Copyright (c) 2013年 Song Xiaoming. All rights reserved.
//


#import "SYBWeiboEngine.h"
#import "WeiboConstantDefine.h"


@implementation SYBWeiboEngine

static NSString *authorizeCode;
static NSString *accessCode;

static NSString *requestURL;
static NSString *ResponseURL;


+(NSString *)authorizeCode
{
    return  authorizeCode;
    
}

+(void)setAuthorizeCode:(NSString *) authCode
{
    authorizeCode = authCode;
    
}

+(NSString *)accessCode
{
    if (!accessCode) {
        accessCode = [[NSString alloc]init];
    }
     return accessCode;
}

+(void)setAccessCode:(NSString *)accessCD
{
    if(!accessCode)
    accessCode = accessCD;
   
}

+(NSString *)getAuthorizeCodeFromServer:(UIWebView *)view
{
    if (SYBWeiboEngine.authorizeCode) {
        NSString *authApi = api_authorize;
        
        NSURL *apiURL  = [[NSURL alloc ]initWithString:authApi];
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:apiURL
                                                                   cachePolicy:NSURLRequestReturnCacheDataElseLoad
                                                               timeoutInterval:60];
    
        [request setHTTPMethod:@"POST"];
        
        NSDictionary *paramsDict = @{@"client_id":client_id,
                                  @"redirect_uri":redirect_uri,
                                 @"response_type":response_type,
                                    @"forcelogin":forcelogin
                                     };
        
        [request setValuesForKeysWithDictionary:paramsDict];
        
        NSLog(@"%@",[request URL]);
        
        [view loadRequest:request];
        
        
    }
    return authorizeCode;

}



+(NSString *)getAccessCodeFromServer
{
    return accessCode;
}





@end
