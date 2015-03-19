//
//  SYBWeiBo+tableViewCell.m
//  WClient
//
//  Created by Song Xiaoming on 3/20/15.
//  Copyright (c) 2015 Song Xiaoming. All rights reserved.
//

#import "SYBWeiBo+tableViewCell.h"

@implementation SYBWeiBo (tableViewCell)

- (WeiboCellType)cellType
{
    if (self.retweeted_status) {
        if (self.retweeted_status.pic_urls && [self.retweeted_status.pic_urls count] > 0) {
            return WeiboCellTypeRepoImage;
        } else {
            return WeiboCellTypeRepoText;
        }
    } else {
        if (self.pic_urls && [self.pic_urls count] > 0) {
            return WeiboCellTypeImage;
        } else {
            return WeiboCellTypeText;
        }
    }
}

@end
