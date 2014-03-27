//
//  SYBWeboAPI.h
//  WClient
//
//  Created by Song Xiaoming on 13-10-24.
//  Copyright (c) 2013年 Song Xiaoming. All rights reserved.
//

extern NSString *const PBXErrorDomain;

typedef NS_ENUM(NSUInteger, PBXError) {
    PBXErrorUnknown = 1,
};

typedef void(^PBStringBlock)(NSString *);
typedef void(^PBArrayBlock)(NSArray *);
typedef void(^PBDictionaryBlock)(NSDictionary *);
typedef void(^PBErrorBlock)(PBXError);
typedef void(^PBEmptyBlock)();

#import <Foundation/Foundation.h>

@interface SYBWeiboAPIClient : NSObject
@property (nonatomic,strong) NSString *token;

+ (instancetype)sharedClient;

- (void)getAllFriendsWeibo:(long long)since_id
                    max_id:(long long)max_id
                      count:(int)count
                  base_app:(int)app_typ
                   feature:(int)feature
                 trim_user:(int)trim_user
                   success:(PBArrayBlock)success
                   failure:(PBErrorBlock)failure;

- (NSURLRequest *)authorizeRequest:(NSString *)c_id
                          res_type:(NSString *)res_tp
                            flogin:(NSString *)fl
                            client:(NSString *)client;
;

- (void)OuthAccess_token:(NSString *)code
                 success:(PBDictionaryBlock)success
                 failure:(PBErrorBlock)failure;

- (void)sendWeibo:(NSString *)po;
- (void)sendWeibo:(NSString *)po images:(NSArray *)images;
@end
