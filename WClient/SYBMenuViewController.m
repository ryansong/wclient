//
//  SYBMenuViewController.m
//  WClient
//
//  Created by Song Xiaoming on 13-11-17.
//  Copyright (c) 2013年 Song Xiaoming. All rights reserved.
//

#import "SYBMenuViewController.h"
#import "SYBListViewController.h"
#import "SYBWeiboUser.h"
#import "SYBWeiboAPIClient.h"
#import "SSKeychain.h"

@interface SYBMenuViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UIActionSheet *loginActionSheet;
@property (nonatomic, strong) UINavigationController *rootController;
@property (nonatomic, strong) SYBWeiboUser *user;

@property (weak, nonatomic) IBOutlet UIImageView *userImageView;
@property (weak, nonatomic) IBOutlet UITableView *configMenuListView;
@property (weak, nonatomic) IBOutlet UILabel *username;
@property (weak, nonatomic) IBOutlet UILabel *userInfo;
@property (weak, nonatomic) IBOutlet UIButton *logoutButton;

@property (nonatomic, strong) NSArray *groupArray;

@end

@implementation SYBMenuViewController

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
    
    _loginActionSheet = [[UIActionSheet alloc] initWithTitle:@"Profile"
                                                    delegate:self
                                           cancelButtonTitle:@"Cancel"
                                      destructiveButtonTitle:@"Login Off"
                                           otherButtonTitles:nil];

    [[SYBWeiboAPIClient sharedClient] getUserInfoWithSource:nil
                                                        uid:nil
                                                screen_name:nil
                                                    success:^(NSDictionary *dict) {
                                                        _user = [[SYBWeiboUser alloc] init];
                                                        _user.idstr = dict[@"idstr"];
                                                        _user.screen_name = dict[@"screen_name"];
                                                        _user.location = dict[@"location"];
                                                        _user.profile_image_url = dict[@"avatar_large"];
                                                        _user.profile_url = dict[@"profile_url"];
                                                        
                                                        _userImageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:_user.profile_image_url]]];
                                                        _userInfo.text = dict[@"description"];
                                                        _username.text = dict[@"screen_name"];
                                                        
                                                        NSString *friends_count = [NSString stringWithFormat:@"关注%@",[dict[@"friends_count"] stringValue]];
                                                        [self.following setTitle:friends_count forState:UIControlStateNormal];
                                                        
                                                        NSString *followers_count = [NSString stringWithFormat:@"粉丝%@",[dict[@"followers_count"] stringValue]];
                                                        [self.follower setTitle:followers_count forState:UIControlStateNormal];
                                                        
                                                        NSString *statuses_count = [NSString stringWithFormat:@"微博%@",[dict[@"statuses_count"] stringValue]];
                                                        [self.twitter setTitle:statuses_count forState:UIControlStateNormal];
                                                        
                                                    } failure:^(PBXError error) {
                                                        
                                                    }];

    
    UITapGestureRecognizer *iconGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                            action:@selector(tapIconGestureRecognizer:)];
    [_userImageView addGestureRecognizer:iconGestureRecognizer];
}

#pragma mark -- UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.groupArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
     static NSString *const cellIdenitifier = @"groupIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdenitifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdenitifier];
    }
    
    return cell;
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tapIconGestureRecognizer:(UITapGestureRecognizer *)panGestureRecognizer
{
    [_loginActionSheet showInView:self.view];
    
}

#pragma -UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // choose logoff
    if (buttonIndex == 0) {
        self.user = nil;
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"uid"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [self dismissViewControllerAnimated:YES completion:nil];
     
//        [self performSegueWithIdentifier:@"logoff" sender:self];
    }
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 88;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"menuCell"];
    return cell;
}

@end
