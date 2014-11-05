//
//  APCProfileViewController.m
//  APCAppleCore
//
//  Created by Ramsundar Shandilya on 10/10/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APCProfileViewController.h"
#import "APCAppleCore.h"
#import "APCTableViewItem.h"
#import "APCAppDelegate.h"
#import "APCUserInfoConstants.h"

#import "UIColor+APCAppearance.h"
#import "UIFont+APCAppearance.h"
#import "NSDate+Helper.h"

@interface APCProfileViewController ()<RKTaskViewControllerDelegate>


@end

@implementation APCProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupAppearance];
    
    self.firstNameTextField.delegate = self;
    self.lastNameTextField.delegate = self;

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    CGRect headerRect = self.headerView.frame;
    headerRect.size.height = 127.0f;
    self.headerView.frame = headerRect;
    
    self.tableView.tableHeaderView = self.tableView.tableHeaderView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Getter Methods

- (APCUser *) user {
    if (!_user) {
        _user = ((APCAppDelegate *)[UIApplication sharedApplication].delegate).dataSubstrate.currentUser;
    }
    
    return _user;
}

#pragma mark - Appearance

- (void)setupAppearance
{
    [self.firstNameTextField setTextColor:[UIColor appSecondaryColor1]];
    [self.firstNameTextField setFont:[UIFont appRegularFontWithSize:16.0f]];
    
    [self.lastNameTextField setTextColor:[UIColor appSecondaryColor1]];
    [self.lastNameTextField setFont:[UIFont appRegularFontWithSize:16.0f]];
    
    [self.profileImageButton.imageView.layer setCornerRadius:CGRectGetHeight(self.profileImageButton.bounds)/2];
    
    [self.editLabel setTextColor:[UIColor appSecondaryColor1]];
    [self.editLabel setFont:[UIFont appRegularFontWithSize:14.0f]];
    
    [self.footerTitleLabel setTextColor:[UIColor appSecondaryColor2]];
    [self.footerTitleLabel setFont:[UIFont appRegularFontWithSize:14.0f]];
    
    [self.editLabel setTextColor:[UIColor appSecondaryColor1]];
    [self.editLabel setFont:[UIFont appRegularFontWithSize:14.0f]];
    
    [self.editLabel setTextColor:[UIColor appSecondaryColor1]];
    [self.editLabel setFont:[UIFont appRegularFontWithSize:14.0f]];
    
    [self.diseaseLabel setTextColor:[UIColor appPrimaryColor]];
    [self.diseaseLabel setFont:[UIFont appRegularFontWithSize:16.0f]];
    
    [self.dateRangeLabel setTextColor:[UIColor appSecondaryColor3]];
    [self.dateRangeLabel setFont:[UIFont appLightFontWithSize:16.0f]];
    
    [self.reviewConsentButton setBackgroundColor:[UIColor appPrimaryColor]];
    [self.reviewConsentButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.reviewConsentButton.titleLabel setFont:[UIFont appMediumFontWithSize:19.0]];
    
    [self.signOutButton setTitleColor:[UIColor appPrimaryColor] forState:UIControlStateNormal];
    [self.signOutButton.titleLabel setFont:[UIFont appRegularFontWithSize:16.0]];
    
    [self.leaveStudyButton setTitleColor:[UIColor appPrimaryColor] forState:UIControlStateNormal];
    [self.leaveStudyButton.titleLabel setFont:[UIFont appRegularFontWithSize:16.0]];
}

- (void)setupPickerCellAppeareance:(APCPickerTableViewCell *)cell
{
    
}

- (void)setupTextFieldCellAppearance:(APCTextFieldTableViewCell *)cell
{
    [cell.textLabel setFont:[UIFont appRegularFontWithSize:14.0f]];
    [cell.textLabel setTextColor:[UIColor appSecondaryColor1]];
    
    [cell.textField setFont:[UIFont appRegularFontWithSize:17.0f]];
    [cell.textField setTextColor:[UIColor appSecondaryColor1]];
}


- (void)setupDefaultCellAppearance:(APCDefaultTableViewCell *)cell
{
    [cell.textLabel setFont:[UIFont appRegularFontWithSize:14.0f]];
    [cell.textLabel setTextColor:[UIColor appSecondaryColor1]];
    
    [cell.detailTextLabel setFont:[UIFont appRegularFontWithSize:17.0f]];
    [cell.detailTextLabel setTextColor:[UIColor appSecondaryColor1]];
}

#pragma mark - UITextFieldDelegate methods

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *text = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    if (textField == self.firstNameTextField) {
        self.user.firstName = text;
    } else if (textField == self.lastNameTextField){
        self.user.lastName = text;
    }
    
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField == self.firstNameTextField) {
        self.user.firstName = textField.text;
    } else if (textField == self.lastNameTextField){
        self.user.lastName = textField.text;
    }
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    
    if ((textField == self.firstNameTextField) && self.lastNameTextField) {
        [self.lastNameTextField becomeFirstResponder];
    } else {
        [self nextResponderForIndexPath:nil];
    }
    
    return YES;
}

#pragma mark - UIImagePickerControllerDelegate

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *image = info[UIImagePickerControllerEditedImage];
    if (!image) {
        image = info[UIImagePickerControllerOriginalImage];
    }
    
    self.profileImage = image;
    [self.profileImageButton setImage:image forState:UIControlStateNormal];
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void) imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Public methods

- (void)loadProfileValuesInModel
{
    
}

- (void)setupDataFromJSONFile:(NSString *)jsonFileName
{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:jsonFileName ofType:@"json"];
    NSString *JSONString = [[NSString alloc] initWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:NULL];
    
    NSError *parseError;
    NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:[JSONString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&parseError];
    
    if (!parseError) {
        
        self.diseaseLabel.text = jsonDictionary[@"disease_name"];
    }
}

#pragma mark - Consent

- (void)showConsent
{
    RKConsentDocument* consent = [[RKConsentDocument alloc] init];
    consent.title = @"Demo Consent";
    consent.signaturePageTitle = @"Consent";
    consent.signaturePageContent = @"I agree  to participate in this research Study.";
    
    
    RKConsentSignature *participantSig = [RKConsentSignature signatureForPersonWithTitle:@"Participant" name:nil signatureImage:nil dateString:nil];
    [consent addSignature:participantSig];
    
    RKConsentSignature *investigatorSig = [RKConsentSignature signatureForPersonWithTitle:@"Investigator" name:@"Jake Clemson" signatureImage:[UIImage imageNamed:@"signature.png"] dateString:@"9/2/14"];
    [consent addSignature:investigatorSig];
    
    
    
    
    NSMutableArray* components = [NSMutableArray new];
    
    NSArray* scenes = @[@(RKConsentSectionTypeOverview),
                        @(RKConsentSectionTypeActivity),
                        @(RKConsentSectionTypeSensorData),
                        @(RKConsentSectionTypeDeIdentification),
                        @(RKConsentSectionTypeCombiningData),
                        @(RKConsentSectionTypeUtilizingData),
                        @(RKConsentSectionTypeImpactLifeTime),
                        @(RKConsentSectionTypePotentialRiskUncomfortableQuestion),
                        @(RKConsentSectionTypePotentialRiskSocial),
                        @(RKConsentSectionTypeAllowWithdraw)];
    for (NSNumber* type in scenes) {
        RKConsentSection* c = [[RKConsentSection alloc] initWithType:type.integerValue];
        c.content = @"Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nam adhuc, meo fortasse vitio, quid ego quaeram non perspicis. Plane idem, inquit, et maxima quidem, qua fieri nulla maior potest. Quonam, inquit, modo? An potest, inquit ille, quicquam esse suavius quam nihil dolere? Cave putes quicquam esse verius. Quonam, inquit, modo?";
        [components addObject:c];
    }
    
    {
        RKConsentSection* c = [[RKConsentSection alloc] initWithType:RKConsentSectionTypeCustom];
        c.summary = @"Custom Scene summary";
        c.title = @"Custom Scene";
        c.content = @"Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nam adhuc, meo fortasse vitio, quid ego quaeram non perspicis. Plane idem, inquit, et maxima quidem, qua fieri nulla maior potest. Quonam, inquit, modo? An potest, inquit ille, quicquam esse suavius quam nihil dolere? Cave putes quicquam esse verius. Quonam, inquit, modo?";
        c.customImage = [UIImage imageNamed:@"image_example.png"];
        [components addObject:c];
    }
    
    {
        RKConsentSection* c = [[RKConsentSection alloc] initWithType:RKConsentSectionTypeOnlyInDocument];
        c.summary = @"OnlyInDocument Scene summary";
        c.title = @"OnlyInDocument Scene";
        c.content = @"Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nam adhuc, meo fortasse vitio, quid ego quaeram non perspicis. Plane idem, inquit, et maxima quidem, qua fieri nulla maior potest. Quonam, inquit, modo? An potest, inquit ille, quicquam esse suavius quam nihil dolere? Cave putes quicquam esse verius. Quonam, inquit, modo?";
        [components addObject:c];
    }
    
    consent.sections = [components copy];
    
    RKVisualConsentStep *step = [[RKVisualConsentStep alloc] initWithDocument:consent];
    RKConsentReviewStep *reviewStep = [[RKConsentReviewStep alloc] initWithSignature:participantSig inDocument:consent];
    RKTask *task = [[RKTask alloc] initWithName:@"consent" identifier:@"consent" steps:@[step,reviewStep]];
    RKTaskViewController *consentVC = [[RKTaskViewController alloc] initWithTask:task taskInstanceUUID:[NSUUID UUID]];
    
    consentVC.taskDelegate = self;
    [self presentViewController:consentVC animated:YES completion:nil];
    
}

#pragma mark - TaskViewController Delegate methods

- (void)taskViewControllerDidComplete: (RKTaskViewController *)taskViewController
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)taskViewControllerDidCancel:(RKTaskViewController *)taskViewController
{
    [taskViewController suspend];
    [taskViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - IBActions

- (IBAction)signOut:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:APCUserLogOutNotification object:self];
}

- (IBAction)leaveStudy:(id)sender
{
    
}

- (IBAction)reviewConsent:(id)sender
{
    [self showConsent];
}

- (IBAction)changeProfileImage:(id)sender
{
    if (self.isEditing) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *cameraAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Take Photo", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
            imagePickerController.editing = YES;
            imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
            imagePickerController.delegate = self;
            [self presentViewController:imagePickerController animated:YES completion:nil];
        }];
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            [alertController addAction:cameraAction];
        }
        
        UIAlertAction *libraryAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Choose from Library", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
            imagePickerController.editing = YES;
            imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            imagePickerController.delegate = self;
            [self presentViewController:imagePickerController animated:YES completion:nil];
        }];
        [alertController addAction:libraryAction];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            
        }];
        [alertController addAction:cancelAction];
        
        [self presentViewController:alertController animated:YES completion:nil];
    }    

}

- (IBAction)editFields:(UIBarButtonItem *)sender {
    
    if (self.isEditing) {
        
        if (self.isPickerShowing) {
            [self hidePickerCell];
        }
        
        sender.title = NSLocalizedString(@"Edit", @"Edit");
        sender.style = UIBarButtonItemStylePlain;
        
        [self loadProfileValuesInModel];
    } else{
        
        sender.title = NSLocalizedString(@"Done", @"Done");
        sender.style = UIBarButtonItemStyleDone;
    }
    
    self.editing = !self.editing;
    
    self.firstNameTextField.enabled = self.isEditing;
    self.lastNameTextField.enabled = self.isEditing;
    
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
}

@end
