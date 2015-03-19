//
//  SYBPlistManagment.m
//  WClient
//
//  Created by Song Xiaoming on 3/18/15.
//  Copyright (c) 2015 Song Xiaoming. All rights reserved.
//

#define KPATH_BASEPATH @""
#define KPATH_ALLWEIBI @""
#define KPATH_GROUP @""

#import "SYBPlistManagment.h"

@implementation SYBPlistManagment


+ (instancetype)sharedPlistManager
{
    static SYBPlistManagment *_management;
    static dispatch_once_t once_token;
    
    dispatch_once(&once_token, ^{
        _management = [[SYBPlistManagment alloc] init];
    });
    
    return _management;
}


- (instancetype)init
{
  self =  [super init];

    if (self) {
        
    }
    
    return self;
}

- (void)saveInPath:(NSString *)path
{
    
    
}

@end
