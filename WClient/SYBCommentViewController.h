//
//  SYBCommentViewController.h
//  WClient
//
//  Created by ryan on 14-8-14.
//  Copyright (c) 2014年 Song Xiaoming. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SYBWeiBo.h"

typedef NS_ENUM(NSInteger, SYBCommentViewType){
    SYBCommentViewTypeCommnet,
    SYBCommentViewTypeRetweet,
};

@interface SYBCommentViewController : UIViewController

@property (nonatomic, strong) SYBWeiBo *status;
@property (weak, nonatomic) IBOutlet UILabel *username;
@property (weak, nonatomic) IBOutlet UILabel *viewTitle;
@property (weak, nonatomic) IBOutlet UITextView *comment;
@property (weak, nonatomic) IBOutlet UILabel *commentCount;

@property (weak, nonatomic) IBOutlet UIView *commentView;
@property (weak, nonatomic) IBOutlet UIButton *retweetSwitch;
@property (weak, nonatomic) IBOutlet UIButton *postComment;


@property (nonatomic ,assign) SYBCommentViewType viewType;

- (IBAction)clickRetweet:(id)sender;
- (IBAction)cancelComment:(id)sender;
- (IBAction)doComment:(id)sender;

@end
