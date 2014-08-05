//
//  SYBAttibutedViewCell.m
//  WClient
//
//  Created by Song Xiaoming on 8/6/14.
//  Copyright (c) 2014 Song Xiaoming. All rights reserved.
//

#import "SYBAttibutedViewCell.h"

@implementation SYBAttibutedViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
