// 
//  APCStudyDetailsViewController.m 
//  AppCore 
// 
//  Copyright (c) 2014 Apple Inc. All rights reserved. 
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
    [self setupNavAppearance];
    
    self.title = self.studyDetails.caption;
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:self.studyDetails.detailText ofType:@"html" inDirectory:@"HTMLContent"];
    NSURL *targetURL = [NSURL URLWithString:filePath];
    NSURLRequest *request = [NSURLRequest requestWithURL:targetURL];
    self.webView.delegate = self;
    [self.webView loadRequest:request];
    [self.webView setDataDetectorTypes:UIDataDetectorTypeAll];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
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

- (void)setupNavAppearance
{
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(0, 0, 44, 44);
    [backButton setImage:[[UIImage imageNamed:@"back_button"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    backButton.tintColor = [UIColor appPrimaryColor];
    [backButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *backBarButton = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    [self.navigationItem setLeftBarButtonItem:backBarButton];
}

#pragma mark - Setup

- (void)setupAppearance
{
    
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    return YES;
}

#pragma mark - Selectors / IBActions

- (void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
