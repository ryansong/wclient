//
//  SYBWeiboCell.m
//  WClient
//
//  Created by Song Xiaoming on 6/18/14.
//  Copyright (c) 2014 Song Xiaoming. All rights reserved.
//

#import "SYBWeiboCell.h"


@implementation SYBWeiboCell

- (WeiboCellType)cellType
{
    if (_weibo.retweeted_status) {
        if (_weibo.retweeted_status.pic_urls && [_weibo.retweeted_status.pic_urls count] > 0) {
            return WeiboCellTypeRepoImage;
        } else {
            return WeiboCellTypeRepoText;
        }
    } else {
        if (_weibo.pic_urls && [_weibo.pic_urls count] > 0) {
            return WeiboCellTypeImage;
        } else {
            return WeiboCellTypeText;
        }
    }
}

@end
