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
#import "SYBWeiboViewCell.h"
#import "APPMacro.h"

@interface SYBListViewController : UIViewController <UITableViewDataSource,
                                                    UITableViewDelegate,
                                                    UIGestureRecognizerDelegate,
                                                    EGORefreshTableHeaderDelegate,
                                                    UIScrollViewDelegate,
                                                    SYBWeiboCellActionDelegate,
                                                    UIViewControllerTransitioningDelegate>

@property (nonatomic, weak) IBOutlet UITableView *listTableView;

- (IBAction)signOut:(id)sender;

@property (nonatomic, strong) EGORefreshTableHeaderView *headerView;

- (void)reloadTableViewDataSource;
- (void)doneLoadingTableViewData;


@end
