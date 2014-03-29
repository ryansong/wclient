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

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        if (!_imageView) {
            
            CGRect imageFrame = frame;
            imageFrame.size.width -= borderInterval;
            imageFrame.size.height -= borderInterval;
            
            _imageView = [[UIImageView alloc] initWithFrame:imageFrame];

            [self addSubview:_imageView];
            
            CGRect bounds = self.bounds;
            _imageView.center = CGPointMake(bounds.size.width / 2, bounds.size.height / 2);
            
            _imageView.contentMode = UIViewContentModeScaleAspectFill;
            _imageView.backgroundColor = [UIColor yellowColor];
        }

        [self.layer setBorderColor:[UIColor grayColor].CGColor];
        [self.layer setBorderWidth:0.5f];
        
        [self setBackgroundColor:[UIColor whiteColor]];
    }
    return self;
}
@end
