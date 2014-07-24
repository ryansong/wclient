//
//  SYBWeiboViewController.h
//  WClient
//
//  Created by ryan on 14-7-24.
//  Copyright (c) 2014年 Song Xiaoming. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SYBWeiBo.h"
#import "SYBWeiboViewCell.h"

@interface SYBWeiboViewController : UIViewController

@property (nonatomic, strong) SYBWeiBo *status;
@property (nonatomic, weak) IBOutlet UIView *weiboDetailView;
@property (nonatomic, weak) IBOutlet UIImageView *userIcon;
@property (nonatomic, weak) IBOutlet UILabel *username;
@property (nonatomic, weak) IBOutlet UILabel *postDate;
@property (nonatomic, weak) IBOutlet UITextView *text;
@property (nonatomic, weak) IBOutlet UITextView *repoText;

@property (nonatomic, weak) IBOutlet UIImageView *attachImageView;
@property (nonatomic, weak) IBOutlet UIScrollView *attachImageViews;


@property (nonatomic, weak) IBOutlet UISegmentedControl *forwordAndComment;

@end
