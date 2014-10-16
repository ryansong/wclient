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

@interface SYBCommentViewController ()<UITextViewDelegate>

@end

@implementation SYBCommentViewController

NSInteger commentLimit = 140;

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
    
    if (_viewType == SYBCommentViewTypeCommnet) {
        _viewTitle.text = Comment;
        [_postComment setTitle:Comment forState:UIControlStateNormal];
        
        // set cursor
        _comment.selectedRange = NSMakeRange(0, 0);
        [_comment becomeFirstResponder];
        
        //todo
        // comment same time
        
        
    } else {
        _viewTitle.text = Retweet;
        [_postComment setTitle:Retweet forState:UIControlStateNormal];
        
        // set origin repo text
        if (_status.retweeted_status) {
            NSString *commentText = [[NSString alloc] initWithFormat:@"%@%@%@", @"//@", _status.user.name, _status.text];
            [_comment setText: commentText];
        }
        // set cursor
        _comment.selectedRange = NSMakeRange(0, 0);
        [_comment becomeFirstResponder];
        
        //todo
        // retweet same time
        
    }
    
    _comment.delegate = self;
    
    // update the count of comment
    NSString *commnet = _comment.text;
    NSInteger currentLength = commnet.length;
    NSString *avariableCommentCount = [[NSNumber numberWithInteger:(commentLimit - currentLength)] stringValue];
    _commentCount.text = avariableCommentCount;

    
    //todo
    [_retweetSwitch removeFromSuperview];
    
    UIPanGestureRecognizer *panDismiss = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                                 action:@selector(panDismiss:)];
    [self.view addGestureRecognizer:panDismiss];
}

- (void)panDismiss:(UIPanGestureRecognizer *)panGestureRecognizer
{
    if (panGestureRecognizer.state == UIGestureRecognizerStateEnded ) {
        
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

#pragma mark UITextViewDelegate

-(void)textViewDidChange:(UITextView *)textView
{
    //update the count of comment
    NSString *commnet = textView.text;
    NSInteger currentLength = commnet.length;
    NSString *avariableCommentCount = [[NSNumber numberWithInteger:(commentLimit - currentLength)] stringValue];
    _commentCount.text = avariableCommentCount;
}

@end
