//
//  SYBWeboAPI.m
//  WClient
//
//  Created by Song Xiaoming on 13-10-24.
//  Copyright (c) 2013年 Song Xiaoming. All rights reserved.
//

static NSString *const KAPIRedirectUri = @"https://api.weibo.com/oauth2/default.html";
static NSString *const KAPIBaseUrl = @"https://api.weibo.com";
static NSString *const KAPIRequestAuthorize = @"/oauth2/authorize";
static NSString *const KAPIRequestAccess_token = @"/oauth2/access_token";
static NSString *const KAPIRequestFriendsWeibo = @"/statuses/friends_timeline.json";


#import "SYBWeiboAPIClient.h"
#import <AFNetworking.h>
#import "SYBWeiBo.h"
#import <SSKeychain.h>

@interface SYBWeiboAPIClient ()
@property (nonatomic, strong) AFHTTPClient *httpClient;
@end

@implementation SYBWeiboAPIClient

+ (instancetype)sharedClient
{
    static SYBWeiboAPIClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[SYBWeiboAPIClient alloc] init];
    });
    
    return _sharedClient;
}

- (id)init
{
    self = [super init];
    if (self) {
        _httpClient = [AFHTTPClient clientWithBaseURL:[NSURL URLWithString:KAPIBaseUrl]];
    }
    return self;
}

-(NSURLRequest *)authorizeRequest:(NSString *)c_id
                         res_type:(NSString *)res_tp
                           flogin:(NSString *)fl
{

    NSString *url =  [[NSString alloc] initWithFormat:@"%@%@?client_id=%@&redirect_uri=%@&response_type=%@&forcelogin=%@",KAPIBaseUrl,KAPIRequestAuthorize,c_id,redirect_uri,res_tp,fl];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]
                                             cachePolicy:NSURLRequestUseProtocolCachePolicy
                                         timeoutInterval:60.0];
    return request;
}

- (void)getAllFriendsWeibo:(long)since_id
                    max_id:(long)max_id
                      count:(int)count
                  base_app:(int)base_app
                   feature:(int)feature
                 trim_user:(int)trim_user
                   success:(PBArrayBlock)success
                   failure:(PBErrorBlock)failure
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];

    params[@"access_token"] = _token;
    
    if (since_id) {
        params[@"since_id"] = @(since_id);
    }
    
    if (max_id) {
        params[@"max_id"] = @(max_id);
    }
    
    if (count) {
        params[@"count"] = @(count);
    }
    
    if (base_app) {
        params[@"base_app"] = @(base_app);
    }
    
    if (feature) {
        params[@"feature"] = @(feature);
    }
    
    if (trim_user) {
        params[@"trim_uer"] = @(trim_user);
    }
    
    
    
    [_httpClient getPath:KAPIRequestFriendsWeibo parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSError *error;
        
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:&error];
        
        if (!error) {
            if (dict) {
                NSMutableArray *result = [[NSMutableArray alloc] init];
                NSMutableArray *statuses =  dict[@"statuses"];
               
                for ( NSDictionary *status in statuses ) {
                    SYBWeiBo *weibo = [[SYBWeiBo alloc] init];
                    weibo.created_at = status[@"created_at"];
                    weibo.text = status[@"text"];
                    weibo.weiboId = [status[@"id"] longLongValue];
                    weibo.mid = [status[@"mid"] longLongValue];
                    weibo.source = status[@"source"];
                    
                    [result addObject:weibo];
                }
                
                if (success) {
                    success(result);
                }
            }
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure) {
            failure(error.code);
        }
    }];
    
}

- (BOOL) sendWeiBo
{
    NSString *acctoken = [SSKeychain passwordForService:@"WClient" account:@"username"];
    NSString *status =@"test1111222中文";
    
    NSString *api = [NSString stringWithFormat:@"https://api.weibo.com/2/statuses/update.json?access_token=%@&status=%@",acctoken,status];
    
    NSString* encodeURL = [api stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSURL *url = [NSURL URLWithString: encodeURL];
    
    
    NSLog(@"encode is %@",url);
    
    //第二步，创建请求
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
    [request setHTTPMethod:@"POST"];//设置请求方式为POST，默认为GET
    NSString *str = @"type=focus-c";//设置参数
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:data];
    
    //第三步，连接服务器
    
    NSData *received = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSString *str1 = [[NSString alloc]initWithData:received encoding:NSUTF8StringEncoding];
    
    
    NSLog(@"%@",str1);
    return YES;
}

- (void)OuthAccess_token:(NSString *)code
                 success:(PBDictionaryBlock)success
                 failure:(PBErrorBlock)failure
{
    [_httpClient postPath:KAPIRequestAccess_token parameters:@{@"client_id":client_id,
                                                             @"client_secret": client_secret,
                                                             @"grant_type":@"authorization_code",
                                                             @"code": code,
                                                             @"redirect_uri": redirect_uri,}
                 success:^(AFHTTPRequestOperation *operation, id responseObject){
                     NSError *error;
                     NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject
                                                                          options:NSJSONReadingMutableContainers
                                                                            error:&error];
                     if (!error) {
                         if (dict) {
                             if (success) {
                                 success(dict);
                             }
                         }
                     }
                 } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                     NSLog(@"OuthAccess_token error");
                     if (failure)
                     {
                         failure(error.code);
                     }
                 }];
}

@end
