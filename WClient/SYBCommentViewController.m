//
//  SYBCommentViewController.m
//  WClient
//
//  Created by ryan on 14-8-14.
//  Copyright (c) 2014年 Song Xiaoming. All rights reserved.
//

#import "SYBCommentViewController.h"
#import "SYBWeiboAPIClient.h"
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
    
    if (_viewType == SYBCommentOriComment) {
        _viewTitle.text = Comment;
        [_postComment setTitle:Comment forState:UIControlStateNormal];
        
        //todo
        // comment same time
        
        
    } else {
        _viewTitle.text = Retweet;
        [_postComment setTitle:@"Retweet" forState:UIControlStateNormal];
        
        //
        
        //todo
        // retweet same time
        
    }
    
    //todo
    [_retweetSwitch removeFromSuperview];
}

- (void)panDismiss:(UIPanGestureRecognizer *)panGestureRecognizer
{
    if (panGestureRecognizer.state == UIGestureRecognizerStateEnded ) {
//        CGPoint offset = [panGestureRecognizer translationInView:panGestureRecognizer.view];
        
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
    SYBWeiboAPIClient *sharedClient = [SYBWeiboAPIClient sharedClient];
    
    if (_viewType == SYBCommentViewTypeCommnet){
    
        SYBCommentOriType comment_ori = SYBCommentOriComment;
        if (_retweetSwitch.isSelected) {
            comment_ori = SYBCommentOriRetweet;
        }
        
        
        [sharedClient postCommentOnWeibo:_status.weiboId
                                  comment:_comment.text
                              comment_ori:comment_ori
                                      rip:nil
                                  success:^(NSDictionary * dict) {
        
                              } failure:^(PBXError error) {
        
                              }];
    } else {
       [sharedClient repostWeibo:_status.weiboId
                          status:_comment.text
                       isComment:1
                             rip:nil
                         success:^(NSDictionary *dict) {
           
       }
                         failure:^(PBXError error) {
           
       }];
    }
}

- (IBAction)clickRetweet:(id)sender {
    _retweetSwitch.selected = !_retweetSwitch.isSelected;
}


@end
