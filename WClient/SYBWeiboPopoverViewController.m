//
//  SYBWeiboPopoverViewController.m
//  WClient
//
//  Created by ryan on 14-8-4.
//  Copyright (c) 2014年 Song Xiaoming. All rights reserved.
//

#import "SYBWeiboPopoverViewController.h"
#import "SYBWeiboAPIClient.h"
#import "SYBWeiBoComment.h"
#import "SYBAttibutedViewCell.h"

@implementation SYBWeiboPopoverViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    _likeCount = _status.attitudes_count;
    _retweetCount = _status.reposts_count;
    _commentCount = _status.comments_count;
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[SYBWeiboAPIClient sharedClient] getCommnetsWithWeiboID:_status.weiboId
                                                    since_id:0
                                                      max_id:0
                                                       count:50
                                                        page:1 filter_by_author:0
                                                     success:^(NSArray *comments) {
                                                         _commentArray = comments;
                                                         [_listTableView reloadData];
        
    } failure:^(PBXError error) {
        
    }];
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 88;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_commentArray) {
        return [_commentArray count];
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SYBAttibutedViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"attibutedCell"];
    
    SYBWeiBoComment *comment = [_commentArray objectAtIndex:indexPath.row];
    cell.username.text = comment.user.name;
    cell.commentText.text = comment.text;

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:comment.user.profile_image_url]]];
        dispatch_async(dispatch_get_main_queue(), ^{
            cell.iconview.image = image;
        });
    });
    
    return cell;
}



@end
