//
//  SYBWeiboPopoverViewController.m
//  WClient
//
//  Created by ryan on 14-8-4.
//  Copyright (c) 2014年 Song Xiaoming. All rights reserved.
//

#import "SYBWeiboCommentViewController.h"
#import "SYBWeiboAPIClient.h"
#import "SYBWeiBoComment.h"
#import "SYBAttibutedViewCell.h"
#import "SYBWeiboRetweet.h"

@implementation SYBWeiboCommentViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    _likeCount = _status.attitudes_count;
    _retweetCount = _status.reposts_count;
    _commentCount = _status.comments_count;
    
    _contentType = SYBWeiboDetailContentTypeComment;
    _contentSwitch.selectedSegmentIndex = _contentType;
    
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
                                                         _items = _commentArray;
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
    if (_items) {
        return [_items count];
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SYBAttibutedViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"attibutedCell"];
    
    if (_contentType == SYBWeiboDetailContentTypeComment) {
        SYBWeiBoComment *comment = [_items objectAtIndex:indexPath.row];
        cell.username.text = comment.user.name;
        cell.commentText.text = comment.text;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:comment.user.profile_image_url]]];
            dispatch_async(dispatch_get_main_queue(), ^{
                cell.iconview.image = image;
            });
        });
    } else if (_contentType == SYBWeiboDetailContentTypeRetweet){
        SYBWeiboRetweet *retweet = [_items objectAtIndex:indexPath.row];
        cell.username.text = retweet.user.name;
        cell.commentText.text = retweet.text;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:retweet.user.profile_image_url]]];
            dispatch_async(dispatch_get_main_queue(), ^{
                cell.iconview.image = image;
            });
        });
    }
    
    return cell;
}



- (IBAction)itemChanged:(id)sender {
    if (_contentSwitch.selectedSegmentIndex == 0){
        _contentType = SYBWeiboDetailContentTypeAttitude;
        _items = _likeArray;
        [_listTableView reloadData];
    } else if (_contentSwitch.selectedSegmentIndex == 1) {
        _contentType = SYBWeiboDetailContentTypeRetweet;
        _items = _retweetArray;
        if (_items) {
            [_listTableView reloadData];
        }
        [self getRetweets];
    } else {
        // default switch to comment
        _contentType = SYBWeiboDetailContentTypeComment;
        _items = _commentArray;
        [_listTableView reloadData];
    }
}

- (void)getRetweets
{
    [[SYBWeiboAPIClient sharedClient] getRetweetsWithWeiboID:_status.weiboId
                                                    since_id:0
                                                      max_id:0
                                                       count:0
                                                        page:1
                                            filter_by_author:0
                                                     success:^(NSArray *results){
                                                         _retweetArray = results;
                                                         _items = _retweetArray;
                                                         if (_contentType == SYBWeiboDetailContentTypeRetweet) {
                                                             [_listTableView reloadData];
                                                         }
        
    } failure:^(PBXError error)  {
        
    }];
}
@end
