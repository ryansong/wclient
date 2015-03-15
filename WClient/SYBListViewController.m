//
//  SYBListViewController.m
//  WClient
//
//  Created by Song Xiaoming on 13-10-27.
//  Copyright (c) 2013年 Song Xiaoming. All rights reserved.
//

#import <SSKeychain.h>
#import "SYBListViewController.h"
#import "SYBWeiboAPIClient.h"
#import "SYBWeiBo.h"
#import "SYBWeiboViewCell.h"
#import "SYBMenuViewController.h"
#import "SYBCellRetweetView.h"
#import "RegexKitLite.h"
#import "SYBUserInfoView.h"
#import "SYBWeiboViewController.h"
#import "SYBWeiboActionViewController.h"
#import "SYBWeiboActionViewController.h"
#import "SYBCommentViewController.h"
#import "SYBCommentTransition.h"
#import "SYBActionTransition.h"


#import "UIColor+hex.h"

#define ALABEL_EXPRESSION @"@[\u4e00-\u9fa5a-zA-Z0-9_-]{4,30}"
#define HREF_PROPERTY_IN_ALABEL_EXPRESSION @"(href\\s*=\\s*(?:\"([^\"]*)\"|\'([^\']*)\'|([^\"\'>\\s]+)))"
#define URL_EXPRESSION @"([hH][tT][tT][pP][sS]?:\\/\\/[^ ,'\">\\]\\)]*[^\\. ,'\">\\]\\)])"
#define AT_IN_WEIBO_EXPRESSION @"(@[\u4e00-\u9fa5a-zA-Z0-9_-]{4,30})"
#define TOPIC_IN_WEIBO_EXPRESSION @"(#[^#]+#)"


static NSString *textCellIdentifier = @"weiboCellText";
static NSString *imageCellIdentifier = @"weiboCellImage";
static NSString *repoTextCellIdentifier = @"weiboCellRepotext";
static NSString *repoImageCellIdentifier = @"weiboCellRepoImage";

@interface SYBListViewController ()
@property (nonatomic, strong) NSArray *items;
@property (nonatomic, strong) NSMutableDictionary *iconDict;
@property (nonatomic, strong) NSString *client_id;
@property (nonatomic, strong) NSString *client_secret;

@property (nonatomic, strong) SYBUserInfoView *userInfo;

@property (nonatomic, strong) SYBWeiboViewCell *prototype;
@property (nonatomic, strong) SYBWeiboImageView *imageView;

@property (nonatomic, strong) UIImageView *fullImageView;
@property (nonatomic, strong) NSTimer *imageLoadTimer;
@property (nonatomic, strong) UIProgressView *imageProgress;
@property (nonatomic, strong) UIViewController *parentController;

@property (nonatomic, strong) NSString *fullImageUrl;

@property (nonatomic, strong) UIPanGestureRecognizer *dynamicTransitionPanGesture;

@property (nonatomic, strong) UIStoryboard *mainStoryboard;

@end

@implementation SYBListViewController
{
    BOOL loading;
}

static const float MAX_VIEW_SLID_POINT_X = 400.0f;
static const float MIN_VIEW_SLID_POINT_X = 160.0f;
static const float DIVIDWIDTH = 320.0f;

static const double SYBMINTUESECONDS = 60;
static const double SYBHOURSECONDS = 60*60;
static const double SYBDAYSECONDS = 24*60*60;

static const float CELL_CONTENT_WIDTH = 320.0f;
static const float CELL_CONTENT_MARGIN = 6.0f;

static const float CELL_ICON_HEIGHT = 50.0f;
static const float CELL_REPOUSERNAME_HEIGHT = 21.0f;
static const float IMAGE_WIDTH = 130.0;
static const float CELL_ATTIBUTED_HEIGHT = 10.0f;

static UIImage *defalutUserIcon;
static UIImage *noImage;
static UIImage *defaultImage;

static NSString * const smallImageFolder = @"thumbnail";
static NSString * const middleImageFolder = @"bmiddle";
static NSString * const largeImageFolder = @"mw1024";

+(void)initialize
{
    [super initialize];
    
    NSString *iconPath = [[NSBundle mainBundle] pathForResource:@"UserIcon" ofType:@"png"];
    defalutUserIcon = [UIImage imageWithContentsOfFile:iconPath];
    
    NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"NoImage" ofType:@"png"];
    noImage = [UIImage imageWithContentsOfFile:imagePath];
    
    NSString *defaultImagePath = [[NSBundle mainBundle] pathForResource:@"Default" ofType:@"png"];
    defaultImage = [UIImage imageWithContentsOfFile:defaultImagePath];


}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _listTableView.rowHeight = UITableViewAutomaticDimension;
    
    [_listTableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    [_listTableView setSeparatorColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"Divider_line@2x.png"]]];
    
#pragma add headerView
    if (_headerView == nil) {
		
		EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - _listTableView.bounds.size.height, _listTableView.frame.size.width, _listTableView.bounds.size.height)];
		view.delegate = self;
		[_listTableView addSubview:view];
		_headerView = view;
	}
    
    _listTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _listTableView.frame.size.width, 44)];
    _mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    
    
    [self getWeibo];
}

- (void)loadView
{
    [super loadView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [_listTableView reloadData];
}

#pragma mark -- UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (!_items) {
        return 0;
    }
    return _items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier;
    
    SYBWeiboCell *status = [_items objectAtIndex:[indexPath row]];

    switch (status.cellType) {
        case WeiboCellTypeText:
            CellIdentifier = textCellIdentifier;
            break;
            
        case WeiboCellTypeImage:
            CellIdentifier = imageCellIdentifier;
            break;
            
        case WeiboCellTypeRepoText:
            CellIdentifier = repoTextCellIdentifier;
            break;

        case WeiboCellTypeRepoImage:
            CellIdentifier = repoImageCellIdentifier;
            break;
            
        default:
            break;
    }
    
    SYBWeiboViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell.cellDelegate = self;
    
    
    UITapGestureRecognizer *tapGestureForCell = [[UITapGestureRecognizer alloc]
                                                 initWithTarget:self
                                                 action:@selector(handleCellTap:)];
    [cell.iconView addGestureRecognizer:tapGestureForCell];
    
    UITapGestureRecognizer *tapImage = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showFullImage:)];
    
    [cell.poImage addGestureRecognizer:tapImage];
    
    UITapGestureRecognizer *tapRepoImage = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showFullImage:)];
    [cell.repoImage addGestureRecognizer:tapRepoImage];

    cell.tag = indexPath.row;
    
    [self setViewCell:cell withIndex:indexPath];
    
    // update layout after set text
    [cell layoutIfNeeded];
    
    return cell;
}

- (void)caculateHeigtForCell:(SYBWeiboCell *)weiboCell
{
    if (!_prototype) {
        _prototype = [_listTableView dequeueReusableCellWithIdentifier:@"weiboCellRepotext"];
    }
    _prototype.poTextView.text = nil;
    _prototype.repoTextView.text = nil;
    
    _prototype.poTextView.text = weiboCell.weibo.text;
    [_prototype.poTextView sizeToFit];
    weiboCell.poHeight = _prototype.poTextView.frame.size.height;

    switch (weiboCell.cellType) {
        case WeiboCellTypeText:
            break;
            
        case WeiboCellTypeImage:

            break;
            
        case WeiboCellTypeRepoText:
            _prototype.repoTextView.text = weiboCell.weibo.retweeted_status.text;
            [_prototype.repoTextView sizeToFit];
            weiboCell.repoHeight = _prototype.repoTextView.frame.size.height;
            break;
            
        case WeiboCellTypeRepoImage:
            _prototype.repoTextView.text = weiboCell.weibo.retweeted_status.text;
            [_prototype.repoTextView sizeToFit];
            weiboCell.repoHeight = _prototype.repoTextView.frame.size.height;
            break;
            
        default:
            break;
    }

    
    // height of user icon&username
    weiboCell.cellHeight = CELL_CONTENT_MARGIN + CELL_ICON_HEIGHT;
    //height of weibo text
    weiboCell.cellHeight +=  CELL_CONTENT_MARGIN + weiboCell.poHeight;
    //height of weibo attibuted
    weiboCell.cellHeight += CELL_CONTENT_MARGIN + CELL_ATTIBUTED_HEIGHT + CELL_CONTENT_MARGIN;
    
    //with po image
    if ([weiboCell.weibo hasPic]) {
        weiboCell.cellHeight += CELL_CONTENT_MARGIN + IMAGE_WIDTH;
        return;
    }
    
    if (weiboCell.weibo.retweeted_status) {
   
        
        //MARGIN for repoArea
        weiboCell.cellHeight += CELL_CONTENT_MARGIN;
        // height of repo username
        weiboCell.cellHeight += CELL_CONTENT_MARGIN + CELL_REPOUSERNAME_HEIGHT;
        weiboCell.cellHeight += CELL_CONTENT_MARGIN + weiboCell.repoHeight;
        
        if ([weiboCell.weibo.retweeted_status hasPic]) {
            weiboCell.cellHeight += CELL_CONTENT_MARGIN + IMAGE_WIDTH;
        }
        
        weiboCell.cellHeight += CELL_CONTENT_MARGIN + CELL_ATTIBUTED_HEIGHT + CELL_CONTENT_MARGIN *4;
    }
}

- (void)setViewCell:(UITableViewCell *)viewCell withIndex:(NSIndexPath *)indexPath
{
    SYBWeiboViewCell *configCell = ((SYBWeiboViewCell *)viewCell);
   SYBWeiBo *status = [[_items objectAtIndex:indexPath.row] weibo];
    configCell.poTextView.text = status.text;
    
    configCell.username.text = status.user.name;
    configCell.creatTimeAndSource.text = [NSString stringWithFormat:@"%@ %@", status.created_at, status.source];
    
     SYBWeiboCell *weiboCell = [_items objectAtIndex:[indexPath row]];

    if (weiboCell.cellType == WeiboCellTypeImage) {
        
        configCell.poImage.imageURL = status.pic_urls[0];
        dispatch_async(dispatch_queue_create(0, 0), ^{
            UIImage *cellImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:status.pic_urls[0]]]];
            if (cellImage) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    configCell.poImage.imageView.image = cellImage;
                });
            }
        });
    } else if (weiboCell.cellType == WeiboCellTypeRepoText) {
        configCell.repoUsername.text = status.retweeted_status.user.name;
        configCell.repoTextView.text = status.retweeted_status.text;
    } else if (weiboCell.cellType == WeiboCellTypeRepoImage) {
        configCell.repoUsername.text = status.retweeted_status.user.name;
        configCell.repoTextView.text = status.retweeted_status.text;

        configCell.repoImage.imageURL = status.retweeted_status.pic_urls[0];
        dispatch_async(dispatch_queue_create(0, 0), ^{
            UIImage *cellImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:status.retweeted_status.pic_urls[0]]]];
            if (cellImage) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    configCell.repoImage.imageView.image = cellImage;
                });
            }
        });

    }
    
    __unsafe_unretained typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage *image = [weakSelf getImageWithURL:status.user.profile_image_url];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!indexPath && image) {
                return ;
            }
            if (configCell.tag == indexPath.row) {
                configCell.iconView.image = image;
            }
        });
    });

}

- (NSString *)dateTimeWithCreat_dt:(NSString *)created_dt
{
    NSDateFormatter* formater = [[NSDateFormatter alloc] init];
    [formater setDateFormat:@"EEE MMM dd HH:mm:ss Z yyyy"];
    NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [formater setLocale:usLocale];
    
    NSDate* createdDate = [formater dateFromString:created_dt];
    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate:createdDate];
    
    if (timeInterval < SYBMINTUESECONDS) {
        
        long second = timeInterval;
        NSNumber *number = [NSNumber numberWithLong:second];
        NSString *creat_dt = [number stringValue];
        
        return [creat_dt stringByAppendingString:@"秒前"];
    } else if(timeInterval < SYBHOURSECONDS) {
        
        long minute = timeInterval/SYBMINTUESECONDS;
        NSNumber *number = [NSNumber numberWithLong:minute];
        NSString *creat_dt = [number stringValue];
        return [creat_dt stringByAppendingString:@"分前"];
    } else if(timeInterval < SYBDAYSECONDS/24*3) {
    //only show 3 hours ago
        long hour = timeInterval/SYBDAYSECONDS*24;
        NSNumber *number = [NSNumber numberWithLong:hour];
        NSString *creat_dt = [number stringValue];
        return [creat_dt stringByAppendingString:@"小时前"];
    }

    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    [outputFormatter setDateFormat:@"yy-dd HH:mm"];
    [outputFormatter setLocale:[NSLocale currentLocale]];
    NSString *creat_dt = [outputFormatter stringFromDate:createdDate];
    
    return creat_dt;
 }

- (NSArray *)weiboCellsFromWeibos:(NSArray *)weibos
{
    NSMutableArray *cells = [[NSMutableArray alloc] init];
    for (SYBWeiBo *weibo in weibos) {
        SYBWeiboCell *weiboCell = [[SYBWeiboCell alloc] init];
        weiboCell.weibo = weibo;
        [cells addObject:weiboCell];
    }
    return cells;
}

- (void)getWeibo{

    [[SYBWeiboAPIClient sharedClient] getAllFriendsWeibo:0 max_id:0 count:0 base_app:0 feature:0 trim_user:0
success:^(NSArray *result) {
    _items = [self weiboCellsFromWeibos:result];
    [_listTableView reloadData];
    
} failure:^(PBXError errorCode) {
    //TODO:错误处理
    NSLog(@"login failed. error code:%lu", errorCode);
}];            
}

- (void)handlePan:(UIPanGestureRecognizer *)recognizer
{
    CGPoint orignCenterPoint = _parentController.view.center;
    float x = orignCenterPoint.x;
    
    CGPoint transformPoint = [recognizer translationInView:_parentController.view];
    x += transformPoint.x;
    
    if(x > MAX_VIEW_SLID_POINT_X) {
        x = MAX_VIEW_SLID_POINT_X;
    }

    [_parentController.view setCenter:CGPointMake(x, orignCenterPoint.y)];
    
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        [UIView animateWithDuration:0.75
                              delay:0.01
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^(void)
         {
             if (x > DIVIDWIDTH ) {
                 _parentController.view.center = CGPointMake(MAX_VIEW_SLID_POINT_X, orignCenterPoint.y);
             } else {
                 _parentController.view.center = CGPointMake(MIN_VIEW_SLID_POINT_X,orignCenterPoint.y);
             }
         } completion:^(BOOL isFinish) {
         }];
    }
    [recognizer setTranslation:CGPointZero inView:_parentController.view];
}

- (void)handleTap:(UITapGestureRecognizer *)recognizer
{
    if ([recognizer isKindOfClass:[UINavigationBar class]]) {
         [_listTableView setContentOffset:CGPointMake(0.0, 0.0) animated:YES];
    }

        _userInfo.hidden = YES;
        _userInfo.userIcon.image = nil;
        _listTableView.scrollEnabled = YES;
}

- (void)handleCellTap:(UITapGestureRecognizer *)recognizer
{
    if (!_userInfo) {
        _userInfo = [[SYBUserInfoView alloc] init];
        _userInfo.backgroundColor = [UIColor grayColor];

    } else if (!_userInfo.hidden) {
            _userInfo.hidden = YES;
            _userInfo.userIcon.image = nil;
            _listTableView.scrollEnabled = YES;
            return;
    }

    SYBWeiboViewCell *selectedCell =nil;
    UIImageView *selectedImage =nil;
    if ([recognizer.view isKindOfClass:[UIImageView class]]) {
        selectedImage = (UIImageView *)recognizer.view;
    }
    if (!selectedImage) {
        return;
    }
    
    if ([[[selectedImage superview] superview] isKindOfClass:[SYBWeiboViewCell class]]) {
        selectedCell = (SYBWeiboViewCell *)[[selectedImage superview] superview];
    }
    if (!selectedCell) {
        return;
    }
    
    NSIndexPath *path = [_listTableView indexPathForCell:selectedCell];
    
    SYBWeiBo *selectStatus = _items[path.row];
    
    _userInfo.userIcon.image = selectedImage.image;
    _userInfo.username.text = selectStatus.user.screen_name;
    
    if (selectStatus.user.verified) {
        _userInfo.authedIfo.text = selectStatus.user.verified_reason;
    } else {
        _userInfo.authedIfo.text = nil;
    }
    
    NSString *followInfo = selectStatus.user.follow_me ? @"已关注你": @"未关注你";
    if ([@"f" isEqualToString: selectStatus.user.gender]) {
        followInfo = [@"她" stringByAppendingString:followInfo];
    } else {
        followInfo = [@"他" stringByAppendingString:followInfo];
    }
    _userInfo.followInfo.text = followInfo;
    
    [[UIApplication sharedApplication].keyWindow addSubview:_userInfo];
    _userInfo.center = [UIApplication sharedApplication].keyWindow.center;
    _userInfo.hidden = NO;
    _listTableView.scrollEnabled = NO;
}


-(BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)recognizer
{
    if ([recognizer isMemberOfClass:[UIPanGestureRecognizer class]]) {
        CGPoint transfromPoint = [(UIPanGestureRecognizer *)recognizer translationInView:_listTableView];
        if (fabsf(transfromPoint.x) > fabsf(transfromPoint.y)) {
            return YES;
        }
    }
    return NO;
}

- (UIImage *)getImageWithURL:(NSString *)imageURL
{
    UIImage *image = nil;
    if (_iconDict) {
        image = [_iconDict objectForKey:imageURL];
        
        if (image) {
            return image;
        }
    } else {
        _iconDict = [[NSMutableDictionary alloc] init];
    }
    image = [self loadImage:imageURL];

    //buffer image
    if (image) {
        [[NSUserDefaults standardUserDefaults] setObject:[NSData dataWithContentsOfURL:[NSURL URLWithString:imageURL]] forKey:imageURL];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        image = [UIImage imageWithData:[[NSUserDefaults standardUserDefaults] objectForKey:imageURL]];
        if (!image) {
            return nil;
        }
    }
    [_iconDict setObject:image forKey:imageURL];
    return image;
}

-(UIImage *)loadImage:(NSString *)imageURL
{
    UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imageURL]]];
    return image;
}

-(NSMutableAttributedString *)AttributedString:(NSString *)text withFont:(UIFont *)font withColor:(UIColor *)color
{
    NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:text];
    
    if (!color) {
      color = [UIColor colorWithHex:0x3498DB];
    }

    NSRange userRange = {NSNotFound, NSNotFound};
    NSInteger local = 0;
    NSMutableString *muText = [NSMutableString stringWithString:text];
    
    NSString *regEx = ALABEL_EXPRESSION;
    for(NSString *user in [muText componentsMatchedByRegex:regEx]) {

        if (userRange.location != NSNotFound) {
            [muText deleteCharactersInRange:NSMakeRange(0, userRange.location + userRange.length)];
        }
        
        userRange = [muText rangeOfString:user options:NSRegularExpressionSearch];
        [attString addAttribute:NSForegroundColorAttributeName value:color range:NSMakeRange(local + userRange.location, userRange.length)];
        local += userRange.length + userRange.location;
        
    }
    return attString;
}

-(NSMutableAttributedString *)AttributedString:(NSString *)text
{
    return [self AttributedString:text withFont:nil withColor:nil] ;
}

-(void) refreshNewWeibos
{
    __unsafe_unretained typeof(self) weakSelf = self;
    [[SYBWeiboAPIClient sharedClient] getAllFriendsWeibo:0 max_id:0 count:0 base_app:0 feature:0 trim_user:0
                                                 success:^(NSArray *result) {
                                                     if (!_items) {
                                                         _items = [self weiboCellsFromWeibos:result];
                                                     } else if(result) {
                                                         result = [self weiboCellsFromWeibos:result];
                                                         _items = [result arrayByAddingObjectsFromArray: _items];
                                                     }
                                                     [_listTableView reloadData];
                                                     [weakSelf doneLoadingTableViewData];
                                                 } failure:^(PBXError errorCode) {
                                                     //TODO:错误处理
                                                     NSLog(@"get weibo failed. error code:%ld", errorCode);
                                                     [weakSelf doneLoadingTableViewData];
                                                 }];
}

#pragma mark Data Source Loading / Reloading Methods
- (void)reloadTableViewDataSource
{
    loading = YES;
    [self refreshNewWeibos];
    
}

- (void)doneLoadingTableViewData
{
    loading = NO;
    [_headerView egoRefreshScrollViewDataSourceDidFinishedLoading:_listTableView];
}

#pragma mark EGORefreshTableHeaderDelegate methods

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView *)view
{
    [self reloadTableViewDataSource];

}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView *)view
{
    return loading;
}

#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
	
	[_headerView egoRefreshScrollViewDidScroll:scrollView];
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
	
	[_headerView egoRefreshScrollViewDidEndDragging:scrollView];
	
}

#pragma mark touch events
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}

- (void)scrollViewTap:(UITapGestureRecognizer *)tapGestureRecognizer
{
    self.tabBarController.tabBar.hidden = NO;
    [tapGestureRecognizer.view removeFromSuperview];
}

- (void)showFullImage:(UIGestureRecognizer *)tapGestureRecognizer
{
    UIScrollView *scrollImageView = [[UIScrollView alloc] initWithFrame:CGRectMake(10, [UIScreen mainScreen].bounds.size.height -50, 40, 40)];
    scrollImageView.backgroundColor = [UIColor blackColor];
    scrollImageView.maximumZoomScale = 2;
    scrollImageView.minimumZoomScale = 1;
    
    scrollImageView.delegate = self;
    
    UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [scrollImageView addSubview:activityView];
    activityView.center = CGPointMake(scrollImageView.frame.size.width/2, scrollImageView.frame.size.height/2);
    [activityView startAnimating];

    UITapGestureRecognizer *scrollViewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewTap:)];
    
    [scrollImageView addGestureRecognizer:scrollViewTap];
    
    UIImageView *imageview = [[UIImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    imageview.contentMode = UIViewContentModeScaleAspectFit;
    
    [scrollImageView addSubview:imageview];
    [self.view addSubview:scrollImageView];
    
    SYBWeiboImageView *tapedView = (SYBWeiboImageView *)tapGestureRecognizer.view;
    _fullImageUrl = tapedView.imageURL ;
   _fullImageUrl = [_fullImageUrl stringByReplacingOccurrencesOfString:smallImageFolder withString:largeImageFolder];
    
    __weak SYBListViewController *weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage *image = [weakSelf getImageWithURL:weakSelf.fullImageUrl];
        dispatch_async(dispatch_get_main_queue(), ^{
            [activityView stopAnimating];
            
            imageview.image = image;
            _fullImageView = imageview;
            
            scrollImageView.frame = [UIScreen mainScreen].bounds;
            weakSelf.tabBarController.tabBar.hidden = YES;
        });
    });
}

- (void)updateProgress:(NSTimer *)timer
{
    _imageView.receivedBytes = [_imageView.imageData length];
    if (_imageView.receivedBytes <=_imageView.totalBytes)
    {
            NSLog(@"%lu", (unsigned long)_imageView.receivedBytes);
        _imageProgress.progress = (float)_imageView.receivedBytes/ _imageView.totalBytes;
    } else
    {
        [_imageLoadTimer invalidate];
        _imageLoadTimer = nil;
    }
    
    NSLog(@"%f", _imageProgress.progress);
}

#pragma -- UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    if (_fullImageView) {
        return _fullImageView;
    }
    return nil;
}

#pragma --UIViewControllerTransitioningDelegate
- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source
{
    id<UIViewControllerAnimatedTransitioning> animationController;
    
    if ([presented isKindOfClass:[SYBWeiboActionViewController class]]) {
        SYBActionTransition *transition = [[SYBActionTransition alloc] init];
        transition.duration = 0.3;
        transition.presenting = YES;
        animationController = transition;
        return animationController;
    }
    
    SYBCommentTransition *transition = [[SYBCommentTransition alloc] init];
    transition.duration = 0.3;
    transition.presenting = YES;
    animationController = transition;
    
    return animationController;
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    id<UIViewControllerAnimatedTransitioning> animationController;
    
    if ([dismissed isKindOfClass:[SYBWeiboActionViewController class]]) {
        SYBActionTransition *transition = [[SYBActionTransition alloc] init];
        transition.duration = 1.0f;
        transition.presenting = NO;
        animationController = transition;
        return animationController;
    }
    
    SYBCommentTransition *transition = [[SYBCommentTransition alloc] init];
    transition.duration = 0.3;
    transition.presenting = NO;
    animationController = transition;
    
    return animationController;
}


#pragma --SYBWeiboCellActionDelegate

- (void)commentWeibo:(UITableViewCell *)cell
{
    NSIndexPath *indexPath = [_listTableView indexPathForCell:cell];
    SYBWeiboCell *weiboCell = [_items objectAtIndex:indexPath.row];
    
    SYBCommentViewController *commentViewController = [[SYBCommentViewController alloc] initWithNibName:nil bundle:nil];
    commentViewController.status = weiboCell.weibo;
    commentViewController.viewType = SYBCommentViewTypeCommnet;
    commentViewController.modalPresentationStyle = UIModalPresentationCustom;
    commentViewController.transitioningDelegate = self;
    [self presentViewController:commentViewController animated:YES completion:nil];
}


- (void)commentSubWeibo:(UITableViewCell *)cell
{
    NSIndexPath *indexPath = [_listTableView indexPathForCell:cell];
    SYBWeiboCell *weiboCell = [_items objectAtIndex:indexPath.row];
    
    SYBWeiBo *subWeibo = weiboCell.weibo.retweeted_status;
    
    if (!subWeibo) {
        return;
    }
    
    SYBCommentViewController *commentViewController = [[SYBCommentViewController alloc] initWithNibName:nil bundle:nil];
    commentViewController.status = subWeibo;
    commentViewController.viewType = SYBCommentViewTypeCommnet;
    commentViewController.modalPresentationStyle = UIModalPresentationCustom;
    commentViewController.transitioningDelegate = self;
    [self presentViewController:commentViewController animated:YES completion:nil];
}

- (void)retweetWeibo:(UITableViewCell *)cell
{
    NSIndexPath *indexPath = [_listTableView indexPathForCell:cell];
    SYBWeiboCell *weiboCell = [_items objectAtIndex:indexPath.row];
    
    SYBCommentViewController *commentViewController = [[SYBCommentViewController alloc] initWithNibName:nil bundle:nil];
    commentViewController.status = weiboCell.weibo;
    commentViewController.viewType = SYBCommentViewTypeRetweet;
    commentViewController.modalPresentationStyle = UIModalPresentationCustom;
    commentViewController.transitioningDelegate = self;
    [self presentViewController:commentViewController animated:YES completion:nil];
}

- (void)retweetSubWeibo:(UITableViewCell *)cell
{
    NSIndexPath *indexPath = [_listTableView indexPathForCell:cell];
    SYBWeiboCell *weiboCell = [_items objectAtIndex:indexPath.row];
    
    SYBWeiBo *subWeibo = weiboCell.weibo.retweeted_status;
    
    if (!subWeibo) {
        return;
    }
    
    SYBCommentViewController *commentViewController = [[SYBCommentViewController alloc] initWithNibName:nil bundle:nil];
    commentViewController.status = subWeibo;
    commentViewController.viewType = SYBCommentViewTypeRetweet;
    commentViewController.modalPresentationStyle = UIModalPresentationCustom;
    commentViewController.transitioningDelegate = self;
    [self presentViewController:commentViewController animated:YES completion:nil];
}

- (void)viewWeibo:(id)sender
{
    NSIndexPath *indexPath = [_listTableView indexPathForCell:sender];
    SYBWeiboCell *weiboCell = [_items objectAtIndex:indexPath.row];
    
    SYBWeiboActionViewController *actionViewController = [_mainStoryboard instantiateViewControllerWithIdentifier:@"SYBWeiboActionViewController"];
    actionViewController.transitioningDelegate = self;
    actionViewController.modalPresentationStyle = UIModalPresentationCustom;
    actionViewController.status = weiboCell.weibo;
    
    [self presentViewController:actionViewController animated:YES completion:^{
        
    }];
}

- (void)viewRepoWeibo:(id)sender
{
    NSIndexPath *indexPath = [_listTableView indexPathForCell:sender];
    SYBWeiboCell *weiboCell = [_items objectAtIndex:indexPath.row];
    
    SYBWeiboActionViewController *actionViewController = [_mainStoryboard instantiateViewControllerWithIdentifier:@"SYBWeiboActionViewController"];
    actionViewController.transitioningDelegate = self;
    actionViewController.modalPresentationStyle = UIModalPresentationCustom;
    actionViewController.status = weiboCell.weibo.retweeted_status;
    
    [self presentViewController:actionViewController animated:YES completion:^{
        
    }];
}

@end