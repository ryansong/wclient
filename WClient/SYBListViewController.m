//
//  SYBListViewController.m
//  WClient
//
//  Created by Song Xiaoming on 13-10-27.
//  Copyright (c) 2013年 Song Xiaoming. All rights reserved.
//

#import "SYBListViewController.h"
#import "SYBWeiboAPIClient.h"
#import "SYBWeiBo.h"
#import "SYBListWeiBoCellView.h"

@interface SYBListViewController ()
@property (strong, nonatomic) NSArray *items;
@end

@implementation SYBListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self getWeibo];
    
}

- (void)loadView
{
    [super loadView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (!_items) {
        return 0;
    }
    
    return _items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SYBListWeiBoCellView *cell = [tableView dequeueReusableCellWithIdentifier:@"weiboCell"];
    SYBWeiBo *weibo = [_items objectAtIndex:indexPath.row];
    NSString *po = weibo.text;
    cell.rePoText.text = po;
    [cell.rePoText setFont:[UIFont fontWithName:@"Helvetica Neue" size:14.0]];
    [cell.rePoText setScrollEnabled:NO];

    return cell;
}

- (void)getWeibo{

    [[SYBWeiboAPIClient sharedClient] getAllFriendsWeibo:0 max_id:0 count:0 base_app:0 feature:0 trim_user:0
success:^(NSArray *result) {
    _items = result;
    [_listView reloadData];
} failure:^(PBXError errorCode) {
    //TODO:错误处理
    NSLog(@"login failed. error code:%d", errorCode);
}];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SYBWeiBo *weibo = [_items objectAtIndex:indexPath.row];
    NSString *str = weibo.text;
    CGSize size = [str sizeWithFont:[UIFont fontWithName:@"Helvetica Neue" size:14.0] constrainedToSize:CGSizeMake(320-16, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
    
    NSLog(@"%d and %f", str.length,size.height);

    return size.height+16;
}
@end
