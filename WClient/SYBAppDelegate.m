//
//  SYBAppDelegate.m
//  WClient
//
//  Created by Song Xiaoming on 13-8-23.
//  Copyright (c) 2013年 Song Xiaoming. All rights reserved.
//

#import "SYBAppDelegate.h"
#import "SYBWeiboAPIClient.h"
#import <SSKeychain.h>

@implementation SYBAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
#warning test api
    
    NSString *uid = [[NSUserDefaults standardUserDefaults] valueForKey:@"uid"];
    NSString *token = [SSKeychain passwordForService:@"WClient" account:uid];
    if (token) {
        [SYBWeiboAPIClient sharedClient].token = token;
    }
    
    //test get friendsWeibo
//    [[SYBWeiboAPIClient sharedClient] getAllFriendsWeibo:0 max_id:0 count:0 base_app:0 feature:0 trim_user:0 success:^(NSArray *reslut) {
//        NSLog(@"success");
//    } failure:^(PBXError error) {
//        NSLog(@"failed errorcode : %d",error);
//    }];
    
    return YES;
}

@end
