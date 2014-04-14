//
//  SYBUserInfoView.h
//  WClient
//
//  Created by Song Xiaoming on 3/30/14.
//  Copyright (c) 2014 Song Xiaoming. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SYBUserInfoView : UIView
@property (nonatomic, weak) IBOutlet UIImageView *userIcon;
@property (nonatomic, weak) IBOutlet UILabel *username;
@property (nonatomic, weak) IBOutlet UILabel *authedIfo;
@property (nonatomic, weak) IBOutlet UILabel *followInfo;
@property (nonatomic, weak) IBOutlet UIButton *followBtn;
@property (nonatomic, weak) IBOutlet UIButton *weiboBtn;

- (IBAction)doFollow:(id)sender;
- (IBAction)gotoWeiboView:(id)sender;
@end
