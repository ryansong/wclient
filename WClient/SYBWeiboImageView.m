//
//  SYBWeiboImageView.m
//  WClient
//
//  Created by Song Xiaoming on 3/29/14.
//  Copyright (c) 2014 Song Xiaoming. All rights reserved.
//

#import "SYBWeiboImageView.h"

@implementation SYBWeiboImageView

static const CGFloat borderInterval = 10.0f;

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    if (self) {
        
        CGRect imageFrame = self.frame;

        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(borderInterval, borderInterval, imageFrame.size.width - borderInterval, imageFrame.size.height - borderInterval)];
            
        _imageView.frame = imageFrame;
        [self addSubview:_imageView];
        
        CGRect bounds = self.bounds;
        _imageView.center = CGPointMake(bounds.size.width / 2, bounds.size.height / 2);
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        _imageView.backgroundColor = [UIColor whiteColor];
        
        [self.layer setBorderColor:[UIColor grayColor].CGColor];
        [self.layer setBorderWidth:0.5f];
        
        [self setBackgroundColor:[UIColor whiteColor]];
        }
        


}

//- (void)loadMiddleImageWithProgress
//{
//    if (!_imageURL) {
//        return;
//    }
//    
//    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
//    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
//    
//    NSURL *URL = [NSURL URLWithString:@"_imageURL"];
//    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
//    
//    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
//        NSURL *documentsDirectoryPath = [NSURL fileURLWithPath:[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject]];
//        return [documentsDirectoryPath URLByAppendingPathComponent:[response suggestedFilename]];
//    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
//        NSLog(@"File downloaded to: %@", filePath);
//    }];
//    [downloadTask resume];
//}
//
//- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
//{
//    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
//    NSDictionary *dict = httpResponse.allHeaderFields;
//    NSString *lengthString = [dict valueForKey:@"Content-Length"];
//    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
//    NSNumber *length = [formatter numberFromString:lengthString];
//    self.totalBytes = length.unsignedIntegerValue;
//    _imageData = [[NSMutableData alloc] init];
//    NSLog(@"%d", [_imageData length]);
//    
//    [connection cancel];
//    connection = nil;
//    _imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:_imageURL]];
//        NSLog(@"%d", [_imageData length]);
//}
@end
