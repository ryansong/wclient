//
//  SYBActionTransition.h
//  WClient
//
//  Created by ryan on 14-10-16.
//  Copyright (c) 2014年 Song Xiaoming. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SYBActionTransition : NSObject <UIViewControllerAnimatedTransitioning>

@property (nonatomic, assign) NSTimeInterval duration;
@property (nonatomic, assign) BOOL presenting;


@end
