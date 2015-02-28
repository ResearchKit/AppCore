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
    
    self.webview.scalesPageToFit = YES;
}

-(void)webViewDidFinishLoad:(UIWebView *) __unused webView{
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

- (IBAction)close:(id) __unused sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
