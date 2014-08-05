//
//  SYBAttibutedViewCell.h
//  WClient
//
//  Created by Song Xiaoming on 8/6/14.
//  Copyright (c) 2014 Song Xiaoming. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SYBAttibutedViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIImageView *iconview;
@property (nonatomic, weak) IBOutlet UILabel *username;
@property (nonatomic, weak) IBOutlet UILabel *commentText;

@end
