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
    
    UITapGestureRecognizer *tapGestureForCell = [[UITapGestureRecognizer alloc]
                                                 initWithTarget:self
                                                 action:@selector(handleCellTap:)];
    [_iconView addGestureRecognizer:tapGestureForCell];
    
    UITapGestureRecognizer *tapImage = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showFullImage:)];
    
    [_poImage addGestureRecognizer:tapImage];

    UITapGestureRecognizer *tapRepoImage = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showFullImage:)];
    [_repoImage addGestureRecognizer:tapRepoImage];
}

- (void)prepareForReuse
{
    NSString *iconPath = [[NSBundle mainBundle] pathForResource:@"UserIcon" ofType:@"png"];
   UIImage *defalutUserIcon = [UIImage imageWithContentsOfFile:iconPath];
    _iconView.image = defalutUserIcon;
    _poImage.imageView.image = nil;
    _repoImage.imageView.image = nil;
    
}
@end
