//
//  SYBMenuViewController.h
//  WClient
//
//  Created by Song Xiaoming on 13-11-17.
//  Copyright (c) 2013年 Song Xiaoming. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SYBMenuViewController : UIViewController <UIActionSheetDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UIButton *following;
@property (weak, nonatomic) IBOutlet UIButton *follower;
@property (weak, nonatomic) IBOutlet UIButton *twitter;
@property (weak, nonatomic) IBOutlet UITableView *groupList;

@end
