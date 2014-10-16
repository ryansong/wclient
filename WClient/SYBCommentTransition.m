//
//  SYBCommentTransition.m
//  WClient
//
//  Created by ryan on 14-8-14.
//  Copyright (c) 2014年 Song Xiaoming. All rights reserved.
//

#import "SYBCommentTransition.h"
#import "SYBCommentViewController.h"
#import "SYBWeiboActionViewController.h"

@implementation SYBCommentTransition


- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return _duration;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext{
    
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *fromView = fromVC.view;
    UIView *toView = toVC.view;
    UIView *containerView = [transitionContext containerView];
    
    if (_presenting) {
        if ([toVC isKindOfClass:[SYBCommentViewController class]]){
            
            [containerView addSubview:toView];
            
            [fromVC.view setUserInteractionEnabled:NO];
            
            CGRect screenFrame = [UIScreen mainScreen].bounds;
            CGRect originFrame = toView.frame;
            toView.frame = CGRectOffset(originFrame, -screenFrame.size.width, 0);
            
            [UIView animateWithDuration:_duration
                                  delay:0.0
                                options:UIViewAnimationOptionCurveLinear
                             animations:^{
                                 fromVC.view.alpha = 0.5;
                                 toView.frame = originFrame;
                             } completion:^(BOOL finished) {
                                 [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
                             }];
        }
        

    } else {
        
        [toVC.view setUserInteractionEnabled:YES];
        CGRect screenFrame = [UIScreen mainScreen].bounds;
        
        [UIView animateWithDuration:_duration
                              delay:0.0
                            options:UIViewAnimationOptionCurveLinear
                         animations:^{
                             fromView.frame = CGRectOffset(screenFrame, -screenFrame.size.width, 0);
                             toVC.view.alpha = 1.0f;
                         } completion:^(BOOL finished) {
                             [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
                         }];
    }

    
}

@end
