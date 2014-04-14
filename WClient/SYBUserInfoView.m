//
//  SYBUserInfoView.m
//  WClient
//
//  Created by Song Xiaoming on 3/30/14.
//  Copyright (c) 2014 Song Xiaoming. All rights reserved.
//

#import "SYBUserInfoView.h"

@implementation SYBUserInfoView

- (id)init
{
    self = [super init];
    if (self) {
        NSArray *nibs = [[NSBundle mainBundle] loadNibNamed:@"SYBUserInfoView" owner:self options:nil];
        self = nibs[0];
        
        if (_followBtn) {
            _followBtn.layer.borderWidth = 1.0f;
            _followBtn.layer.masksToBounds = YES;
            [_followBtn.layer setCornerRadius:10];
            _followBtn.backgroundColor = [UIColor blueColor];
        }
        
        if (_weiboBtn) {
            _weiboBtn.layer.borderWidth = 1.0f;
        }
    }
    return self;

}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (IBAction)doFollow:(id)sender {
}

- (IBAction)gotoWeiboView:(id)sender {
}
@end
