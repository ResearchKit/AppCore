//
//  APCWebViewController.m
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import "APCWebViewController.h"

@interface APCWebViewController ()

@end

@implementation APCWebViewController

-(void)viewDidLoad{
    self.webview.delegate = self;
    self.webview.alpha = 0.0;
    NSString *filePath = [[NSBundle mainBundle] pathForResource:self.fileName ofType:self.fileType];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    [self.webview loadData:data MIMEType:@"application/pdf" textEncodingName:@"utf-8" baseURL:nil];
    [self.webview setDataDetectorTypes:UIDataDetectorTypeAll];
    self.webview.scalesPageToFit = YES;
}

-(void)webViewDidFinishLoad:(UIWebView *)webView{
    [UIView animateWithDuration:1.0 animations:^{
        self.webview.alpha = 1.0;
    }];
}

- (UIRectEdge)edgesForExtendedLayout
{
    return UIRectEdgeTop;
}

- (BOOL)automaticallyAdjustsScrollViewInsets
{
    return YES;
}

- (IBAction)close:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
