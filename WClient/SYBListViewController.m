//
//  SYBListViewController.m
//  WClient
//
//  Created by Song Xiaoming on 13-10-27.
//  Copyright (c) 2013年 Song Xiaoming. All rights reserved.
//

#import "SYBListViewController.h"
#import "SYBWeiboAPIClient.h"
#import "SYBWeiBo.h"
#import "SYBWeiboCellView.h"
#import "SYBMenuViewController.h"
#import "SYBCellRetweetView.h"
#import "RegexKitLite.h"
#import "SYBUserInfoView.h"

#import "UIColor+hex.h"

#import <SSKeychain.h>

#define ALABEL_EXPRESSION @"@[\u4e00-\u9fa5a-zA-Z0-9_-]{4,30}"
#define HREF_PROPERTY_IN_ALABEL_EXPRESSION @"(href\\s*=\\s*(?:\"([^\"]*)\"|\'([^\']*)\'|([^\"\'>\\s]+)))"
#define URL_EXPRESSION @"([hH][tT][tT][pP][sS]?:\\/\\/[^ ,'\">\\]\\)]*[^\\. ,'\">\\]\\)])"
#define AT_IN_WEIBO_EXPRESSION @"(@[\u4e00-\u9fa5a-zA-Z0-9_-]{4,30})"
#define TOPIC_IN_WEIBO_EXPRESSION @"(#[^#]+#)"

@interface SYBListViewController ()
@property (nonatomic, strong) NSArray *items;
@property (nonatomic, strong) NSMutableDictionary *iconDict;
@property (nonatomic, strong) NSString *client_id;
@property (nonatomic, strong) NSString *client_secret;

@property (nonatomic, strong) SYBUserInfoView *userInfo;

@property (nonatomic, strong) SYBWeiboCellView *prototype;
@property (nonatomic, strong) SYBWeiboImageView *imageView;

@property (nonatomic, strong) UIImageView *fullImageView;
@property (nonatomic, strong) NSTimer *imageLoadTimer;
@property (nonatomic, strong) UIProgressView *imageProgress;
@property (nonatomic, strong) UIViewController *parentController;
@end

@implementation SYBListViewController
{
    BOOL loading;
}

static const float MAX_VIEW_SLID_POINT_X = 400.0f;
static const float MIN_VIEW_SLID_POINT_X = 160.0f;
static const float DIVIDWIDTH = 320.0f;

static const float DEFALUTFONTSIZE = 14;

static const double SYBMINTUESECONDS = 60;
static const double SYBHOURSECONDS = 60*60;
static const double SYBDAYSECONDS = 24*60*60;

static const float CELL_CONTENT_WIDTH = 320.0f;
static const float CELL_CONTENT_MARGIN = 6.0f;

static const float STANDARD_AQUA_SPACE = 20;

static const float REPO_WIDTH = 302.0f;
static const float TEXTROWHEIGHT = 17.0f;
static const float REPO_TEXTROWHEIGHT = 16.0f;

static const float IMAGE_HEIGHT = 120.0f;
static const float IMAGE_WIDTH = 120.0f;

static const float IMAGE_BORDAE_WIDTH = 10.0f;


static float yHeight = 0;
static float reYHight = 0;

static UIImage *defalutUserIcon;
static UIImage *noImage;
static UIImage *defaultImage;

static const NSString *smallImageFolder = @"thumbnail";
static const NSString *middleImageFolder = @"bmiddle";
static const NSString *largeImageFolder = @"mw1024";

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
	// Do any additional setup after loading the view.    
    [self getWeibo];

    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc]
                                                    initWithTarget:self
                                                            action:@selector(handlePan:)];
    panGestureRecognizer.delegate = self;
    
    _parentController = self.parentViewController;
    [_parentController.view addGestureRecognizer:panGestureRecognizer];
    
    UITapGestureRecognizer *tapNavigationBarRecognizer = [[UITapGestureRecognizer alloc]
                                                    initWithTarget:self
                                                    action:@selector(handleTap:)];
    [_navigationBar addGestureRecognizer:tapNavigationBarRecognizer];
    
    UITapGestureRecognizer *tapListViewRecognizer = [[UITapGestureRecognizer alloc]
                                                    initWithTarget:self
                                                    action:@selector(handleTap:)];
    
    [_listTableView addGestureRecognizer:tapListViewRecognizer];
    _listTableView.userInteractionEnabled = YES;
    
    //add shadow
    CALayer *layer = [_listTableView layer];
    [layer setShadowOffset:CGSizeMake(-10, 10)];
    [layer setShadowRadius:20];
    [layer setShadowOpacity:1];
    [layer setShadowColor:[UIColor blackColor].CGColor];
    layer.masksToBounds = NO;
    
    [_listTableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    
    [_listTableView setSeparatorColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"Divider_line@2x.png"]]];
    
#pragma add headerView
    if (_headerView == nil) {
		
		EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - _listTableView.bounds.size.height, _listTableView.frame.size.width, _listTableView.bounds.size.height)];
		view.delegate = self;
		[_listTableView addSubview:view];
		_headerView = view;
	}
	
	//  update the last update date
//	[_headerView refreshLastUpdatedDate];
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (!_items) {
        return 0;
    }
    return _items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"weiboCell";
    SYBWeiboCellView *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (!cell)
    {
        cell = [[SYBWeiboCellView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.tag = indexPath.row;
    
    SYBWeiboCell *status =[_items objectAtIndex:[indexPath row]];
    [self configCellWithStatus:status WithCell:cell cellForRowAtIndexPath:indexPath isForOffscreenUse:NO];
    
    return cell;
}

- (void)caculateHeigtForCell:(SYBWeiboCell *)weiboCell
{
    CGSize poTextSize =[self getSizeOfString:weiboCell.weibo.text withFont:[UIFont systemFontOfSize:DEFALUTFONTSIZE] withWidth:(CELL_CONTENT_WIDTH - CELL_CONTENT_MARGIN * 2)];
    weiboCell.poHeight = poTextSize.height;
    if (weiboCell.weibo.retweeted_status) {
        CGSize repoTextHeight =[self getSizeOfString:weiboCell.weibo.retweeted_status.text withFont:[UIFont systemFontOfSize:DEFALUTFONTSIZE - 1] withWidth:(CELL_CONTENT_WIDTH - CELL_CONTENT_MARGIN * 4)];
        weiboCell.repoHeight = repoTextHeight.height;

    }

    weiboCell.cellHeight = weiboCell.poHeight + 120;
    //with po image
    if ([weiboCell.weibo hasPic]) {
        weiboCell.cellHeight += 120;
        return;
    }
    
    if (![weiboCell.weibo hasRepo]) {
        return;
    }
    
    weiboCell.cellHeight += weiboCell.repoHeight + 40;
    if (![weiboCell.weibo.retweeted_status hasPic]) {
        return;
    }
    weiboCell.cellHeight += 120 ;
   
}

- (void)configCellWithStatus:(SYBWeiboCell *)weiboCell WithCell:(SYBWeiboCellView *)cell cellForRowAtIndexPath:(NSIndexPath *)indexPath isForOffscreenUse:(BOOL)offScreen
{
    SYBWeiBo *status = weiboCell.weibo;
    CGFloat repoHeight = 0;
    CGFloat repoAreaHeight = 0;
    // set icon view
    yHeight = CELL_CONTENT_MARGIN;
    
    if (!cell.iconView) {
            cell.iconView = [[UIImageView alloc] initWithFrame:CGRectMake(CELL_CONTENT_MARGIN, CELL_CONTENT_MARGIN, 50, 50)];
            UITapGestureRecognizer *tapGestureForCell = [[UITapGestureRecognizer alloc]
                              initWithTarget:self
                              action:@selector(handleCellTap:)];

            [cell.iconView addGestureRecognizer:tapGestureForCell];
    }

    [cell.iconView setUserInteractionEnabled:YES];
    
    [cell addSubview:cell.iconView];
    cell.iconView.image = defalutUserIcon;
    
    CALayer *imageLayer = cell.iconView.layer;
    [imageLayer setMasksToBounds:YES];
    [imageLayer setCornerRadius:10.0f];

    __unsafe_unretained typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage *image = [weakSelf getImageWithURL:status.user.profile_image_url];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!indexPath && image) {
                return ;
            }
            if (cell.tag == indexPath.row) {
                cell.iconView.image = image;
            }

        });
    });

    if (!cell.username) {
        cell.username = [[UILabel alloc] initWithFrame:CGRectMake(CELL_CONTENT_MARGIN+60, CELL_CONTENT_MARGIN, 160, 21)];
    }
    
    cell.username.font = [UIFont boldSystemFontOfSize:DEFALUTFONTSIZE];
    [cell.username setText:status.user.screen_name];
    [cell addSubview:cell.username];
    
    //set create time
    NSString *creatDate = [self dateTimeWithCreat_dt:status.created_at];
    CGSize cdsize = CGSizeMake(120, 21);
    
    if (!cell.creatTime) {
        cell.creatTime = [[UILabel alloc] init];
    }
    [cell.creatTime setFont:[UIFont systemFontOfSize:DEFALUTFONTSIZE - 2]];
    
    [cell.creatTime setFrame:CGRectMake(CELL_CONTENT_MARGIN + 60, yHeight + 50 - ceilf(cdsize.height),ceilf(cdsize.width), ceilf(cdsize.height))];
    [cell.creatTime setText:creatDate];
    [cell addSubview:cell.creatTime];
    
    yHeight += 50 + CELL_CONTENT_MARGIN * 2;
    
    NSString *poText = status.text;
    CGRect poRect = CGRectMake(CELL_CONTENT_MARGIN, yHeight + CELL_CONTENT_MARGIN, CELL_CONTENT_WIDTH - CELL_CONTENT_MARGIN * 2, weiboCell.poHeight);
    
    if (!cell.poTextLabel) {
        cell.poTextLabel = [[UILabel alloc] initWithFrame:poRect];
        [cell.poTextLabel setNumberOfLines:0];
        [cell.poTextLabel setFont:[UIFont systemFontOfSize:DEFALUTFONTSIZE]];
        [cell addSubview:cell.poTextLabel];
    } else {
        cell.poTextLabel.frame = poRect;
    }
    
    if (!status.attributedText) {
        status.attributedText = [self AttributedString:poText];
    }
    
    cell.poTextLabel.attributedText = status.attributedText;

    yHeight += CGRectGetHeight(cell.poTextLabel.frame);
    yHeight += CELL_CONTENT_MARGIN * 2;
    
    // attach pic
    if (status.hasPic) {
        yHeight += CELL_CONTENT_MARGIN;
        if (!cell.poImage) {
            cell.poImage = [[SYBWeiboImageView alloc] initWithFrame:CGRectMake(CELL_CONTENT_MARGIN, yHeight, IMAGE_WIDTH + IMAGE_BORDAE_WIDTH, IMAGE_HEIGHT + IMAGE_BORDAE_WIDTH)];

            UITapGestureRecognizer *tapImage = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showFullImage:)];
            
            [cell.poImage addGestureRecognizer:tapImage];
        }
        
        cell.poImage.imageURL = [status.pic_urls objectAtIndex:0];
        
        cell.poImage.userInteractionEnabled = YES;
#warning todo multiple images
        cell.poImage.frame = CGRectMake(CELL_CONTENT_MARGIN, yHeight , IMAGE_WIDTH + IMAGE_BORDAE_WIDTH, IMAGE_HEIGHT + IMAGE_BORDAE_WIDTH);
        cell.poImage.imageView.image = noImage;
        
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            UIImage *image = [weakSelf getImageWithURL: [status.pic_urls objectAtIndex:0]];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (cell.tag == indexPath.row) {
                    [weakSelf loadImage:image forView:cell.poImage];
                }
            });
        });
        [cell addSubview:cell.poImage];
        
        yHeight += CGRectGetHeight(cell.poImage.frame);
        cell.poImage.hidden = NO;
    } else {
        cell.poImage.hidden = YES;
    }
    
    reYHight = CELL_CONTENT_MARGIN;
    SYBWeiBo *reStatus = status.retweeted_status;
    if (reStatus) {
        if(!cell.repoArea){
            cell.repoArea = [[UIView alloc] init];
            [cell addSubview:cell.repoArea];
        }
        
        if (!cell.repoBar) {
            cell.repoBar = [[UIView alloc] init];
            cell.repoBar.backgroundColor = [UIColor colorWithHex:0xECF0F1 alpha:1.0];
            
            [cell addSubview:cell.repoBar];
        }
        
        if (!cell.repoUsername) {
            cell.repoUsername = [[UILabel alloc] initWithFrame:CGRectMake(CELL_CONTENT_MARGIN, CELL_CONTENT_MARGIN, 200, 16)];
            cell.repoUsername.font = [UIFont boldSystemFontOfSize:DEFALUTFONTSIZE - 1];
            cell.repoUsername.textColor = [UIColor colorWithHex:0x3498DB];
            [cell.repoArea addSubview:cell.repoUsername];
        }
        cell.repoUsername.text = [NSString stringWithFormat:@"@%@", reStatus.user.screen_name];

        reYHight += cell.repoUsername.frame.size.height;
        reYHight += CELL_CONTENT_MARGIN;
        
        CGRect repoTextRect = CGRectMake(CELL_CONTENT_MARGIN, reYHight, CELL_CONTENT_WIDTH - 4 * CELL_CONTENT_MARGIN, weiboCell.repoHeight);

        if (!cell.repoText) {
            cell.repoText = [[UILabel alloc] initWithFrame:repoTextRect];
            cell.repoText.numberOfLines = 0;
            cell.repoText.font = [UIFont systemFontOfSize:DEFALUTFONTSIZE - 1];
            [cell.repoArea addSubview:cell.repoText];
        } else {
            cell.repoText.frame = repoTextRect;
        }
        if (!reStatus.attributedText) {
            reStatus.attributedText = [self AttributedString:reStatus.text];
        }
        cell.repoText.attributedText = reStatus.attributedText;
        
        CGSize repoTextSize = [self getSizeOfString:reStatus.text withFont:[UIFont systemFontOfSize:DEFALUTFONTSIZE - 1] withWidth:(CELL_CONTENT_WIDTH - 4 * CELL_CONTENT_MARGIN)];
        [self setView:cell.repoText withSize:repoTextSize];
        
        reYHight += cell.repoText.frame.size.height;
        reYHight += CELL_CONTENT_MARGIN * 2;
        repoHeight = reYHight;
        if (reStatus.hasPic == YES) {
            if (!cell.repoImage) {
                cell.repoImage = [[SYBWeiboImageView alloc] initWithFrame:CGRectMake(CELL_CONTENT_MARGIN,
                                                                                     repoHeight,
                                                                                     IMAGE_WIDTH + IMAGE_BORDAE_WIDTH,
                                                                                     IMAGE_HEIGHT + IMAGE_BORDAE_WIDTH
                                                                                     )];
                cell.repoImage.userInteractionEnabled = YES;
                UITapGestureRecognizer *tapImage = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showFullImage:)];
                [cell.repoImage addGestureRecognizer:tapImage];

            }
            cell.repoImage.imageURL = [reStatus.pic_urls objectAtIndex:0];
            
            cell.repoImage.frame = CGRectMake(CELL_CONTENT_MARGIN,
                                              repoHeight,
                                              IMAGE_WIDTH + IMAGE_BORDAE_WIDTH,
                                              IMAGE_HEIGHT + IMAGE_BORDAE_WIDTH
                                              );
            
            cell.repoImage.imageView.image = noImage;
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                UIImage *image = [weakSelf getImageWithURL:[reStatus.pic_urls objectAtIndex:0]];
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (cell.tag == indexPath.row) {
                        [weakSelf loadImage:image forView:cell.repoImage];
                    }
                });
            });
            
            [cell.repoArea addSubview:cell.repoImage];
            cell.repoImage.hidden = NO;
            repoAreaHeight += CGRectGetHeight(cell.repoImage.frame);
        } else {
            cell.repoImage.hidden = YES;
        }
        repoAreaHeight += repoHeight;
        cell.repoArea.hidden = NO;
        cell.repoBar.hidden = NO;
    } else {
        cell.repoArea.hidden = YES;
        cell.repoBar.hidden = YES;
    }
    
    cell.repoArea.frame = CGRectMake(CELL_CONTENT_MARGIN * 2, yHeight, REPO_WIDTH, repoAreaHeight);
    cell.repoBar.frame = CGRectMake(CELL_CONTENT_MARGIN, yHeight, CELL_CONTENT_MARGIN, repoAreaHeight);
    
    yHeight += cell.repoArea.frame.size.height;
    yHeight += CELL_CONTENT_MARGIN;
    
    if (!cell.creatin) {
        cell.creatin = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 280, 14)];
        [cell addSubview:cell.creatin];
        cell.creatin.textAlignment = NSTextAlignmentRight;
        cell.creatin.font = [UIFont systemFontOfSize:11];
    }
    
    CGRect sourceFrame = cell.creatin.frame;
    sourceFrame.origin.y = yHeight;
    cell.creatin.frame = sourceFrame;
    cell.creatin.text = [NSString stringWithFormat:@"%@ %@", @"来自",status.source];
    

    CGRect cellFrame = cell.frame;
    cellFrame.size.height = yHeight + 14 +CELL_CONTENT_MARGIN;
    
    cell.frame = cellFrame;
}

-(void)setImageView:(UIImageView *)imageView withSize:(CGSize)size
{
    [self setView:imageView withSize:size];
}
-(void)setView:(UIView *)view withWidth:(CGFloat)width withHeight:(CGFloat)height
{
    [self setView:view withSize:CGSizeMake(width, height)];
}

-(CGSize)celifSize:(CGSize)size
{
    size.height = ceilf(size.height);
    size.width = ceilf(size.width);
    return size;
}

-(void)setView:(UIView *)view withSize:(CGSize)size
{
    size = [self celifSize:size];
    view.frame = CGRectMake(view.frame.origin.x, view.frame.origin.y, size.width, size.height);
}

-(NSString *)dateTimeWithCreat_dt:(NSString *)created_dt
{
    NSDateFormatter* formater = [[NSDateFormatter alloc] init];
    [formater setDateFormat:@"EEE MMM dd HH:mm:ss Z yyyy"];
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
    NSLog(@"login failed. error code:%d", errorCode);
}];            
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SYBWeiboCell *weiboCell = [_items objectAtIndex:indexPath.row];
    if (weiboCell.cellHeight != 0) {
        return weiboCell.cellHeight;
    }
    [self caculateHeigtForCell:weiboCell];

    return weiboCell.cellHeight;
}

- (CGSize)getSizeOfString:(NSString *)aString withFont:(UIFont *)font withWidth:(CGFloat)theWidth
{
   return  [aString sizeWithFont:font constrainedToSize:CGSizeMake(theWidth, MAXFLOAT) lineBreakMode:NSLineBreakByCharWrapping];
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

    SYBWeiboCellView *selectedCell =nil;
    UIImageView *selectedImage =nil;
    if ([recognizer.view isKindOfClass:[UIImageView class]]) {
        selectedImage = (UIImageView *)recognizer.view;
    }
    if (!selectedImage) {
        return;
    }
    
    if ([[[selectedImage superview] superview] isKindOfClass:[SYBWeiboCellView class]]) {
        selectedCell = (SYBWeiboCellView *)[[selectedImage superview] superview];
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
                                                     NSLog(@"get weibo failed. error code:%d", errorCode);
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

- (void)loadImage:(UIImage *)img forView:(SYBWeiboImageView *)view
{
    if (!img) {
        return;
    }
    
    CGSize imagSize = img.size;
    CGFloat rateWH = imagSize.width/imagSize.height;
   
    if (rateWH == 1) {
        return;
    }

    CGRect viewframe = view.frame;
    CGRect imageViewframe = view.imageView.frame;
    
    if (rateWH < 1) {
        CGFloat width = 120 * rateWH;
        viewframe.size.width = width + IMAGE_BORDAE_WIDTH;
        imageViewframe.size.width = width;
        
    } else {
        CGFloat width = 120 * rateWH;
        viewframe.size.width = width + IMAGE_BORDAE_WIDTH;
        imageViewframe.size.width = width;
    }
    
    view.frame = viewframe;
    view.imageView.frame = imageViewframe;
    view.imageView.image = img;
}

- (void)showFullImage:(UIGestureRecognizer *)send
{
    _imageView = nil;
    if ([send.view isKindOfClass:[SYBWeiboImageView class]]) {
        _imageView = (SYBWeiboImageView *)send.view;
    }

    if (!_imageView) {
        return;
    }

    [_imageView loadMiddleImageWithProgress];
    
    CGRect screenRect = [[UIScreen mainScreen] applicationFrame];
    if (!_fullImageView) {
        _fullImageView = [[UIImageView alloc] initWithFrame:screenRect];
        _fullImageView.userInteractionEnabled = YES;
    }
    _fullImageView.image = _imageView.imageView.image;

    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
         _imageLoadTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateProgress:) userInfo:nil repeats:YES];
    });
    
     _imageProgress = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    
    [_fullImageView addSubview:_imageProgress];
    
    [[UIApplication sharedApplication].keyWindow addSubview:_fullImageView];
}

- (void)updateProgress:(NSTimer *)timer
{
    _imageView.receivedBytes = [_imageView.imageData length];
    if (_imageView.receivedBytes <=_imageView.totalBytes)
    {
            NSLog(@"%d", _imageView.receivedBytes);
        _imageProgress.progress = (float)_imageView.receivedBytes/ _imageView.totalBytes;
    } else
    {
        [_imageLoadTimer invalidate];
        _imageLoadTimer = nil;
    }
    
    NSLog(@"%f", _imageProgress.progress);
}

- (IBAction)signOut:(id)sender {
        NSString *uid = [[NSUserDefaults standardUserDefaults]objectForKey:@"uid"];
        [SSKeychain deletePasswordForService:@"WClient" account:uid];
}
@end