//
//  SYBListViewController.h
//  WClient
//
//  Created by Song Xiaoming on 13-10-27.
//  Copyright (c) 2013年 Song Xiaoming. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SYBListViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, weak) IBOutlet UITableView *listView;
@property (weak, nonatomic) IBOutlet UITextView *rePoText;

@end
