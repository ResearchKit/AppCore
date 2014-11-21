//
//  APCStudyDetailsViewController.m
//  APCAppleCore
//
//  Created by Ramsundar Shandilya on 10/28/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APCStudyDetailsViewController.h"
#import "UIColor+APCAppearance.h"
#import "UIFont+APCAppearance.h"

@interface APCStudyDetailsViewController () <UIWebViewDelegate>

@end

@implementation APCStudyDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupAppearance];
    
    self.title = self.studyDetails.caption;
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:self.studyDetails.detailText ofType:@"pdf"];
    NSURL *targetURL = [NSURL URLWithString:filePath];
    NSURLRequest *request = [NSURLRequest requestWithURL:targetURL];
    self.webView.delegate = self;
    [self.webView loadRequest:request];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidLayoutSubviews {
    
    [super viewDidLayoutSubviews];
    
    // A Hack to get rid of the black border surrounding the PDF in the UIWebView
    UIView *view = self.webView;
    while (view) {
        view.backgroundColor = [UIColor whiteColor];
        view = [view.subviews firstObject];
    }
}

#pragma mark - Setup

- (void)setupAppearance
{
    
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    return YES;
}

@end
