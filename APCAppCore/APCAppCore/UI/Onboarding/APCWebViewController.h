//
//  APCWebViewController.h
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface APCWebViewController : UIViewController <UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webview;

@property (nonatomic, strong) NSString *fileName;

@property (nonatomic, strong) NSString *fileType;

- (IBAction)close:(id)sender;

@end
