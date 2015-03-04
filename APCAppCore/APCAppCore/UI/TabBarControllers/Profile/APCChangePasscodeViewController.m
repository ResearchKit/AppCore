// 
//  APCChangePasscodeViewController.m 
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//
 
#import "APCChangePasscodeViewController.h"
#import "UIColor+APCAppearance.h"
#import "UIFont+APCAppearance.h"
#import "APCKeychainStore.h"
#import "APCUserInfoConstants.h"
#import "UIAlertController+Helper.h"
#import "APCAppCore.h"

typedef NS_ENUM(NSUInteger, APCPasscodeEntryType) {
    kAPCPasscodeEntryTypeOld,
    kAPCPasscodeEntryTypeNew,
    kAPCPasscodeEntryTypeReEnter,
};

@interface APCChangePasscodeViewController ()<APCPasscodeViewDelegate>

@property (nonatomic) APCPasscodeEntryType entryType;
@property (nonatomic, strong) NSString *passcode;

@end

@implementation APCChangePasscodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.passcodeView.delegate = self;
    
    [self setupAppearance];
    self.textLabel.text = NSLocalizedString(@"Enter your old passcode", nil);
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.passcodeView becomeFirstResponder];
  APCLogViewControllerAppeared();
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Setup

- (void)setupAppearance
{
    [self.textLabel setTextColor:[UIColor appSecondaryColor1]];
    [self.textLabel setFont:[UIFont appLightFontWithSize:19.0f]];
}

#pragma mark - APCPasscodeViewDelegate

- (void) passcodeViewDidFinish:(APCPasscodeView *)passcodeView withCode:(NSString *) __unused code {
    
    switch (self.entryType) {
        case kAPCPasscodeEntryTypeOld:
        {
            if ([passcodeView.code isEqualToString:[APCKeychainStore stringForKey:kAPCPasscodeKey]]) {
                self.textLabel.text = NSLocalizedString(@"Enter your new passcode", nil);
                [passcodeView reset];
                [passcodeView becomeFirstResponder];
                self.entryType = kAPCPasscodeEntryTypeNew;
            } else{
                
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Wrong Passcode", nil) message:NSLocalizedString(@"Please enter again.", nil) preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction *okayAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * __unused action) {
                    [passcodeView reset];
                    [passcodeView becomeFirstResponder];
                }];
                [alertController addAction:okayAction];
                
                [self presentViewController:alertController animated:YES completion:nil];
            }
        }
            break;
        case kAPCPasscodeEntryTypeNew:
        {
            self.textLabel.text = NSLocalizedString(@"Re-enter your new passcode", nil);
            self.passcode = passcodeView.code;
            [passcodeView reset];
            [passcodeView becomeFirstResponder];
            self.entryType = kAPCPasscodeEntryTypeReEnter;
        }
            break;
        case kAPCPasscodeEntryTypeReEnter:
        {
            if ([passcodeView.code isEqualToString:self.passcode]) {
                [self savePasscode];
                [self dismissViewControllerAnimated:YES completion:nil];
            } else{
                [passcodeView reset];
                [passcodeView becomeFirstResponder];
                self.entryType = kAPCPasscodeEntryTypeReEnter;
                
                UIAlertController *alert = [UIAlertController simpleAlertWithTitle:NSLocalizedString(@"Wrong Passcode", nil) message:NSLocalizedString(@"The passcode you entered did not match your new passcode. Please enter again.", nil)];
                [self presentViewController:alert animated:YES completion:nil];
                
            }
        }
            break;
        default:
            break;
    }
}

- (void)savePasscode
{
    [APCKeychainStore setString:self.passcode forKey:kAPCPasscodeKey];
    self.passcode = @"";
}

- (IBAction)cancel:(id) __unused sender
{
    self.passcodeView.delegate = nil;
    [self.passcodeView resignFirstResponder];
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
