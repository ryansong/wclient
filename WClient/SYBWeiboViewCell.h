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

@protocol SYBWeiboCellActionDelegate <NSObject>

- (void)commentWeibo:(UITableViewCell *)cell;
- (void)retweetWeibo:(UITableViewCell *)cell;

- (void)commentSubWeibo:(UITableViewCell *)cell;
- (void)retweetSubWeibo:(UITableViewCell *)cell;

- (void)viewRepoWeibo:(UITableViewCell *)cell;
- (void)viewWeibo:(UITableViewCell *)cell;

@optional
- (void)postWeiboAttitude:(UITableViewCell *)cell;
@end

@interface SYBWeiboViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIImageView *iconView;
@property (nonatomic, weak) IBOutlet UILabel *username;
@property (nonatomic, weak) IBOutlet UILabel *creatTimeAndSource;

@property (nonatomic, weak) IBOutlet UITextView *poTextView;
@property (nonatomic, weak) IBOutlet SYBWeiboImageView *poImage;

@property (nonatomic, weak) IBOutlet UIView *repoArea;
@property (nonatomic, weak) IBOutlet UIView *repoBar;
@property (nonatomic, weak) IBOutlet UILabel *repoUsername;
@property (nonatomic, weak) IBOutlet UITextView *repoTextView;
@property (nonatomic, weak) IBOutlet SYBWeiboImageView *repoImage;
@property (nonatomic, weak) IBOutlet UIButton *repoLikeButton;
@property (nonatomic, weak) IBOutlet UIButton *repoRetwitterButton;
@property (nonatomic, weak) IBOutlet UIButton *repoCommentButton;

@property (nonatomic, weak) IBOutlet UIButton *likeButton;
@property (nonatomic, weak) IBOutlet UIButton *retwitterButton;
@property (nonatomic, weak) IBOutlet UIButton *commentButton;

@property (nonatomic, strong) UITapGestureRecognizer *gesture;
@property (nonatomic, strong) UITapGestureRecognizer *repoGesture;

@property (nonatomic, assign) id<SYBWeiboCellActionDelegate> cellDelegate;

- (IBAction)retweetWeibo:(id)sender;
- (IBAction)commentOnWeibo:(id)sender;
- (IBAction)postAttitude:(id)sender;

@end