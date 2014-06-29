//
//  SYBMenuViewController.m
//  WClient
//
//  Created by Song Xiaoming on 13-11-17.
//  Copyright (c) 2013年 Song Xiaoming. All rights reserved.
//

#import "SYBMenuViewController.h"
#import "SYBListViewController.h"

@interface SYBMenuViewController ()

@property (nonatomic, strong) UINavigationController *rootController;

@end

@implementation SYBMenuViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"left" ofType:@"png"];
    UIImage *image = [UIImage imageWithContentsOfFile:path];
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    [self.view addSubview:imageView];
    
    _rootController = [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"navigationController"];
    [self addChildViewController:_rootController];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self.view addSubview:_rootController.view];
    [_rootController didMoveToParentViewController:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
