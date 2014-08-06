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
static NSString *const KAPIRequestShowComments = @"/2/comments/show.json";
static NSString *const KAPIRequestShowRetweets = @"/2/statuses/repost_timeline.json";
static NSString *const KAPIRequestShowAttitudes = @"2/attitudes/show.json";
static NSString *const KAPIRequestFriendsWeibo = @"/statuses/friends_timeline.json";


#import "SYBWeiboAPIClient.h"
#import <AFNetworking.h>
#import "SYBWeiBo.h"
#import <SSKeychain.h>
#import "APPMacro.h"
#import "SYBWeiBoComment.h"
#import "SYBWeiboRetweet.h"
#import "SYBWeiboAttitude.h"


@interface SYBWeiboAPIClient ()
@property (nonatomic, strong) AFHTTPSessionManager *httpClient;
@property (nonatomic, strong) NSString *accessToken;

@property (nonatomic, strong) NSString *client_id;
@property (nonatomic, strong) NSString *client_secret;

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
        _client_id = CLIENT_ID;
        _client_secret = CLIENT_SECRET;
        _httpClient = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:KAPIBaseUrl]];
        _httpClient.responseSerializer = [AFHTTPResponseSerializer serializer];
    }
    return self;
}

-(NSURLRequest *)authorizeRequest:(NSString *)c_id
                         res_type:(NSString *)res_tp
                           flogin:(NSString *)fl
                           client:(NSString *)client
{
    if (!client) {
        client = @"default";
    }

    NSString *url =  [[NSString alloc] initWithFormat:@"%@%@?client_id=%@&redirect_uri=%@&response_type=%@&forcelogin=%@&display=%@",KAPIBaseUrl,KAPIRequestAuthorize,c_id,redirect_uri,res_tp,fl,client];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]
                                             cachePolicy:NSURLRequestUseProtocolCachePolicy
                                         timeoutInterval:60.0];
    return request;
}

- (void)getUserInfoWithSource:(NSString *)source
                          uid:(NSString *)uid
                  screen_name:(NSString *)screen_name
                      success:(PBDictionaryBlock)success
                      failure:(PBErrorBlock)failure
{
    NSMutableDictionary *params = [NSMutableDictionary  dictionary];
    params[@"access_token"] = _token;
    
    if (source) {
        params[@"source"] = source;
    } else {
        // default value
        params[@"source"] = @"AppKey";
    }
    
    if (uid) {
        params[@"uid"] = uid;
    } else {
       params[@"uid"] = [[NSUserDefaults standardUserDefaults] valueForKey:@"uid"];
    }
    
    if (screen_name) {
        params[@"screen_name"] = screen_name;
    }
    
    [_httpClient GET:@"users/show.json" parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
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
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (failure) {
            failure(error.code);
        }
    }];
    
}

- (void)getAllFriendsWeibo:(long long)since_id
                    max_id:(long long)max_id
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
    
    [_httpClient GET:[KAPIBaseUrl stringByAppendingString:KAPIRequestFriendsWeibo] parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        NSError *error;

        //test data for offline
        if (ENV == SYBRunEnviromentOffLine) {
            [[NSUserDefaults standardUserDefaults] setObject:responseObject forKey:@"testData"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }

        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:&error];


        if (!error) {
            if (dict) {
                NSMutableArray *result = [[NSMutableArray alloc] init];
                NSMutableArray *statuses =  dict[@"statuses"];

                for ( NSDictionary *status in statuses ) {
                    SYBWeiBo *weibo = [self weiBoFromDict:status];
                    [result addObject:weibo];
                }
                //test data for offline
                [[NSUserDefaults standardUserDefaults] setObject:responseObject forKey:@"testData"];

                if (success) {
                    success(result);
                }
            }
        } else {
            failure(error.code);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (failure) {
            failure(error.code);
        }
        //for offline env
        if (ENV == SYBRunEnviromentOffLine) {

            NSData *responseObject = [[NSUserDefaults standardUserDefaults] objectForKey:@"testData"];
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:&error];
            if (dict) {
                NSMutableArray *result = [[NSMutableArray alloc] init];
                NSMutableArray *statuses =  dict[@"statuses"];

                for ( NSDictionary *status in statuses ) {
                    SYBWeiBo *weibo = [self weiBoFromDict:status];
                    [result addObject:weibo];
                }
                //test data for offline
                [[NSUserDefaults standardUserDefaults] setObject:responseObject forKey:@"testData"];

                if (success) {
                    success(result);
                }
            }
        }
    }];
    
//    [_httpClient getPath:KAPIRequestFriendsWeibo parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSError *error;
//        
//        //test data for offline
//        if (ENV == SYBRunEnviromentOffLine) {
//            [[NSUserDefaults standardUserDefaults] setObject:responseObject forKey:@"testData"];
//            [[NSUserDefaults standardUserDefaults] synchronize];
//        }
//        
//        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:&error];
//   
//
//        if (!error) {
//            if (dict) {
//                NSMutableArray *result = [[NSMutableArray alloc] init];
//                NSMutableArray *statuses =  dict[@"statuses"];
//               
//                for ( NSDictionary *status in statuses ) {
//                    SYBWeiBo *weibo = [self weiBoFromDict:status];
//                    [result addObject:weibo];
//                }
//                //test data for offline
//                [[NSUserDefaults standardUserDefaults] setObject:responseObject forKey:@"testData"];
//
//                if (success) {
//                    success(result);
//                }
//            }
//        } else {
//            failure(error.code);
//        }
//        
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        if (failure) {
//            failure(error.code);
//        }
//        //for offline env
//        if (ENV == SYBRunEnviromentOffLine) {
//            
//            NSData *responseObject = [[NSUserDefaults standardUserDefaults] objectForKey:@"testData"];
//            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:&error];
//            if (dict) {
//                NSMutableArray *result = [[NSMutableArray alloc] init];
//                NSMutableArray *statuses =  dict[@"statuses"];
//                
//                for ( NSDictionary *status in statuses ) {
//                    SYBWeiBo *weibo = [self weiBoFromDict:status];
//                    [result addObject:weibo];
//                }
//                //test data for offline
//                [[NSUserDefaults standardUserDefaults] setObject:responseObject forKey:@"testData"];
//                
//                if (success) {
//                    success(result);
//                }
//            }
//        }
//    }];
    
}

- (void)getCommnetsWithWeiboID:(long long)weiboID
                      since_id:(long long)since_id
                        max_id:(long long)max_id
                         count:(int)count
                          page:(int)page
              filter_by_author:(int)filter
                       success:(PBArrayBlock)success
                       failure:(PBErrorBlock)failure
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    params[@"access_token"] = _token;
   
    if (weiboID) {
        params[@"id"] = @(weiboID);
    }

    if (since_id) {
        params[@"since_id"] = @(since_id);
    } else {
        params[@"since_id"] = @(0);
    }
    
    if (max_id) {
        params[@"max_id"] = @(max_id);
    } else {
        params[@"max_id"] = @(0);
    }
    
    if (count) {
        params[@"count"] = @(count);
    }
    
    if (page) {
        params[@"page"] = @(page);
    }

    if (filter) {
        params[@"filter_by_author"] = @(filter);
    }
    
    [_httpClient GET:KAPIRequestShowComments parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        NSMutableArray *weiboComments = [NSMutableArray array];

        NSError *error;
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:&error];
        
        if (error) {
            failure(PBXErrorUnknown);
            return;
        } else {
            NSDictionary *comments = dict[@"comments"];
            for (NSDictionary *comment in comments) {
                SYBWeiBoComment *weiboComment = [[SYBWeiBoComment alloc] init];
                weiboComment.created_at = comment[@"created_at"];
                weiboComment.text = comment[@"text"];
                weiboComment.commentID = [comment[@"id"] longLongValue];
                weiboComment.idstr = comment[@"idstr"];
                weiboComment.mid = comment[@"mid"];
                weiboComment.source = comment[@"source"];
                weiboComment.status = [self weiBoFromDict:comment[@"status"]];
                weiboComment.user = [self userFromDict:comment[@"user"]];
                
                [weiboComments addObject:weiboComment];
            }
        }
        
        if (success) {
            success(weiboComments);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
         failure(PBXErrorUnknown);
    }];
    
}

- (void)getRetweetsWithWeiboID:(long long)weiboID
                      since_id:(long long)since_id
                        max_id:(long long)max_id
                         count:(int)count
                          page:(int)page
              filter_by_author:(int)filter
                       success:(PBArrayBlock)success
                       failure:(PBErrorBlock)failure
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    params[@"access_token"] = _token;
    
    if (weiboID) {
        params[@"id"] = @(weiboID);
    }
    
    if (since_id) {
        params[@"since_id"] = @(since_id);
    } else {
        params[@"since_id"] = @(0);
    }
    
    if (max_id) {
        params[@"max_id"] = @(max_id);
    } else {
        params[@"max_id"] = @(0);
    }
    
    if (count) {
        params[@"count"] = @(count);
    }
    
    if (page) {
        params[@"page"] = @(page);
    }
    
    if (filter) {
        params[@"filter_by_author"] = @(filter);
    }
    
    [_httpClient GET:KAPIRequestShowRetweets parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        NSMutableArray *weiboRetweets = [NSMutableArray array];
        
        NSError *error;
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:&error];
        
        if (error) {
            failure(PBXErrorUnknown);
            return;
        } else {
            NSDictionary *retweets = dict[@"reposts"];
            for (NSDictionary *retweet in retweets) {
                SYBWeiboRetweet *weiboRetweet = [[SYBWeiboRetweet alloc] init];

                weiboRetweet.idstr = retweet[@"idstr"];
                weiboRetweet.created_at = retweet[@"created_at"];
                weiboRetweet.weiboID = [retweet[@"id"] longLongValue];
                weiboRetweet.text = retweet[@"text"];
                weiboRetweet.source = retweet[@"source"];
                weiboRetweet.favorited = [retweet[@"favorited"] boolValue];
                weiboRetweet.truncated = [retweet[@"truncated"] boolValue];
                weiboRetweet.mid = [retweet[@"mid"] longLongValue];
                weiboRetweet.bmiddle_pic = retweet[@"bmiddle_pic"];
                weiboRetweet.original_pic = retweet[@"original_pic"];
                weiboRetweet.thumbnail_pic = retweet[@"thumbnail_pic"];
                weiboRetweet.reposts_count = [retweet[@"reposts_count"] integerValue];
                weiboRetweet.comments_count = [retweet[@"comments_count"] integerValue];
                weiboRetweet.annotations = [retweet[@"annotations"] allObjects];
                weiboRetweet.geo = [self geoFromDict:retweet[@"geo"]];
                weiboRetweet.retweeted_status = [self weiBoFromDict:retweet[@"status"]];
                weiboRetweet.user = [self userFromDict:retweet[@"user"]];
                
                [weiboRetweets addObject:weiboRetweet];
            }
        }
        
        if (success) {
            success(weiboRetweets);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        failure(PBXErrorUnknown);
    }];
    
}

- (void)getAttitudesWithWeiboID:(long long)weiboID
                          count:(int)count
                           page:(int)page
                        success:(PBArrayBlock)success
                        failure:(PBErrorBlock)failure;
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    params[@"access_token"] = _token;
    
    if (weiboID) {
        params[@"id"] = @(weiboID);
    }
    
    if (count) {
        params[@"count"] = @(count);
    }
    
    if (page) {
        params[@"page"] = @(page);
    }
    
    [_httpClient GET:KAPIRequestShowAttitudes
          parameters:params
             success:^(NSURLSessionDataTask *task, id responseObject) {
                 
                 NSMutableArray *weiboAttitudes = [[NSMutableArray alloc] init];
                 
                 NSError *error;
                 NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:&error];
                 
                 if (error) {
                     failure(PBXErrorUnknown);
                     return;
                 } else {
                     NSDictionary *attitudes = dict[@"attitudes"];
                     for (NSDictionary *attitude in attitudes) {
                         SYBWeiboAttitude *weiboAttitude = [[SYBWeiboAttitude alloc] init];
                         weiboAttitude.attitudeID = [attitude[@"id"] longLongValue];
                         weiboAttitude.created_at = attitude[@"created_at"];
                         weiboAttitude.attitude = attitude[@"attitude"];
                         weiboAttitude.last_attitude = attitude[@"last_attitude"];
                         weiboAttitude.source = attitude[@"source"];
                         weiboAttitude.user = [self userFromDict:attitude[@"user"]];
                         weiboAttitude.status = [self weiBoFromDict:attitude[@"status"]];
                         weiboAttitude.hasvisible = [attitude[@"hasvisible"] boolValue];
                         weiboAttitude.previous_cursor = [attitude[@"previous_cursor"] intValue];
                         weiboAttitude.next_cursor = [attitude[@"next_cursor"] longLongValue];
                         weiboAttitude.total_number = [attitude[@"total_number"] intValue];
                         
                         [weiboAttitudes addObject:weiboAttitude];
                     }
                     
                 }
        
    
                 
             } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
    }];
}

- (BOOL) sendWeiBo
{
    NSString *acctoken = [SSKeychain passwordForService:@"WClient" account:@"username"];
    NSString *status =@"test1111222中文";
    
    NSString *api = [NSString stringWithFormat:@"https://api.weibo.com/2/statuses/update.json?access_token=%@&status=%@",acctoken,status];
    
    NSString* encodeURL = [api stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSURL *url = [NSURL URLWithString: encodeURL];
    
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

- (void)sendWeibo:(NSString *)po
{
    [self sendWeibo:po images:nil];
}

- (void)sendWeibo:(NSString *)po images:(NSArray *)images
{
    NSString *acctoken = [SSKeychain passwordForService:@"WClient" account:@"username"];
    NSString *api = [NSString stringWithFormat:@"https://api.weibo.com/2/statuses/update.json?access_token=%@&status=%@",acctoken,po];
}

- (void)OuthAccess_token:(NSString *)code
                 success:(PBDictionaryBlock)success
                 failure:(PBErrorBlock)failure

{
    [_httpClient POST:[KAPIBaseUrl stringByAppendingString:KAPIRequestAccess_token] parameters:@{@"client_id":_client_id,
                                                                      @"client_secret": _client_secret,
                                                                      @"grant_type":@"authorization_code",
                                                                      @"code": code,
                                                                      @"redirect_uri": redirect_uri,}
              success:^(NSURLSessionDataTask *task, id responseObject) {
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
                  
              } failure:^(NSURLSessionDataTask *task, NSError *error) {
                  NSLog(@"OuthAccess_token error");
                  if (failure)
                  {
                      failure(error.code);
                  }
                  
              }];
}

- (SYBWeiboUser *)userFromDict:(NSDictionary *)userDict
{
     SYBWeiboUser *user = [[SYBWeiboUser alloc] init];
    
    user.uid = [userDict[@"uid"] longValue];
    user.idstr = userDict[@"idstr"];
    user.screen_name = userDict[@"screen_name"];
    user.name = userDict[@"name"];
    user.province = [userDict[@"province"] intValue];
    user.city = [userDict[@"city"] intValue];
    user.location = userDict[@"location"];
    user.description = userDict[@"description"];
    user.url = userDict[@"url"];
    user.profile_image_url = userDict[@"profile_image_url"];
    user.profile_url = userDict[@"profile_url"];
    user.domain = userDict[@"domain"];
    user.weihao = userDict[@"weihao"];
    user.gender = userDict[@"gender"];
    user.followers_count = [userDict[@"followers_count"] intValue];
    user.friends_count = [userDict[@"friends_count"] intValue];
    user.statuses_count = [userDict[@"statuses_count"] intValue];
    user.favourites_count = [userDict[@"favourites_count"] intValue];
    user.created_at = userDict[@"created_at"];
    user.following = [userDict[@"following"] boolValue];
    user.allow_all_act_msg = [userDict[@"allow_all_act_msg"] boolValue];
    user.geo_enabled = [userDict[@"geo_enabled"] boolValue];
    user.verified = [userDict[@"verified"] boolValue];
    user.verified_type = [userDict[@"verified_type"] intValue];
    user.remark = userDict[@"remark"];
    //a property of weiboUser
    //user.status = userDict[@"status"];
    user.allow_all_comment = [userDict[@"allow_all_comment"] boolValue];
    user.avatar_large = userDict[@"avatar_large"];
    user.verified_reason = userDict[@"verified_reason"];
    user.follow_me = [userDict[@"follow_me"] boolValue];
    user.online_status = [userDict[@"online_status"] intValue];
    user.bi_followers_count = [userDict[@"bi_followers_count"] intValue];
    user.lang = userDict[@"lang"];

    return user;
}


- (SYBWeiBoGEO *)geoFromDict:(NSDictionary *)geoDict
{
    SYBWeiBoGEO *geo = [[SYBWeiBoGEO alloc] init];
    //todo
    
    return geo;
}

- (SYBWeiBo *)weiBoFromDict:(NSDictionary *)status
{
    SYBWeiBo *weibo = [[SYBWeiBo alloc] init];
    weibo.created_at = status[@"created_at"];
    weibo.text = status[@"text"];
    weibo.weiboId = [status[@"id"] longLongValue];
    weibo.mid = [status[@"mid"] longLongValue];
    
#warning ignore the url
    NSString *source = status[@"source"];
    if (source) {
    NSString *pattern = @".*>(.+)</a>";
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:nil];
    
    NSArray *matches = [regex matchesInString:source options:NSRegularExpressionCaseInsensitive range:NSMakeRange(0, source.length)];
    
        if (matches) {
            for (NSTextCheckingResult *match in matches) {
                for (int i = 1; i < match.numberOfRanges; ++i) {
                    weibo.source = [source substringWithRange:[match rangeAtIndex:1]];
                }
            }
        }
    }

    weibo.favorited = [status[@"favorited"] boolValue];
    weibo.truncated = [status[@"truncated"] boolValue];
    weibo.in_reply_to_status_id = status[@"in_reply_to_status_id"];
    weibo.in_reply_to_user_id = status[@"in_reply_to_user_id"];
    weibo.in_reply_to_screen_name = status[@"in_reply_to_screen_name"];
    weibo.thumbnail_pic = status[@"thumbnail_pic"];
    weibo.bmiddle_pic = status[@"bmiddle_pic"];
    weibo.original_pic = status[@"original_pic"];
    
    if (status[@"geo"] != [NSNull null]) {
        
        SYBWeiBoGEO *geo = [[SYBWeiBoGEO alloc] init];
        NSDictionary *geoDict  = status[@"geo"];
        geo.longitude = geoDict[@"longitude"];
        geo.latitude = geoDict[@"latitude"];
        geo.city = geoDict[@"city"];
        geo.province = geoDict[@"province"];
        geo.city_name = geoDict[@"city_name"];
        geo.province_name = geoDict[@"province_name"];
        geo.address = geoDict[@"address"];
        geo.pinyin = geoDict[@"pinyin"];
        geo.more = geoDict[@"more"];
        weibo.geo = geo;
    }
    
    SYBWeiboUser *user = [[SYBWeiboUser alloc] init];
    if (status[@"user"]) {
        NSDictionary *userDict = status[@"user"];
        user.uid = [userDict[@"uid"] longValue];
        user.idstr = userDict[@"idstr"];
        user.screen_name = userDict[@"screen_name"];
        user.name = userDict[@"name"];
        user.province = [userDict[@"province"] intValue];
        user.city = [userDict[@"city"] intValue];
        user.location = userDict[@"location"];
        user.description = userDict[@"description"];
        user.url = userDict[@"url"];
        user.profile_image_url = userDict[@"profile_image_url"];
        user.profile_url = userDict[@"profile_url"];
        user.domain = userDict[@"domain"];
        user.weihao = userDict[@"weihao"];
        user.gender = userDict[@"gender"];
        user.followers_count = [userDict[@"followers_count"] intValue];
        user.friends_count = [userDict[@"friends_count"] intValue];
        user.statuses_count = [userDict[@"statuses_count"] intValue];
        user.favourites_count = [userDict[@"favourites_count"] intValue];
        user.created_at = userDict[@"created_at"];
        user.following = [userDict[@"following"] boolValue];
        user.allow_all_act_msg = [userDict[@"allow_all_act_msg"] boolValue];
        user.geo_enabled = [userDict[@"geo_enabled"] boolValue];
        user.verified = [userDict[@"verified"] boolValue];
        user.verified_type = [userDict[@"verified_type"] intValue];
        user.remark = userDict[@"remark"];
        //a property of weiboUser
        //user.status = userDict[@"status"];
        user.allow_all_comment = [userDict[@"allow_all_comment"] boolValue];
        user.avatar_large = userDict[@"avatar_large"];
        user.verified_reason = userDict[@"verified_reason"];
        user.follow_me = [userDict[@"follow_me"] boolValue];
        user.online_status = [userDict[@"online_status"] intValue];
        user.bi_followers_count = [userDict[@"bi_followers_count"] intValue];
        user.lang = userDict[@"lang"];
        
        weibo.user = user;
    }
    weibo.reposts_count = [status[@"reposts_count"] intValue];
    weibo.comments_count = [status[@"comments_count"] intValue];
    weibo.attitudes_count = [status[@"attitudes_count"] intValue];
    weibo.mlevel = [status[@"mlevel"] intValue];
    
    if (status[@"visible"]) {
        weibo.visible = status[@"visible"];
    }
    
    if (status[@"pic_urls"]) {
        NSArray *urlDicts = status[@"pic_urls"];
        if ([urlDicts count] > 0) {
            weibo.hasPic = YES;
            NSMutableArray *urls = [[NSMutableArray alloc] init];
            for (NSDictionary *urlDict in urlDicts) {
                [urls addObject:[urlDict objectForKey:@"thumbnail_pic"]];
            }
            weibo.pic_urls = [NSArray arrayWithArray:urls];
        }
    }
    
#warning not support ad
    //                    if (status[@"ad"]) {
    //                        weibo.ad = status[@"ad"];
    //                    }
    
    if (status[@"retweeted_status"]) {
        weibo.hasRepo = YES;
        weibo.retweeted_status = [self weiBoFromDict:status[@"retweeted_status"]];
    }
    
    return weibo;
}

- (CGFloat)getProgressDownloadFile:(NSURL *)url
{
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    NSURL *URL = [NSURL URLWithString:@"http://example.com/download.zip"];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
        NSURL *documentsDirectoryPath = [NSURL fileURLWithPath:[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject]];
        return [documentsDirectoryPath URLByAppendingPathComponent:[response suggestedFilename]];
    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        NSLog(@"File downloaded to: %@", filePath);
    }];
    [downloadTask resume];
}

@end
