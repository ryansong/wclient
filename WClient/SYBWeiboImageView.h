//
//  SYBWeiboImageView.h
//  WClient
//
//  Created by Song Xiaoming on 3/29/14.
//  Copyright (c) 2014 Song Xiaoming. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AFNetworking.h>

@interface SYBWeiboImageView : UIView

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) NSString *imageURL;
@property (nonatomic, strong) UIProgressView *progressBar;

@property (nonatomic, strong) NSMutableData *imageData;

@property (nonatomic, assign) NSUInteger totalBytes;
@property (nonatomic, assign) NSUInteger receivedBytes;

//- (void)loadMiddleImageWithProgress;

@end
