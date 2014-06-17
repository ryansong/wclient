//
//  SYBWeiboCell.h
//  WClient
//
//  Created by Song Xiaoming on 6/18/14.
//  Copyright (c) 2014 Song Xiaoming. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SYBWeiBo.h"

@interface SYBWeiboCell : NSObject

@property (nonatomic, strong) SYBWeiBo *weibo;
@property (nonatomic, assign) CGFloat poHeight;
@property (nonatomic, assign) CGFloat repoHeight;
@property (nonatomic, assign) CGFloat cellHeight;

@end
