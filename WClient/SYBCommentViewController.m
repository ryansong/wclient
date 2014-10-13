//
//  SYBCommentViewController.m
//  WClient
//
//  Created by ryan on 14-8-14.
//  Copyright (c) 2014年 Song Xiaoming. All rights reserved.
//

#import "SYBCommentViewController.h"
#import "SYBWeiboAPIClient.h"

CGFloat const detemineOffset = 40;

@interface SYBCommentViewController ()

@end

@implementation SYBCommentViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
       UIStoryboard *mainStoryBoard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
        self = [mainStoryBoard instantiateViewControllerWithIdentifier:@"commentViewController"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    _username.text = _status.user.name;
    
    UIPanGestureRecognizer *panDismiss = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                                 action:@selector(panDismiss:)];
    [self.view addGestureRecognizer:panDismiss];
}

- (void)panDismiss:(UIPanGestureRecognizer *)panGestureRecognizer
{
    if (panGestureRecognizer.state == UIGestureRecognizerStateEnded ) {
        CGPoint offset = [panGestureRecognizer translationInView:panGestureRecognizer.view];
        
    } else {
       CGPoint offset = [panGestureRecognizer translationInView:panGestureRecognizer.view];
        self.view.frame = CGRectOffset(self.view.frame, 0, offset.y);
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)cancelComment:(id)sender {
    [self dismissViewControllerAnimated:YES completion:NO];
}

- (IBAction)doComment:(id)sender {
    [self postCommentOnWeibo];
    [self dismissViewControllerAnimated:YES completion:NO];
}

- (void)postCommentOnWeibo
{
    int comment_ori = 0;
    if (_retweetButton.isSelected) {
        comment_ori = 1;
    }
    
    SYBWeiboAPIClient *_sharedClient = [SYBWeiboAPIClient sharedClient];
    [_sharedClient postCommentOnWeibo:_status.weiboId
                              comment:_comment.text
                          comment_ori:comment_ori
                                  rip:nil
                              success:^(NSDictionary * dict) {
    
                          } failure:^(PBXError error) {
    
                          }];
}

- (IBAction)clickRetweet:(id)sender {
    _retweetButton.selected = !_retweetButton.isSelected;
    
    [self dismissViewControllerAnimated:YES completion:NO];
}
@end
