//
//  SYBPopoverSegue.m
//  WClient
//
//  Created by ryan on 14-8-14.
//  Copyright (c) 2014年 Song Xiaoming. All rights reserved.
//

#import "SYBPopoverSegue.h"

@implementation SYBPopoverSegue

- (void)perform
{
    UIView *fromView = ((UIViewController *)self.sourceViewController).view;
    UIView *toView = ((UIViewController *)self.destinationViewController).view;
    
    fromView.transform = CGAffineTransformIdentity;
    toView.transform = CGAffineTransformIdentity;
    
    [UIView animateWithDuration:0.3
                     animations:^{
                         fromView.alpha = 0.5;
                         toView.transform = CGAffineTransformMakeScale(1, 0.9);
                     } completion:^(BOOL finished) {
                         [((UIViewController *)self.sourceViewController) presentViewController:((UIViewController *)self.destinationViewController) animated:YES completion:nil];
                     }];
}

@end
