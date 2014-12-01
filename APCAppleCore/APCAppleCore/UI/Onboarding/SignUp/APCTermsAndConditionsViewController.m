//
//  APCTermsAndConditionsViewController.m
//  APCAppleCore
//
//  Created by Ramsundar Shandilya on 10/21/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APCTermsAndConditionsViewController.h"
#import "UIColor+APCAppearance.h"
#import "UIFont+APCAppearance.h"

@interface APCTermsAndConditionsViewController ()

@property (weak, nonatomic) IBOutlet UIButton *agreeButton;
@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;

@end

@implementation APCTermsAndConditionsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.textView.text = [self prepareContent];
    
    [self setupAppearance];
}

#pragma mark - Prepare content

- (NSString *)prepareContent
{
    return [self surveyFromJSONFile:@"TermsAndConditions"];
}

#pragma mark - Setup

- (void)setupAppearance
{
    [self.textView setTextColor:[UIColor appSecondaryColor1]];
    [self.textView setFont:[UIFont appLightFontWithSize:17.0f]];
    [self.textView.layer setCornerRadius:5.0f];
    [self.textView setTextContainerInset:UIEdgeInsetsMake(13, 10, 10, 10)];
    
    self.navigationBar.titleTextAttributes = @{ NSForegroundColorAttributeName : [UIColor whiteColor]};
    
    [self.agreeButton setTitleColor:[UIColor appPrimaryColor] forState:UIControlStateNormal];
    [self.agreeButton.titleLabel setFont:[UIFont appMediumFontWithSize:19.0]];
}

- (NSString *)surveyFromJSONFile:(NSString *)jsonFileName
{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:jsonFileName ofType:@"json"];
    NSString *JSONString = [[NSString alloc] initWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:NULL];
    
    NSError *parseError;
    NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:[JSONString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&parseError];
    
    NSString *termsString = @"";
    
    if (!parseError) {
        
        termsString = jsonDictionary[@"terms"];
    }
    
    return termsString;
}

#pragma mark - IBActions

- (IBAction)agree:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(termsAndConditionsViewControllerDidAgree)]) {
        [self.delegate termsAndConditionsViewControllerDidAgree];
    }
}

- (IBAction)close:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(termsAndConditionsViewControllerDidCancel)]) {
        [self.delegate termsAndConditionsViewControllerDidCancel];
    }
}

@end
