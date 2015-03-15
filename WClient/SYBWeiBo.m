//
//  SYBWeiBo.m
//  WClient
//
//  Created by Song Xiaoming on 13-9-16.
//  Copyright (c) 2013年 Song Xiaoming. All rights reserved.
//

#import "SYBWeiBo.h"

@implementation SYBWeiBo

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:_created_at forKey:@"created_at"];
    
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    if (!self) {
        self = [[SYBWeiBo alloc] init];
    }
    
    return self;
}
@end
