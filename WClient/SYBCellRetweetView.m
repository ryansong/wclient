//
//  SYBCellRetweetView.m
//  WClient
//
//  Created by Song Xiaoming on 13-12-1.
//  Copyright (c) 2013年 Song Xiaoming. All rights reserved.
//

#import "SYBCellRetweetView.h"

@implementation SYBCellRetweetView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    
    _repoUsername = [[UILabel alloc] init];
    _repoText = [[UILabel alloc] init];
    _repoImageView = [[UIImageView alloc] init];
    
    [self addSubview:_repoUsername];
    [self addSubview:_repoText];
    [self addSubview:_repoImageView];
    return self;
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGRect rectt = CGRectMake(100 ,100, 100, 100);//坐标
    CGContextSetRGBFillColor(context, 61/ 255.0f, 122/ 255.0f, 160/ 255.0f,0.2);//颜色（RGB）,透明度
    CGContextFillRect(context, rectt);
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
