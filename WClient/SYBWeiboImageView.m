//
//  SYBWeiboImageView.m
//  WClient
//
//  Created by Song Xiaoming on 3/29/14.
//  Copyright (c) 2014 Song Xiaoming. All rights reserved.
//

#import "SYBWeiboImageView.h"

@implementation SYBWeiboImageView

static const CGFloat borderInterval = 10.0f;

- (instancetype)init
{
    return [super init];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        
    }
    
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    if (self) {
        
        CGRect imageFrame = self.frame;

        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(borderInterval, borderInterval, imageFrame.size.width - borderInterval, imageFrame.size.height - borderInterval)];
            
        _imageView.frame = imageFrame;
        [self addSubview:_imageView];
        
        CGRect bounds = self.bounds;
        _imageView.center = CGPointMake(bounds.size.width / 2, bounds.size.height / 2);
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        _imageView.backgroundColor = [UIColor whiteColor];
        
        [self.layer setBorderColor:[UIColor grayColor].CGColor];
        [self.layer setBorderWidth:0.5f];
        
        [self setBackgroundColor:[UIColor whiteColor]];
        }
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    _imageView.frame = self.bounds;
    [self bringSubviewToFront:_imageView];

}

@end
