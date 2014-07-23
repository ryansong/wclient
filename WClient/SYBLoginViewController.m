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
#import "APPMacro.h"

@interface SYBLoginViewController ()

@property (nonatomic, strong) NSString *client_id;
@property (nonatomic, strong) NSString *client_secret;

@end

@implementation SYBLoginViewController
{
    NSTimer *timer;
}

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
    
    _client_id = CLIENT_ID;
    _client_secret = CLIENT_SECRET;

    if (!_webView) {
        _webView = [[UIWebView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        [self.view addSubview: _webView];
    }
    _webView.hidden  = YES;
    _loadImage.hidden = NO;
    
    [self start];
    
}


- (void)start
{
    NSString *uid = [[NSUserDefaults standardUserDefaults]objectForKey:@"uid"];
    if (!uid)
    { //As Not Login
        [self loadLoginWebView];
    } else {
#warning delete user key for test
//        [SSKeychain deletePasswordForService:@"WClient" account:uid];
        
        NSString *token = [SSKeychain passwordForService:@"WClient" account:uid];
        [[SYBWeiboAPIClient sharedClient] setToken:token];

        if (!token)
        {//As not Login
            [self loadLoginWebView];
        }else{
            timer = [NSTimer scheduledTimerWithTimeInterval:0.8 target:self selector:@selector(goListViewController) userInfo:nil repeats:NO];
        }
    }
}

- (void)goListViewController
{
    [self hideWebView];
    [self performSegueWithIdentifier:@"login" sender:self];
}

- (void)showWebView
{
    [self hideWebView];
    _webView.hidden = NO;
}

- (void)hideWebView
{
    [UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.8];
	[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight
                           forView:self.view cache:YES];
    _loadImage.hidden = YES;
    [UIView commitAnimations];
}


- (void)loadLoginWebView
{
    NSURLRequest *request = [[SYBWeiboAPIClient sharedClient] authorizeRequest:_client_id res_type:@"code" flogin:@"true" client:@"mobile"];
    
    [_webView loadRequest:request];
    _webView.delegate = self;
    [self didLoadLoginWebView];
}

- (void)didLoadLoginWebView
{
    timer = [NSTimer scheduledTimerWithTimeInterval:0.8 target:self selector:@selector(showWebView) userInfo:nil repeats:NO];
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
