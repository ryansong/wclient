//
//  SYBWeiboPopoverViewController.h
//  WClient
//
//  Created by ryan on 14-8-4.
//  Copyright (c) 2014年 Song Xiaoming. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SYBWeiBo.h"

typedef NS_ENUM(NSUInteger, SYBWeiboActionType) {
    SYBWeiboActionTypeAttitude,
    SYBWeiboActionTypeRetweet,
    SYBWeiboActionTypeComment,
};

@interface SYBWeiboActionViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) IBOutlet UITableView *listTableView;
@property (nonatomic, strong) SYBWeiBo *status;

@property (nonatomic, strong) NSArray *likeArray;
@property (nonatomic, assign) NSInteger likeCount;
@property (nonatomic, strong) NSArray *retweetArray;
@property (nonatomic, assign) NSInteger retweetCount;
@property (nonatomic, strong) NSArray *commentArray;
@property (nonatomic, assign) NSInteger commentCount;

@property (nonatomic, weak) IBOutlet UIScrollView *identifier;

@property (nonatomic, strong) NSArray *items;
@property (nonatomic, assign) SYBWeiboActionType contentType;;

- (IBAction)viewAttitubed:(id)sender;
- (IBAction)viewComment:(id)sender;
- (IBAction)viewRetweet:(id)sender;
- (IBAction)viewTweet:(id)sender;

@end