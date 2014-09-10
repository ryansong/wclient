//
//  SYBWeiboPopoverViewController.m
//  WClient
//
//  Created by ryan on 14-8-4.
//  Copyright (c) 2014年 Song Xiaoming. All rights reserved.
//

#import "SYBWeiboActionViewController.h"
#import "SYBWeiboAPIClient.h"
#import "SYBWeiBoComment.h"
#import "SYBAttibutedViewCell.h"
#import "SYBWeiboRetweet.h"
#import "SYBWeiboAttitude.h"

@implementation SYBWeiboActionViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    _likeCount = _status.attitudes_count;
    _retweetCount = _status.reposts_count;
    _commentCount = _status.comments_count;
    
    _contentType = SYBWeiboActionTypeComment;
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
        tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        return [_items count];
    }
    
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SYBAttibutedViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"attibutedCell"];
    
    if (_contentType == SYBWeiboActionTypeComment) {
        SYBWeiBoComment *comment = [_items objectAtIndex:indexPath.row];
        cell.username.text = comment.user.name;
        cell.commentText.text = comment.text;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:comment.user.profile_image_url]]];
            dispatch_async(dispatch_get_main_queue(), ^{
                cell.iconview.image = image;
            });
        });
    } else if (_contentType == SYBWeiboActionTypeRetweet){
        SYBWeiboRetweet *retweet = [_items objectAtIndex:indexPath.row];
        cell.username.text = retweet.user.name;
        cell.commentText.text = retweet.text;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:retweet.user.profile_image_url]]];
            dispatch_async(dispatch_get_main_queue(), ^{
                cell.iconview.image = image;
            });
        });
    } else if (_contentType == SYBWeiboActionTypeAttitude){
        SYBWeiboAttitude *attitude = [_items objectAtIndex:indexPath.row];
        cell.username.text = attitude.user.name;
        cell.commentText.text = attitude.attitude;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:attitude.user.profile_image_url]]];
            dispatch_async(dispatch_get_main_queue(), ^{
                cell.iconview.image = image;
            });
        });
    }
    
    return cell;
}



- (IBAction)itemChanged:(id)sender {
    if (_contentSwitch.selectedSegmentIndex == 0){
        _contentType = SYBWeiboActionTypeAttitude;
        _items = _likeArray;
        if (_items) {
            [_listTableView reloadData];
        }
        [self getAttitudes];
    } else if (_contentSwitch.selectedSegmentIndex == 1) {
        _contentType = SYBWeiboActionTypeRetweet;
        _items = _retweetArray;
        if (_items) {
            [_listTableView reloadData];
        }
        [self getRetweets];
    } else {
        // default switch to comment
        _contentType = SYBWeiboActionTypeComment;
        _items = _commentArray;
        [_listTableView reloadData];
    }
}

- (IBAction)didPan:(id)sender {
    UIPanGestureRecognizer *panGesture = nil;
    if ([sender isKindOfClass:[UIPanGestureRecognizer class]]) {
        panGesture = (UIPanGestureRecognizer *)sender;
    }
    
    if (panGesture.state == UIGestureRecognizerStateEnded) {
        [self didMoveToParentViewController:nil];
        [self dismissViewControllerAnimated:NO completion:nil];
    } else if (panGesture.state == UIGestureRecognizerStateBegan) {
        [self willMoveToParentViewController:nil];
        CGPoint offPoint = [panGesture translationInView:panGesture.view];
        self.view.frame = CGRectOffset(self.view.frame, offPoint.x, 0);
        [panGesture setTranslation:CGPointZero inView:panGesture.view];
    } else {
        CGPoint offPoint = [panGesture translationInView:panGesture.view];
        self.view.frame = CGRectOffset(self.view.frame, offPoint.x, 0);
        [panGesture setTranslation:CGPointZero inView:panGesture.view];
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
                                                         if (_contentType == SYBWeiboActionTypeRetweet) {
                                                             [_listTableView reloadData];
                                                         }
        
    } failure:^(PBXError error)  {
        
    }];
}

- (void)getAttitudes
{
    [[SYBWeiboAPIClient sharedClient] getAttitudesWithWeiboID:_status.weiboId
                                                        count:50
                                                         page:1
                                                      success:^(NSArray *results) {
                                                          _likeArray = results;
                                                          _items = _likeArray;
                                                          if (_contentType == SYBWeiboActionTypeAttitude) {
                                                              [_listTableView reloadData];
                                                          }
    
                                                      } failure:^(PBXError error) {
    
                                                      }];
}

@end
