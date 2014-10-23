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

@property (nonatomic,retain)UIWebView *webView;
@property (nonatomic,retain)NSMutableData *receivedData;
@property (nonatomic)NSHTTPURLResponse *response;
@property (weak, nonatomic) IBOutlet UIImageView *loadImage;

@property (nonatomic, weak) IBOutlet UITextField *username;
@property (nonatomic, weak) IBOutlet UITextField *password;

@property (nonatomic, copy) NSString *userID;
@property (nonatomic, copy) NSString *passwd;

@property (nonatomic, assign) BOOL clientLogin;

- (IBAction)login:(id)sender;

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
    
    _username.delegate = self;
    _password.delegate = self;

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
        [self openLoginView];
    } else {
#warning delete user key for test
//        [SSKeychain deletePasswordForService:@"WClient" account:uid];
        
        NSString *token = [SSKeychain passwordForService:@"WClient" account:uid];
        [[SYBWeiboAPIClient sharedClient] setToken:token];

        if (!token)
        {//As not Login
            [self openLoginView];
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

- (void)openLoginView
{
    _loadImage.hidden = YES;
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
//    timer = [NSTimer scheduledTimerWithTimeInterval:0.8 target:self selector:@selector(showWebView) userInfo:nil repeats:NO];
}
- (void)webViewDidFinishLoad:(UIWebView *)webView{
    
    NSString *tokenstring = self.webView.request.URL.absoluteString;
    
    // didload login view
    if ([tokenstring hasPrefix:@"https://api.weibo.com/oauth2/authorize"] && _clientLogin) {
        
        NSString *jsSettingUserID = [NSString stringWithFormat:@"document.getElementsByName('userId')[0].value=%@;", _userID];
        
         NSString *jsSettingPWD = [NSString stringWithFormat:@"document.getElementsByName('passwd')[0].value='%@';", _passwd];
        
        [webView stringByEvaluatingJavaScriptFromString:jsSettingUserID];
        [webView stringByEvaluatingJavaScriptFromString:jsSettingPWD];
        [webView stringByEvaluatingJavaScriptFromString:@"document.forms[0].submit();"];
    }
    
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

- (IBAction)login:(id)sender {
    
    _userID = _username.text;
    _passwd = _password.text;
    
    _clientLogin = YES;
    
    _webView.hidden = YES;
    [self loadLoginWebView];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([_password isEqual:textField]) {
        [_password resignFirstResponder];
        [self login:nil];
        
    } else if ([_username isEqual:textField]) {
        [_username resignFirstResponder];
        [_password becomeFirstResponder];
    }
    
    return YES;
    
}
@end
