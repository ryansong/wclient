//
//  SYBWeiboPopoverViewController.m
//  WClient
//
//  Created by ryan on 14-8-4.
//  Copyright (c) 2014年 Song Xiaoming. All rights reserved.
//

#import "SYBWeiboPopoverViewController.h"

@implementation SYBWeiboPopoverViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    _likeCount = _status.attitudes_count;
    _retweetCount = _status.reposts_count;
    _commentCount = _status.comments_count;
    
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 88;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _likeCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"attibutedCell"];
    return cell;
}



@end
