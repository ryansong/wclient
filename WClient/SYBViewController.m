//
//  SYBViewController.m
//  WClient
//
//  Created by Song Xiaoming on 13-8-23.
//  Copyright (c) 2013年 Song Xiaoming. All rights reserved.
//

#import "SYBViewController.h"

@interface SYBViewController ()

@property(nonatomic)NSString *code;

@end

@implementation SYBViewController

@synthesize webView;

@synthesize receivedData;

@synthesize code;

@synthesize response =_response;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://api.weibo.com/oauth2/authorize?client_id=261263576&redirect_uri=https://api.weibo.com/oauth2/default.html&response_type=code&forcelogin=true"]
                                             cachePolicy:NSURLRequestUseProtocolCachePolicy
                                         timeoutInterval:60.0];
    
    webView = [[UIWebView alloc] initWithFrame:CGRectMake(10, 10, 20, 20)];
    [webView loadRequest:request];
    self.view = webView;
    webView.delegate = self;

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (void)webViewDidFinishLoad:(UIWebView *)webView{
    
    NSString *tokenstring = self.webView.request.URL.absoluteString;
    NSLog(@"tokenstring %@",tokenstring);
    
    NSArray *arry = [tokenstring componentsSeparatedByString:@"code="];
    
    if (arry.count >=2) {

    
    NSString *paramWithCode =  arry[1];
    
    NSArray *params = [paramWithCode componentsSeparatedByString:@"&"];
    
        if (params.count>=1) {
            
            NSString *accode = params[0];
            NSLog(@"accesstoken %@", accode);
            self.code = accode;
            
            NSString *url1 = @"https://api.weibo.com/oauth2/access_token?client_id=261263576&redirect_uri=https://api.weibo.com/oauth2/default.html&client_secret=6597bf2ba67b745e6af1c5b7f4b33e6e&grant_type=authorization_code&code=";
            NSString *newUrl = [NSString stringWithFormat:@"%@%@", url1 , accode];
            
            NSLog(@"access_token url is %@",newUrl);
//            newUrl =@"http://baidu.com";
            
            
            //第一步，创建URL
            NSURL *url = [NSURL URLWithString: newUrl];
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
            
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:received options:NSJSONReadingAllowFragments error:nil];
            NSLog(@"dic=%@",dic);
            
            ///将foundation对象转换成json数据  判断这个对象是否能转换成json数据
            if ([NSJSONSerialization isValidJSONObject:dic]) {
                NSError *error;
                NSData *jsondata = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&error];
                NSString *str2 = [[NSString alloc]initWithData:jsondata encoding:NSUTF8StringEncoding];
                NSLog(@"jsondata=%@",str2);
            }
            NSString *accToken = [dic objectForKey:@"access_token"];
            
            if (accToken) {
                [self sendWeiBo:accToken];
            }
            

            
        }
    }
}

//- (void)connection:(NSURLConnection *)aConn didReceiveData:(NSData *)data {
//    [receivedData appendData:data];
//}

- (void)connection:(NSURLConnection*)connection didReceiveResponse:(NSHTTPURLResponse*)reResponse
{
 
    self.response =reResponse;
}

- (BOOL) sendWeiBo:(NSString *)acctoken
{
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

@end
