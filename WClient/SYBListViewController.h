//
//  SYBListViewController.h
//  WClient
//
//  Created by Song Xiaoming on 13-10-27.
//  Copyright (c) 2013年 Song Xiaoming. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGORefreshTableHeaderView.h"
#import "SYBWeiboCell.h"


@interface SYBListViewController : UIViewController <UITableViewDataSource,
                                                    UITableViewDelegate,
                                                    UIGestureRecognizerDelegate,
                                                    EGORefreshTableHeaderDelegate,
                                                    UIScrollViewDelegate>

@property (nonatomic, weak) IBOutlet UITableView *listTableView;

@property (nonatomic,weak) IBOutlet UINavigationBar *navigationBar;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *leftItem;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *rightItem;

- (IBAction)signOut:(id)sender;


@property (nonatomic, strong) EGORefreshTableHeaderView *headerView;

- (void)reloadTableViewDataSource;
- (void)doneLoadingTableViewData;


@end
