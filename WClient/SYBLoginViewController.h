//
//  SYBLoginViewController.h
//  WClient
//
//  Created by Song Xiaoming on 13-10-26.
//  Copyright (c) 2013年 Song Xiaoming. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SYBLoginViewController : UIViewController <UIWebViewDelegate>

@property(nonatomic,retain)UIWebView *webView;
@property(nonatomic,retain)NSMutableData *receivedData;
@property(nonatomic)NSHTTPURLResponse *response;

@end
