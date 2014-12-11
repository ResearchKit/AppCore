// 
//  APCLocationInfoViewController.m 
//  AppCore 
// 
//  Copyright (c) 2014 Apple Inc. All rights reserved. 
// 
 
#import "APCLocationInfoViewController.h"
#import "UIColor+APCAppearance.h"
#import "UIFont+APCAppearance.h"
#import "APCAppCore.h"

@interface APCLocationInfoViewController ()

@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;

@end

@implementation APCLocationInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.textView.text = [self prepareContent];
    
    [self setupAppearance];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
  APCLogViewControllerAppeared();
}

#pragma mark - Prepare content

- (NSString *)prepareContent
{
    return [self surveyFromJSONFile:@"LocationInfo"];
}

#pragma mark - Setup

- (void)setupAppearance
{
    [self.textView setTextColor:[UIColor appSecondaryColor1]];
    [self.textView setFont:[UIFont appLightFontWithSize:17.0f]];
    [self.textView.layer setCornerRadius:5.0f];
    [self.textView setTextContainerInset:UIEdgeInsetsMake(13, 10, 10, 10)];
    
    self.navigationBar.titleTextAttributes = @{ NSForegroundColorAttributeName : [UIColor whiteColor]};
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor whiteColor];
}

- (NSString *)surveyFromJSONFile:(NSString *)jsonFileName
{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:jsonFileName ofType:@"json"];
    NSString *JSONString = [[NSString alloc] initWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:NULL];
    
    NSError *parseError;
    NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:[JSONString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&parseError];
    
    NSString *detailsString = @"";
    
    if (!parseError) {
        
        detailsString = jsonDictionary[@"details"];
    }
    
    return detailsString;
}

#pragma mark - IBActions

- (IBAction)close:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
