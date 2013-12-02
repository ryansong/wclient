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
#import "SYBListWeiBoCellView.h"
#import "SYBMenuViewController.h"
#import "UIColor+hex.h"
#import "SYBCellRetweetView.h"


@interface SYBListViewController ()
@property (strong, nonatomic) NSArray *items;
@property (strong, nonatomic) NSMutableDictionary *iconDict;
@end

@implementation SYBListViewController


static const float MAX_VIEW_SLID_POINT_X = 400.0f;
static const float MIN_VIEW_SLID_POINT_X = 160.0f;
static const float DIVIDWIDTH = 320.0f;

static const float DEFALUTFONTSIZE = 14;

static const double SYBMINTUESECONDS = 60;
static const double SYBHOURSECONDS = 60*60;
static const double SYBDAYSECONDS = 24*60*60;

static const float CELL_CONTENT_WIDTH = 320.0f;
static const float CELL_CONTENT_MARGIN = 8.0f;

static float yHight = 0;
static float reYHight = 0;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.    
    [self getWeibo];

//    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc]
//                                                    initWithTarget:self
//                                                    action:@selector(handlePan:)];
//    panGestureRecognizer.delegate = self;
//    [_listTableView addGestureRecognizer:panGestureRecognizer];
//    
//    //add shadow
//    CALayer *layer = [_listTableView layer];
//    [layer setShadowOffset:CGSizeMake(-10, 10)];
//    [layer setShadowRadius:20];
//    [layer setShadowOpacity:1];
//    [layer setShadowColor:[UIColor blackColor].CGColor];
//    layer.masksToBounds = NO;
    
    [_listTableView reloadData];
    
}

- (void)loadView
{
    [super loadView];
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
    SYBListWeiBoCellView *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (!cell)
    {
        cell = [[SYBListWeiBoCellView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];

    }
    
    SYBWeiBo *status =[_items objectAtIndex:[indexPath row]];
    [self configCellWithStatus:status WithCell:cell];
    
    return cell;
}

-(void)configCellWithStatus:(SYBWeiBo *)status WithCell:(SYBListWeiBoCellView *)cell
{
    // set icon view
    yHight = CELL_CONTENT_MARGIN;
    
    if (!cell.iconView) {
            cell.iconView = [[UIImageView alloc] initWithFrame:CGRectMake(CELL_CONTENT_MARGIN, yHight, 50, 50)];
    }
    [cell addSubview:cell.iconView];
    
    CALayer *imageLayer = cell.iconView.layer;
    [imageLayer setMasksToBounds:YES];
    [imageLayer setCornerRadius:8.0f];
    
    __unsafe_unretained typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage *image = [weakSelf getImageWithURL:status.user.profile_image_url];
        dispatch_async(dispatch_get_main_queue(), ^{
            cell.iconView.image = image;
        });
    });
    
    //set username label
    CGSize nameSize = [status.user.name sizeWithFont:[UIFont systemFontOfSize:DEFALUTFONTSIZE] constrainedToSize:CGSizeMake(MAXFLOAT, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];

    if (!cell.username) {
        cell.username = [[UILabel alloc] init];
    }
    
    [cell.username setFrame: CGRectMake(CELL_CONTENT_MARGIN+60, yHight,ceilf(nameSize.width), ceilf(nameSize.height))];
    
    [cell.username setFont:[UIFont systemFontOfSize:DEFALUTFONTSIZE]];
    [cell.username setText:status.user.name];
    [cell addSubview:cell.username];
    
    //set create time
    NSString *creatDate = [self dateTimeWithCreat_dt:status.created_at];
    CGSize cdsize = [creatDate sizeWithFont: [UIFont systemFontOfSize:DEFALUTFONTSIZE] constrainedToSize: CGSizeMake(MAXFLOAT, MAXFLOAT)];
    
    if (!cell.creatTime) {
        cell.creatTime = [[UILabel alloc] init];
    }
    
    [cell.creatTime setFont:[UIFont systemFontOfSize:DEFALUTFONTSIZE]];
    [cell.creatTime setFrame:CGRectMake(CELL_CONTENT_MARGIN+60, yHight+25,ceilf(cdsize.width), ceilf(cdsize.height))];
    [cell.creatTime setText:creatDate];
    [cell addSubview:cell.creatTime];
    
    yHight += 50;
    
    
    NSString *poText = status.text;
    
    if (!cell.poTextLabel) {
        cell.poTextLabel = [[UILabel alloc] init];
    }
   
    CGSize poTextSize = [poText sizeWithFont:[UIFont systemFontOfSize:DEFALUTFONTSIZE] constrainedToSize:CGSizeMake(CELL_CONTENT_WIDTH - 2*CELL_CONTENT_MARGIN , MAXFLOAT) lineBreakMode:NSLineBreakByCharWrapping];
    CGRect poTextRect = {.origin.x = CELL_CONTENT_MARGIN, .origin.y = yHight + CELL_CONTENT_MARGIN, .size.width = ceilf(poTextSize.width), .size.height =  ceilf(poTextSize.height) };
    
    [cell.poTextLabel setFrame:poTextRect];
    [cell.poTextLabel setNumberOfLines:0];
    [cell.poTextLabel setFont:[UIFont systemFontOfSize:DEFALUTFONTSIZE]];
    [cell.poTextLabel setText:poText];
    [cell addSubview:cell.poTextLabel];
    
    yHight += poTextSize.height;
    yHight += CELL_CONTENT_MARGIN;

    
    // attach pic
    if (status.pic_urls) {
        if (!cell.poImage) {
            cell.poImage = [[UIImageView alloc] init];
        }
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            UIImage *image = [weakSelf getImageWithURL: [status.pic_urls objectAtIndex:0]];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self resizeView:cell.poImage size:image.size];
                cell.poImage.image = image;
            });
        });
        
        cell.poImage.frame = CGRectMake(CELL_CONTENT_MARGIN, yHight, 40, 120);
        [cell addSubview:cell.poImage];
        yHight += 120;
    } else {
        cell.poImage.hidden = YES;

    }

    reYHight = CELL_CONTENT_MARGIN;
    
    SYBWeiBo *reStatus = status.retweeted_status;
    if (reStatus) {
        if(!cell.repoArea){
            cell.repoArea = [[UIView alloc] init];
            cell.repoArea.layer.borderWidth = 0.0f;
            cell.repoArea.layer.backgroundColor = [[UIColor ColorWithHex:0xECF0F1] CGColor];
            
            [cell addSubview:cell.repoArea];
        }
        
        cell.repoArea.frame = CGRectMake(CELL_CONTENT_MARGIN, yHight, CELL_CONTENT_WIDTH - CELL_CONTENT_MARGIN * 2, 300);
        
        if (!cell.repoUsername) {
            cell.repoUsername = [[UILabel alloc] init];
            cell.repoUsername.font = [UIFont systemFontOfSize:DEFALUTFONTSIZE - 1];
            
            [cell.repoArea addSubview:cell.repoUsername];
        }
        cell.repoUsername.text = reStatus.user.name;
        [self resizeView:cell.repoUsername withText:reStatus.user.name withFont:[UIFont systemFontOfSize:DEFALUTFONTSIZE - 1]];
        
        [self setOriginPointAboutView:cell.repoUsername newPoint:CGPointMake(CELL_CONTENT_MARGIN, CELL_CONTENT_MARGIN)];
        reYHight += cell.repoUsername.frame.size.height;
        
        if (!cell.repoText) {
            cell.repoText = [[UILabel alloc] init];
            cell.repoText.numberOfLines = 0;
            cell.repoText.font = [UIFont systemFontOfSize:DEFALUTFONTSIZE - 1];
            
            [cell.repoArea addSubview:cell.repoText];
        }
        cell.repoText.text = reStatus.text;
        [self resizeView:cell.repoText withFont:[UIFont systemFontOfSize:DEFALUTFONTSIZE - 1]];
        [self setOriginPointAboutView:cell.repoText newPoint:CGPointMake(CELL_CONTENT_MARGIN, reYHight+CELL_CONTENT_MARGIN)];
        reYHight += cell.repoText.frame.size.height;
        
        if (reStatus.pic_urls) {
            if (!cell.repoImage) {
                cell.repoImage = [[UIImageView alloc] init];
                [cell.repoArea addSubview:cell.repoImage];
            }
             [self setOriginPointAboutView:cell.repoImage newPoint:CGPointMake(CELL_CONTENT_MARGIN, reYHight+CELL_CONTENT_MARGIN)];
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                UIImage *image = [weakSelf getImageWithURL:[reStatus.pic_urls objectAtIndex:0]];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self resizeView:cell.repoImage ceilfSize:image.size];
                    cell.repoImage.image = image;
                });
            });
            }
        
    }
    
}

- (void)setOriginPointAboutView:(UIView *)view newPoint:(CGPoint) originPoint
{
    [self resizeFrameView:view originX:originPoint.x originY:originPoint.y sizeWidth:view.frame.size.width sizeHeight:view.frame.size.height];
}

- (void)resizeFrameView:(UIView *)aView originX:(CGFloat)x originY:(CGFloat)y sizeWidth:(CGFloat)width sizeHeight:(CGFloat)height
{
    aView.frame = CGRectMake(x, y, width, height);
}


- (void)resizeView:(UIView *)aView size:(CGSize)size
{
    aView.frame = CGRectMake(aView.frame.origin.x, aView.frame.origin.y, size.width, size.height);
}

- (void)resizeView:(UILabel *)theLabel withFont:(UIFont *)font
{
    if(!font){
        font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
    }
    CGSize  constrainedSize = CGSizeMake(CELL_CONTENT_WIDTH - CELL_CONTENT_MARGIN * 3, MAXFLOAT);
    
    CGSize newSize = [theLabel.text sizeWithFont:font constrainedToSize:constrainedSize lineBreakMode:NSLineBreakByCharWrapping];
    
    [self resizeView:theLabel ceilfSize:newSize];
}


- (void)resizeView:(UIView *)view withText:(NSString *)text withFont:(UIFont *)font
{
    if(!font){
        font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
    }
    CGSize  constrainedSize = CGSizeMake(CELL_CONTENT_WIDTH - CELL_CONTENT_MARGIN * 3, MAXFLOAT);
        
    CGSize newSize = [text sizeWithFont:font constrainedToSize:constrainedSize lineBreakMode:NSLineBreakByCharWrapping];
    
    [self resizeView:view ceilfSize:newSize];
    
}

- (void)resizeView:(UIView *)view withSize:(CGSize)size
{
    view.frame = CGRectMake(view.frame.origin.x, view.frame.origin.y, size.width, size.height);
}
- (void) resizeView:(UIView *)view ceilfSize:(CGSize)size
{
    view.frame = CGRectMake(view.frame.origin.x, view.frame.origin.y, ceilf(size.width), ceilf(size.height));
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

- (void)getWeibo{

    [[SYBWeiboAPIClient sharedClient] getAllFriendsWeibo:0 max_id:0 count:0 base_app:0 feature:0 trim_user:0
success:^(NSArray *result) {
    _items = result;
    [_listTableView reloadData];
} failure:^(PBXError errorCode) {
    //TODO:错误处理
    NSLog(@"login failed. error code:%d", errorCode);
}];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SYBWeiBo *status = [_items objectAtIndex:indexPath.row];
    
    //高度设置
    CGFloat yHeight = 70.0;
    
    //微博的内容的高度
    CGSize constraint = CGSizeMake(CELL_CONTENT_WIDTH - (CELL_CONTENT_MARGIN * 2), MAXFLOAT);
    CGSize sizeOne = [status.text sizeWithFont:[UIFont systemFontOfSize:DEFALUTFONTSIZE] constrainedToSize:constraint lineBreakMode:NSLineBreakByWordWrapping];
    
    yHeight += (sizeOne.height + CELL_CONTENT_MARGIN);
    
    //转发情况
    SYBWeiBo  *retwitterStatus = status.retweeted_status;
    
    //有转发
    if (retwitterStatus && ![retwitterStatus isEqual:[NSNull null]])
    {
        
        //转发内容的文本内容
        NSString *retwitterContentText = [NSString stringWithFormat:@"%@:%@",retwitterStatus.user.screen_name,retwitterStatus.text];
        CGSize textSize = CGSizeMake(CELL_CONTENT_WIDTH - (CELL_CONTENT_MARGIN * 2), MAXFLOAT);
        CGSize sizeTwo = [retwitterContentText sizeWithFont:[UIFont systemFontOfSize:DEFALUTFONTSIZE] constrainedToSize:textSize lineBreakMode:NSLineBreakByWordWrapping];
        
        yHeight += (sizeTwo.height + CELL_CONTENT_MARGIN);
        
        //那么图像就在转发部分进行显示
        if (status.retweeted_status.pic_urls) //转发的微博有图像
        {
            yHeight += (120 + CELL_CONTENT_MARGIN);
        }
    }
    //无转发
    else
    {
        //微博有图像
        if (status.pic_urls) {
            
            yHeight += (120+ CELL_CONTENT_MARGIN);
        }
    }
    yHeight += 20;
    return yHeight;
}

- (void)handlePan:(UIPanGestureRecognizer *)recognizer
{
    CGPoint orignCenterPoint = _listTableView.center;
    float x = orignCenterPoint.x;
    
    CGPoint transformPoint = [recognizer translationInView:_listTableView];
    x = orignCenterPoint.x +transformPoint.x;
    
    if(x > MAX_VIEW_SLID_POINT_X) {
        x = MAX_VIEW_SLID_POINT_X;
    }

    [_listTableView setCenter:CGPointMake(x, orignCenterPoint.y)];
    
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        [UIView animateWithDuration:0.75
                              delay:0.01
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^(void)
         {
             if (x > DIVIDWIDTH ) {
                 _listTableView.center = CGPointMake(MAX_VIEW_SLID_POINT_X, orignCenterPoint.y);
             } else {
                 _listTableView.center = CGPointMake(MIN_VIEW_SLID_POINT_X,orignCenterPoint.y);
             }
         } completion:^(BOOL isFinish) {
         }];
    }
    [recognizer setTranslation:CGPointZero inView:self.view];
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
    [_iconDict setObject:image forKey:imageURL];
    return image;
}

-(UIImage *)loadImage:(NSString *)imageURL
{
    UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imageURL]]];
    return image;
}
@end