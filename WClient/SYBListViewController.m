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
#import "UIColor+hex.h"
#import "SYBCellRetweetView.h"
#import "RegexKitLite.h"

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
@end

@implementation SYBListViewController
{
    CGFloat rowHeight;
    CGFloat repoHeight;
    
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

static const float REPO_WIDTH = 302.0f;
static const float TEXTROWHEIGHT = 17.0f;
static const float REPO_TEXTROWHEIGHT = 16.0f;


static float yHeight = 0;
static float reYHight = 0;

static UIImage *defalutUserIcon;
static UIImage *defalutImage;

+(void)initialize
{
    [super initialize];
    
    NSString *iconPath = [[NSBundle mainBundle] pathForResource:@"UserIcon" ofType:@"png"];
    defalutUserIcon = [UIImage imageWithContentsOfFile:iconPath];
    
    NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"noImage" ofType:@"png"];
    defalutImage = [UIImage imageWithContentsOfFile:imagePath];

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
    [_listTableView addGestureRecognizer:panGestureRecognizer];
    
    UITapGestureRecognizer *tapGesturerecognizer = [[UITapGestureRecognizer alloc]
                                                    initWithTarget:self
                                                            action:@selector(handleTap:)];
    [_navigationBar addGestureRecognizer:tapGesturerecognizer];
    
    //add shadow
    CALayer *layer = [_listTableView layer];
    [layer setShadowOffset:CGSizeMake(-10, 10)];
    [layer setShadowRadius:20];
    [layer setShadowOpacity:1];
    [layer setShadowColor:[UIColor blackColor].CGColor];
    layer.masksToBounds = NO;
    
    
#pragma add headerView
    if (_headerView == nil) {
		
		EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - _listTableView.bounds.size.height, _listTableView.frame.size.width, _listTableView.bounds.size.height)];
		view.delegate = self;
		[_listTableView addSubview:view];
		_headerView = view;

		
	}
	
	//  update the last update date
	[_headerView refreshLastUpdatedDate];
    
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
    SYBWeiboCellView *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (!cell)
    {
        cell = [[SYBWeiboCellView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.tag = indexPath.row;
    
    SYBWeiBo *status =[_items objectAtIndex:[indexPath row]];
    [self configCellWithStatus:status WithCell:cell cellForRowAtIndexPath:indexPath];
    
    return cell;
}

-(void)configCellWithStatus:(SYBWeiBo *)status WithCell:(SYBWeiboCellView *)cell
{
    [self configCellWithStatus:status WithCell:cell cellForRowAtIndexPath:nil];
}

-(void)configCellWithStatus:(SYBWeiBo *)status WithCell:(SYBWeiboCellView *)cell cellForRowAtIndexPath:(NSIndexPath *)indexPath

{
    // set icon view
    yHeight = CELL_CONTENT_MARGIN;
    
    if (!cell.iconView) {
            cell.iconView = [[UIImageView alloc] initWithFrame:CGRectMake(CELL_CONTENT_MARGIN, yHeight, 50, 50)];
    }
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
                [cell setNeedsLayout];
            }

        });
    });
    
    //set username label
    CGSize nameSize = [status.user.screen_name sizeWithFont:[UIFont boldSystemFontOfSize:DEFALUTFONTSIZE] constrainedToSize:CGSizeMake(MAXFLOAT, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];

    if (!cell.username) {
        cell.username = [[UILabel alloc] init];
    }
    
    [cell.username setFrame: CGRectMake(CELL_CONTENT_MARGIN+60, yHeight,ceilf(nameSize.width), ceilf(nameSize.height))];
    
    cell.username.font = [UIFont boldSystemFontOfSize:DEFALUTFONTSIZE];
    [cell.username setText:status.user.screen_name];
    [cell addSubview:cell.username];
    
    //set create time
    NSString *creatDate = [self dateTimeWithCreat_dt:status.created_at];
    CGSize cdsize = [creatDate sizeWithFont: [UIFont systemFontOfSize:DEFALUTFONTSIZE - 2] constrainedToSize: CGSizeMake(MAXFLOAT, TEXTROWHEIGHT)];
    
    if (!cell.creatTime) {
        cell.creatTime = [[UILabel alloc] init];
    }
    [cell.creatTime setFont:[UIFont systemFontOfSize:DEFALUTFONTSIZE - 2]];
    [cell.creatTime setFrame:CGRectMake(CELL_CONTENT_MARGIN + 60, yHeight + 50 - ceilf(cdsize.height),ceilf(cdsize.width), ceilf(cdsize.height))];
    [cell.creatTime setText:creatDate];
    [cell addSubview:cell.creatTime];
    
    yHeight += 50;
    yHeight += CELL_CONTENT_MARGIN * 2;
    
    NSString *poText = status.text;
    
    if (!cell.poTextLabel) {
        cell.poTextLabel = [[UILabel alloc] init];
    }
    CGRect poTextRect = {.origin.x = CELL_CONTENT_MARGIN, .origin.y = yHeight + CELL_CONTENT_MARGIN, .size.width = ceilf(status.textSize.width), .size.height =  ceilf(status.textSize.height) };
    
    [cell.poTextLabel setFrame:poTextRect];
    [cell.poTextLabel setNumberOfLines:0];
    [cell.poTextLabel setFont:[UIFont systemFontOfSize:DEFALUTFONTSIZE]];
    
    if (!status.attributedText) {
        status.attributedText = [self AttributedString:poText];
    }
    cell.poTextLabel.attributedText = status.attributedText;

    [cell addSubview:cell.poTextLabel];

    yHeight += status.textSize.height;
    yHeight += CELL_CONTENT_MARGIN * 2;
    
    // attach pic
    if (status.hasPic) {
        yHeight += CELL_CONTENT_MARGIN;
        if (!cell.poImage) {
            cell.poImage = [[UIImageView alloc] init];
            cell.poImage.contentMode = UIViewContentModeScaleAspectFit;
        }
#warning todo multiple images
        cell.poImage.frame = CGRectMake(CELL_CONTENT_MARGIN, yHeight, 120, 120);
        cell.poImage.image = defalutImage;
        
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            UIImage *image = [weakSelf getImageWithURL: [status.pic_urls objectAtIndex:0]];
            dispatch_async(dispatch_get_main_queue(), ^{
                cell.poImage.image = image;
            });
        });
        [cell addSubview:cell.poImage];
        
        yHeight += 120;
        yHeight += CELL_CONTENT_MARGIN;
        cell.poImage.hidden = NO;
    } else {
        cell.poImage.hidden = YES;
    }
    
    reYHight = CELL_CONTENT_MARGIN;
    SYBWeiBo *reStatus = status.retweeted_status;
    if (reStatus) {
        if(!cell.repoArea){
            cell.repoArea = [[UIView alloc] init];
//            cell.repoArea.layer.backgroundColor = [[UIColor colorWithHex:0xECF0F1] CGColor];

//            CALayer *repoLayer = cell.repoArea.layer;
//            repoLayer.shadowOffset = CGSizeMake(-5, 5);
//            repoLayer.shadowColor = [UIColor colorWithHex:0x000000 alpha:1].CGColor;
//            repoLayer.shadowOpacity = 1;
            
            [cell addSubview:cell.repoArea];
        }
        
        if (!cell.repoBar) {
            cell.repoBar = [[UIView alloc] init];
            cell.repoBar.backgroundColor = [UIColor colorWithHex:0xECF0F1 alpha:1.0];
            
            [cell addSubview:cell.repoBar];
        }
        
        if (!cell.repoUsername) {
            cell.repoUsername = [[UILabel alloc] initWithFrame:CGRectMake(CELL_CONTENT_MARGIN, CELL_CONTENT_MARGIN, 0, 0)];
            cell.repoUsername.font = [UIFont boldSystemFontOfSize:DEFALUTFONTSIZE - 1];
            
            [cell.repoArea addSubview:cell.repoUsername];
        }
        cell.repoUsername.text = reStatus.user.screen_name;
        if (reStatus.usernameWidth == 0) {
           reStatus.usernameWidth = [self sizeByString:reStatus.user.screen_name UIFont:[UIFont boldSystemFontOfSize:DEFALUTFONTSIZE - 1] height:REPO_TEXTROWHEIGHT].width;
        }
        [self setView:cell.repoUsername withWidth:reStatus.usernameWidth withHeight:REPO_TEXTROWHEIGHT];

        reYHight += cell.repoUsername.frame.size.height;
        reYHight += CELL_CONTENT_MARGIN;
        
        if (!cell.repoText) {
            cell.repoText = [[UILabel alloc] initWithFrame:CGRectMake(CELL_CONTENT_MARGIN, reYHight, 0, 0)];
            cell.repoText.numberOfLines = 0;
            cell.repoText.font = [UIFont systemFontOfSize:DEFALUTFONTSIZE - 1];
            [cell.repoArea addSubview:cell.repoText];
        }
        if (!reStatus.attributedText) {
            reStatus.attributedText = [self AttributedString:reStatus.text];
        }
        cell.repoText.attributedText = reStatus.attributedText;
        
        [self setView:cell.repoText withSize:reStatus.textSize];
        reYHight += cell.repoText.frame.size.height;
        reYHight += CELL_CONTENT_MARGIN * 2;
        if (reStatus.hasPic) {
            if (!cell.repoImage) {
                cell.repoImage = [[UIImageView alloc] init];
                cell.repoImage.contentMode = UIViewContentModeScaleAspectFit;
                [cell.repoArea addSubview:cell.repoImage];
            }
            
            cell.repoImage.frame = CGRectMake(CELL_CONTENT_MARGIN, reYHight, 120, 120);
            cell.repoImage.image = defalutImage;

            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                UIImage *image = [weakSelf getImageWithURL:[reStatus.pic_urls objectAtIndex:0]];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self setImageView:cell.repoImage withSize:image.size];
                    cell.repoImage.image = image;
                    
#warning to do listTableView updates
                    [_listTableView beginUpdates];
                    [_listTableView endUpdates];
                    
                });
            });
            cell.repoImage.hidden = NO;
        } else {
            cell.repoImage.hidden = YES;
        }
        
        cell.repoArea.hidden = NO;
    } else {
        cell.repoArea.hidden = YES;
    }
    
    cell.repoArea.frame = CGRectMake(CELL_CONTENT_MARGIN * 2, yHeight, REPO_WIDTH, status.repoArea.height);
    cell.repoBar.frame = CGRectMake(CELL_CONTENT_MARGIN, yHeight, CELL_CONTENT_MARGIN, status.repoArea.height);
}

-(void)setImageView:(UIImageView *)imageView withSize:(CGSize)size
{
    [self setView:imageView withSize:size];
}
-(void)setView:(UIView *)view withWidth:(CGFloat)width withHeight:(CGFloat)height
{
    [self setView:view withSize:CGSizeMake(width, height)];
}

-(CGFloat)widthByString:(NSString *)text UIFont:(UIFont *)font height:(CGFloat)height
{
   CGSize size = [self sizeByString:text UIFont:font height:height];
    size = [self celifSize:size];
    return size.width;
}

-(CGSize)sizeByString:(NSString *)text UIFont:(UIFont *)font height:(CGFloat)height
{
    CGSize size = [text sizeWithFont:font constrainedToSize:CGSizeMake(MAXFLOAT, height) lineBreakMode:NSLineBreakByCharWrapping];
    return [self celifSize:size];
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
    
    if (status.rowHeight) {
        return [status.rowHeight floatValue];
    } else {
        rowHeight = CELL_CONTENT_MARGIN * 2 + 50;
        
        status.textSize = [self getSizeOfString:status.text withFont:[UIFont systemFontOfSize:DEFALUTFONTSIZE] withWidth:(CELL_CONTENT_WIDTH)];
        
        rowHeight += ceilf(status.textSize.height);
        rowHeight += CELL_CONTENT_MARGIN * 2 ;

        // height of image
        if (status.hasPic) {
            rowHeight += CELL_CONTENT_MARGIN * 2 ;
            status.poImageSize = CGSizeMake(120, 120);
            rowHeight += 120;
        }
        
        //height of repo
        repoHeight =  rowHeight;
        if (status.hasRepo) {
            rowHeight += CELL_CONTENT_MARGIN * 2 ;
            SYBWeiBo *reStatus = status.retweeted_status;
            rowHeight += 16;
            
            reStatus.textSize = [self getSizeOfString:reStatus.text withFont:[UIFont systemFontOfSize:DEFALUTFONTSIZE - 1] withWidth:(CELL_CONTENT_WIDTH - 2 * CELL_CONTENT_MARGIN)];
            
            rowHeight += ceilf(reStatus.textSize.height);
            
            if (reStatus.hasPic) {
                rowHeight += CELL_CONTENT_MARGIN * 2 ;
                reStatus.poImageSize = CGSizeMake(120, 120);
                rowHeight += 120;
            }
        }
        rowHeight += CELL_CONTENT_MARGIN * 2;
        repoHeight = rowHeight - repoHeight;
        status.repoArea = CGSizeMake(0, repoHeight);
        status.rowHeight = [[NSNumber alloc] initWithFloat:rowHeight];
        return rowHeight;
    }

}

- (CGSize)getSizeOfString:(NSString *)aString withFont:(UIFont *)font withWidth:(CGFloat)theWidth
{
   return  [aString sizeWithFont:font constrainedToSize:CGSizeMake(theWidth, MAXFLOAT) lineBreakMode:NSLineBreakByCharWrapping];
}

- (void)handlePan:(UIPanGestureRecognizer *)recognizer
{
    CGPoint orignCenterPoint = _listTableView.center;
    float x = orignCenterPoint.x;
    
    CGPoint transformPoint = [recognizer translationInView:_listTableView];
    x += transformPoint.x;
    
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

- (void)handleTap:(UITapGestureRecognizer *)recognizer
{
    [_listTableView setContentOffset:CGPointMake(0.0, 0.0) animated:YES];
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
    NSInteger since_id = [[NSUserDefaults standardUserDefaults] integerForKey:@"since_id"];
    NSInteger max_id = [[NSUserDefaults standardUserDefaults] integerForKey:@"max_id"];
    
    __unsafe_unretained typeof(self) weakSelf = self;
    [[SYBWeiboAPIClient sharedClient] getAllFriendsWeibo:0 max_id:0 count:0 base_app:0 feature:0 trim_user:0
                                                 success:^(NSArray *result) {
                                                     if (!_items) {
                                                         _items = result;
                                                     } else if(result) {
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

#pragma mark -
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

@end