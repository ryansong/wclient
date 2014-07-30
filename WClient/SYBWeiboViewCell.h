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

@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, strong) UILabel *username;
@property (nonatomic, strong) UILabel *creatTime;
@property (nonatomic, strong) UILabel *repost_comment;
@property (nonatomic, strong) UILabel *creatin;

@property (nonatomic, strong) UILabel *poTextLabel;
@property (nonatomic, strong) SYBWeiboImageView *poImage;

@property (nonatomic, strong) UIView *repoArea;
@property (nonatomic, strong) UIView *repoBar;
@property (nonatomic, strong) UILabel *repoUsername;
@property (nonatomic, strong) UILabel *repoText;
@property (nonatomic, strong) SYBWeiboImageView *repoImage;

@property (nonatomic, strong) UIButton *likeButton;
@property (nonatomic, strong) UIButton *retwitterButton;
@property (nonatomic, strong) UIButton *commentButton;

@end