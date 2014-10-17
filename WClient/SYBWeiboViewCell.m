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

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    if (self) {
        UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapWeibo)];
        
        [self addGestureRecognizer:gesture];
        
        UITapGestureRecognizer *repoGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapRepoWeibo)];
        
        [_repoArea addGestureRecognizer:repoGesture];
        _repoArea.userInteractionEnabled = YES;
    }
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


- (void)tapWeibo
{
    [self.cellDelegate viewWeibo:self];
}

- (void)tapRepoWeibo
{
    [self.cellDelegate viewRepoWeibo:self];
}


- (void)dealloc
{
    [self addGestureRecognizer:nil];
    [_repoArea addGestureRecognizer:nil];
}

@end
