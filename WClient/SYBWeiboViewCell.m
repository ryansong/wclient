//
//  SYB.m
//  WClient
//
//  Created by Song Xiaoming on 13-11-1.
//  Copyright (c) 2013年 Song Xiaoming. All rights reserved.
//

#import "SYBWeiboViewCell.h"

@implementation SYBWeiboViewCell

- (id)init
{
    self = [super init];
    if (self) {
      
    }
    return self;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)prepareForReuse
{
    NSString *iconPath = [[NSBundle mainBundle] pathForResource:@"UserIcon" ofType:@"png"];
   UIImage *defalutUserIcon = [UIImage imageWithContentsOfFile:iconPath];
    _iconView.image = defalutUserIcon;
    _poImage.imageView.image = nil;
    _repoImage.imageView.image = nil;
    
}

- (IBAction)postAttitude:(id)sender {
    [_cellDelegate postWeiboAttitude:self];
}

- (IBAction)retweetWeibo:(id)sender {
    
    if (sender == self.repoRetwitterButton)
    {
        [_cellDelegate retweetSubWeibo:self];
    } else if (sender == self.retwitterButton) {
        [_cellDelegate retweetWeibo:self];
    }
}

- (IBAction)commentOnWeibo:(id)sender {
    if (sender == self.repoCommentButton)
    {
        [_cellDelegate commentSubWeibo:self];
    } else if (sender == self.commentButton) {
        [_cellDelegate commentWeibo:self];
    }
}


@end
