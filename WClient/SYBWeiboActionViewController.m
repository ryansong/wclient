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

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _likeCount = _status.attitudes_count;
    _retweetCount = _status.reposts_count;
    _commentCount = _status.comments_count;
    
    _contentType = SYBWeiboActionTypeComment;

    
    _listTableView.tableFooterView = [[UIView alloc] init];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // default view in comment
    [self getComments];
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

- (void)viewAttitubed
{
    _contentType = SYBWeiboActionTypeAttitude;
    _items = _likeArray;
    [_listTableView reloadData];
    if (!_items || [_items count] == 0) {
        [self getAttitudes];
    }
}

- (void)viewRetweet
{
    _contentType = SYBWeiboActionTypeRetweet;
    _items = _retweetArray;
    [_listTableView reloadData];
    
    if (!_items || [_items count] == 0) {
        [self getRetweets];
        return;
    }
}

- (void)viewComment
{
    // if switch to comment
    _contentType = SYBWeiboActionTypeComment;
    _items = _commentArray;
    [_listTableView reloadData];
    if (!_items || [_items count] == 0) {
        [self getComments];
        return;
    }
    
}

// todo
// view original Tweet
//- (void)viewTweet
//{
//    _identifier.contentOffset = CGPointMake(0, 0);
//
//    // todo
//}

- (IBAction)itemChanged:(id)sender {
    
    NSInteger selectedItem = ((UISegmentedControl *)sender).selectedSegmentIndex;
    if (selectedItem == SYBWeiboActionTypeAttitude ) {
        [self viewAttitubed];
    } else if (selectedItem == SYBWeiboActionTypeRetweet) {
        [self viewRetweet];
    } else if (selectedItem == SYBWeiboActionTypeComment) {
        [self viewComment];
    }
}

- (IBAction)dismissBtnClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
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

- (void)getComments
{
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

@end
