// 
//  APCShareViewController.m 
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//
 
#import "APCShareViewController.h"
#import "APCShareTableViewCell.h"
#import "UIColor+APCAppearance.h"
#import "UIFont+APCAppearance.h"
#import "UIImage+APCHelper.h"
#import "APCAppCore.h"
#import <MessageUI/MessageUI.h>
#import <Social/Social.h>

@interface APCShareViewController () <MFMessageComposeViewControllerDelegate, MFMailComposeViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *logoImageView;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UILabel *tableHeaderLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *okayButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableBottomConstraint;

@property (strong, nonatomic) NSString *shareMessage;

@end

@implementation APCShareViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupAppearance];
    [self setupNavAppearance];
    
    self.okayButton.hidden = self.hidesOkayButton;
    if (self.okayButton.hidden) {
        self.tableBottomConstraint.constant = 0;
        [self.view layoutIfNeeded];
    }
    
    [self.logoImageView setImage:[UIImage imageNamed:@"logo_disease"]];
    
    NSDictionary *initialOptions = ((APCAppDelegate *)[UIApplication sharedApplication].delegate).initializationOptions;
    self.shareMessage = initialOptions[kShareMessageKey];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
  APCLogViewControllerAppeared();
}

#pragma mark - Setup

- (void)setupAppearance
{
    [self.messageLabel setTextColor:[UIColor appSecondaryColor1]];
    [self.messageLabel setFont:[UIFont appRegularFontWithSize:19.0f]];
    
    [self.tableHeaderLabel setFont:[UIFont appLightFontWithSize:14.0f]];
    [self.tableHeaderLabel setTextColor:[UIColor appSecondaryColor3]];
    
    [self.okayButton setBackgroundImage:[UIImage imageWithColor:[UIColor appPrimaryColor]] forState:UIControlStateNormal];
    [self.okayButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.okayButton.titleLabel setFont:[UIFont appMediumFontWithSize:19.0f]];
}

- (void)setupNavAppearance
{
    UIBarButtonItem  *backster = [APCCustomBackButton customBackBarButtonItemWithTarget:self action:@selector(back) tintColor:[UIColor appPrimaryColor]];
    [self.navigationItem setLeftBarButtonItem:backster];
}

#pragma mark - UITableViewDataSource methods

- (NSInteger) tableView: (UITableView *) __unused tableView
  numberOfRowsInSection: (NSInteger) __unused section
{
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    APCShareTableViewCell *cell = (APCShareTableViewCell *)[tableView dequeueReusableCellWithIdentifier:kAPCShareTableViewCellIdentifier];
    
    switch (indexPath.row) {
        case kAPCShareTypeTwitter:
        {
            cell.textLabel.text = NSLocalizedString(@"Share on Twitter", nil);
            cell.imageView.image = [[UIImage imageNamed:@"twitter_icon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        }
            break;
        case kAPCShareTypeFacebook:
        {
            cell.textLabel.text = NSLocalizedString(@"Share on Facebook", nil);
            cell.imageView.image = [[UIImage imageNamed:@"facebook_icon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        }
            break;
        case kAPCShareTypeEmail:
        {
            cell.textLabel.text = NSLocalizedString(@"Share via Email", nil);
            cell.imageView.image = [[UIImage imageNamed:@"email_icon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        }
            break;
        case kAPCShareTypeSMS:
        {
            cell.textLabel.text = NSLocalizedString(@"Share via SMS", nil);
            cell.imageView.image = [[UIImage imageNamed:@"sms_icon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        }
            break;
            
        default:
            break;
    }
    
    cell.imageView.tintColor = [UIColor appPrimaryColor];
    
    return cell;
}

#pragma mark - UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case kAPCShareTypeTwitter:
        {
            [self postMessageForServiceType:SLServiceTypeTwitter];
        }
            break;
        case kAPCShareTypeFacebook:
        {
            [self postMessageForServiceType:SLServiceTypeFacebook];
        }
            break;
        case kAPCShareTypeEmail:
        {
            if ([MFMailComposeViewController canSendMail])
            {
                MFMailComposeViewController *mailComposeVC = [[MFMailComposeViewController alloc] init];
                mailComposeVC.mailComposeDelegate = self;
                
                [mailComposeVC setMessageBody:self.shareMessage isHTML:NO];
                
                [self presentViewController:mailComposeVC animated:YES completion:NULL];
            } else {
                NSString *message = NSLocalizedString(@"Looks like you don't have Mail app setup. Please configure to share via email.", nil);
                
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Email", nil) message:message preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *dismiss = [UIAlertAction actionWithTitle:NSLocalizedString(@"Dismiss", nil) style:UIAlertActionStyleDefault handler:nil];
                [alertController addAction:dismiss];
                [self presentViewController:alertController animated:YES completion:nil];
            }
        }
            break;
        case kAPCShareTypeSMS:
        {
            if ([MFMessageComposeViewController canSendText]) {
                MFMessageComposeViewController *messageComposer = [[MFMessageComposeViewController alloc] init];
                messageComposer.messageComposeDelegate = self;
                messageComposer.body = self.shareMessage;
                
                [self presentViewController:messageComposer animated:YES completion:nil];
            } else {
                NSString *message = NSLocalizedString(@"Looks like you don't have Messages app setup. Please configure to share via SMS.", nil);
                
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Messages", nil) message:message preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *dismiss = [UIAlertAction actionWithTitle:NSLocalizedString(@"Dismiss", nil) style:UIAlertActionStyleDefault handler:nil];
                [alertController addAction:dismiss];
                [self presentViewController:alertController animated:YES completion:nil];
            }
            
        }
            break;
            
        default:
            break;
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Helper Methods

- (void)postMessageForServiceType:(NSString *)type
{
    NSString *serviceName;
    
    if ([type isEqualToString:SLServiceTypeTwitter]){
        serviceName = @"Twitter";
    } else if ([type isEqualToString:SLServiceTypeFacebook]) {
        serviceName = @"Facebook";
    } else {
        serviceName = @"";
    }
    
    SLComposeViewController *composeViewController = [SLComposeViewController composeViewControllerForServiceType:type];
    
    [composeViewController setInitialText:self.shareMessage];
    
    [self presentViewController:composeViewController animated:YES completion:nil];
}

#pragma mark - MFMailComposeViewControllerDelegate method

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            break;
        case MFMailComposeResultSaved:
            break;
        case MFMailComposeResultSent:
            break;
        case MFMailComposeResultFailed:
            APCLogError2(error);
            break;
        default:
            break;
    }
    
    [controller dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - MFMessageComposeViewControllerDelegate method

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    switch (result)
    {
        case MessageComposeResultSent:
            break;
        case MessageComposeResultCancelled:
            break;
        case MessageComposeResultFailed:
            break;
        default:
            break;
    }
    
    [controller dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Selectors / IBActions

- (IBAction) okayTapped: (id) __unused sender
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
