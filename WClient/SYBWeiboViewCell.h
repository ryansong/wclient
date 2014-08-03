//
//  SYB.h
//  WClient
//
//  Created by Song Xiaoming on 13-11-1.
//  Copyright (c) 2013年 Song Xiaoming. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>
#import "SYBWeiBo.h"
#import "SYBWeiboImageView.h"

@class SYBCellRetweetView;

@interface SYBWeiboViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIImageView *iconView;
@property (nonatomic, weak) IBOutlet UILabel *username;
@property (nonatomic, weak) IBOutlet UILabel *creatTimeAndSource;
@property (nonatomic, weak) IBOutlet UILabel *repost_comment;

@property (nonatomic, weak) IBOutlet UILabel *poTextView;
@property (nonatomic, weak) IBOutlet SYBWeiboImageView *poImage;

@property (nonatomic, weak) IBOutlet UIView *repoArea;
@property (nonatomic, weak) IBOutlet UIView *repoBar;
@property (nonatomic, weak) IBOutlet UILabel *repoUsername;
@property (nonatomic, weak) IBOutlet UILabel *repoTextView;
@property (nonatomic, weak) IBOutlet SYBWeiboImageView *repoImage;

@property (nonatomic, weak) IBOutlet UIButton *likeButton;
@property (nonatomic, weak) IBOutlet UIButton *retwitterButton;
@property (nonatomic, weak) IBOutlet UIButton *commentButton;

@end