//
//  SYBLoginViewController.m
//  WClient
//
//  Created by Song Xiaoming on 13-10-26.
//  Copyright (c) 2013年 Song Xiaoming. All rights reserved.
//

#import "SYBLoginViewController.h"
#import "SYBWeiboAPIClient.h"
#import "SSKeychain.h"
#import "SYBWeiboAPIClient.h"

@interface SYBLoginViewController ()

@end

@implementation SYBLoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
}


- (void)start
{
    NSString *uid = [[NSUserDefaults standardUserDefaults]objectForKey:@"uid"];
    if (!uid)
    { //As Not Login
        [self loadLoginWebView];
    } else {
//        [SSKeychain deletePasswordForService:@"WClient" account:uid];
        NSString *token = [SSKeychain passwordForService:@"WClient" account:uid];
        [[SYBWeiboAPIClient sharedClient] setToken:token];
        
        if (!token)
        {//As not Login
            [self loadLoginWebView];
        }else{
           [self performSegueWithIdentifier:@"login" sender:self];
        }
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self start];
}


- (void)loadLoginWebView
{
    NSURLRequest *request = [[SYBWeiboAPIClient sharedClient] authorizeRequest:@"261263576" res_type:@"code" flogin:@"true"];
    _webView = [[UIWebView alloc] initWithFrame:CGRectMake(10, 10, 20, 20)];
    [_webView loadRequest:request];
    self.view = _webView;
    _webView.delegate = self;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    
    NSString *tokenstring = self.webView.request.URL.absoluteString;
    if ([tokenstring hasPrefix:@"https://api.weibo.com/oauth2/default.html"])
    {
        NSString *code = [tokenstring substringFromIndex:47];
        if (code)
        {
         [[SYBWeiboAPIClient sharedClient] OuthAccess_token:code
                                                success:^(NSDictionary *dict)
            {
                NSString *uid = dict[@"uid"];
                NSString *access_token = dict[@"access_token"];
                [[NSUserDefaults standardUserDefaults] setValue:uid forKey:@"uid"];
                [SSKeychain setPassword:access_token forService:@"WClient" account:uid];
                [[SYBWeiboAPIClient sharedClient] setToken:access_token];
                [self performSegueWithIdentifier:@"login" sender:self];
                
            } failure:^(PBXError error) {
             NSLog(@"Outh access_token error : %u", error);
            }];
        }
    }
}

@end
