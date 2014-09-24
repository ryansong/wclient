//
//  SYBCommentTransition.h
//  WClient
//
//  Created by ryan on 14-8-14.
//  Copyright (c) 2014年 Song Xiaoming. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SYBCommentTransition : NSObject <UIViewControllerAnimatedTransitioning>

@property (nonatomic, assign) NSTimeInterval duration;
@property (nonatomic, assign) BOOL presenting;

@end
