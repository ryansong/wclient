//
//  SYBListViewController.h
//  WClient
//
//  Created by Song Xiaoming on 13-10-27.
//  Copyright (c) 2013年 Song Xiaoming. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGORefreshTableHeaderView.h"
#import "SYBWeiboViewCell.h"
#import "APPMacro.h"

typedef enum{
    SYBFetchDataTypeNew = 0,
    SYBFetchDataTypeOld,
    SYBFetchDataTypeUpdate,
} SYBFetchDataType;

@interface SYBListViewController : UIViewController <UITableViewDataSource,
                                                    UITableViewDelegate,
                                                    UIGestureRecognizerDelegate,
                                                    EGORefreshTableHeaderDelegate,
                                                    UIScrollViewDelegate,
                                                    SYBWeiboCellActionDelegate,
                                                    UIViewControllerTransitioningDelegate>

@property (nonatomic, weak) IBOutlet UITableView *listTableView;

@property (nonatomic, strong) EGORefreshTableHeaderView *headerView;

- (void)reloadTableViewDataSourceInType:(SYBFetchDataType)fetchType;
- (void)reloadTableViewDataSource;
- (void)doneLoadingTableViewData;

- (void)fetchNewDate;
- (void)fetchOldDate;


@end
