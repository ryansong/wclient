//
//  SYBViewController.h
//  WClient
//
//  Created by Song Xiaoming on 13-8-23.
//  Copyright (c) 2013年 Song Xiaoming. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SYBWeiboEngine.h"


@interface SYBViewController : UIViewController <UIWebViewDelegate>

@property(nonatomic,retain)UIWebView *webView;

@property(nonatomic,retain)NSMutableData *receivedData;

@property(nonatomic)NSHTTPURLResponse *response;

@end
