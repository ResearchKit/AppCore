// 
//  APCSignUpMedicalInfoViewController.m 
//  AppCore 
// 
//  Copyright (c) 2014 Apple Inc. All rights reserved. 
// 
 
#import "APCSignUpMedicalInfoViewController.h"
#import "APCSpinnerViewController.h"
#import "UIAlertController+Helper.h"
#import "APCUser+Bridge.h"
#import "APCAppDelegate.h"
#import "APCPermissionButton.h"
#import "APCPermissionsManager.h"
#import "APCAppCore.h"

@interface APCSignUpMedicalInfoViewController ()

@property (nonatomic, strong) APCPermissionsManager *permissionManager;
@property (nonatomic) BOOL permissionGranted;

@end

@implementation APCSignUpMedicalInfoViewController

#pragma mark - View Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.tableHeaderView = nil;
    
    self.items = [self prepareContent];
    
    self.navigationItem.hidesBackButton = YES;
    
    self.permissionManager = [[APCPermissionsManager alloc] init];
    
    self.permissionGranted = [self.permissionManager isPermissionsGrantedForType:kSignUpPermissionsTypeHealthKit];
    
    __weak typeof(self) weakSelf = self;
    if (!self.permissionGranted) {
        [self.permissionManager requestForPermissionForType:kSignUpPermissionsTypeHealthKit withCompletion:^(BOOL granted, NSError * __unused error) {
            if (granted) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    weakSelf.permissionGranted = YES;
                    weakSelf.items = [self prepareContent];
                    [weakSelf.tableView reloadData];
                });
            }
        }];
    }
    
    self.title = NSLocalizedString(@"Additional Information", @"Additional Information");
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.stepProgressBar setCompletedSteps:([self onboarding].onboardingTask.currentStepNumber - 1) animation:YES];
  APCLogViewControllerAppeared();
    
}

- (NSArray *)prepareContent {
    
    NSDictionary *initialOptions = ((APCAppDelegate *)[UIApplication sharedApplication].delegate).initializationOptions;
    NSArray *profileElementsList = initialOptions[kAppProfileElementsListKey];
    
    NSMutableArray *items = [NSMutableArray new];
    
    {
        NSMutableArray *rowItems = [NSMutableArray new];
        
        for (NSNumber *type in profileElementsList) {
            
            APCUserInfoItemType itemType = type.integerValue;
            
            switch (itemType) {
                case kAPCUserInfoItemTypeBloodType:
                {
                    APCTableViewCustomPickerItem *field = [APCTableViewCustomPickerItem new];
                    field.caption = NSLocalizedString(@"Blood Type", @"");
                    field.identifier = kAPCDefaultTableViewCellIdentifier;
                    field.selectionStyle = UITableViewCellSelectionStyleGray;
                    field.detailDiscloserStyle = YES;
                    
                    if (self.user.bloodType) {
                        field.selectedRowIndices = @[ @(self.user.bloodType) ];
                        field.editable = NO;
                    }
                    
                    field.textAlignnment = NSTextAlignmentRight;
                    field.pickerData = @[ [APCUser bloodTypeInStringValues] ];
                    
                    APCTableViewRow *row = [APCTableViewRow new];
                    row.item = field;
                    row.itemType = kAPCUserInfoItemTypeBloodType;
                    [rowItems addObject:row];
                    
                }
                    break;
                    
                case kAPCUserInfoItemTypeMedicalCondition:
                {
                    APCTableViewCustomPickerItem *field = [APCTableViewCustomPickerItem new];
                    field.caption = NSLocalizedString(@"Medical Conditions", @"");
                    field.identifier = kAPCDefaultTableViewCellIdentifier;
                    field.selectionStyle = UITableViewCellSelectionStyleGray;
                    field.detailDiscloserStyle = YES;
                    field.pickerData = @[ [APCUser medicalConditions] ];
                    field.textAlignnment = NSTextAlignmentRight;
                    if (self.user.medicalConditions) {
                        field.selectedRowIndices = @[ @([field.pickerData[0] indexOfObject:self.user.medicalConditions]) ];
                    }
                    else {
                        field.selectedRowIndices = @[ @(0) ];
                    }
                    
                    APCTableViewRow *row = [APCTableViewRow new];
                    row.item = field;
                    row.itemType = kAPCUserInfoItemTypeMedicalCondition;
                    [rowItems addObject:row];
                }
                    break;
                    
                case kAPCUserInfoItemTypeMedication:
                {
                    APCTableViewCustomPickerItem *field = [APCTableViewCustomPickerItem new];
                    field.caption = NSLocalizedString(@"Medications", @"");
                    field.identifier = kAPCDefaultTableViewCellIdentifier;
                    field.selectionStyle = UITableViewCellSelectionStyleGray;
                    field.detailDiscloserStyle = YES;
                    field.textAlignnment = NSTextAlignmentRight;
                    field.pickerData = @[ [APCUser medications] ];
                    
                    if (self.user.medications) {
                        field.selectedRowIndices = @[ @([field.pickerData[0] indexOfObject:self.user.medications]) ];
                    }
                    else {
                        field.selectedRowIndices = @[ @(0) ];
                    }
                    
                    APCTableViewRow *row = [APCTableViewRow new];
                    row.item = field;
                    row.itemType = kAPCUserInfoItemTypeMedication;
                    [rowItems addObject:row];
                }
                    break;
                    
                case kAPCUserInfoItemTypeHeight:
                {
                    APCTableViewCustomPickerItem *field = [APCTableViewCustomPickerItem new];
                    field.caption = NSLocalizedString(@"Height", @"");
                    field.identifier = kAPCDefaultTableViewCellIdentifier;
                    field.selectionStyle = UITableViewCellSelectionStyleGray;
                    field.detailDiscloserStyle = YES;
                    field.textAlignnment = NSTextAlignmentRight;
                    field.pickerData = [APCUser heights];

					NSInteger indexOfMyHeightInFeet = 0;
                    NSInteger indexOfMyHeightInInches = 0;

                    if (self.user.height) {
                        double heightInInches = round([APCUser heightInInches:self.user.height]);
                        
                        NSString *feet = [NSString stringWithFormat:@"%d'", (int)heightInInches/12];
                        NSString *inches = [NSString stringWithFormat:@"%d''", (int)heightInInches%12];

						NSArray *allPossibleHeightsInFeet = field.pickerData [0];
						NSArray *allPossibleHeightsInInches = field.pickerData [1];

						indexOfMyHeightInFeet = [allPossibleHeightsInFeet indexOfObject: feet];
						indexOfMyHeightInInches = [allPossibleHeightsInInches indexOfObject: inches];
                    }

                    if (indexOfMyHeightInFeet && indexOfMyHeightInInches) {
                        field.selectedRowIndices = @[ @(indexOfMyHeightInFeet), @(indexOfMyHeightInInches) ];
                    }

                    APCTableViewRow *row = [APCTableViewRow new];
                    row.item = field;
                    row.itemType = kAPCUserInfoItemTypeHeight;
                    [rowItems addObject:row];
                }
                    break;
                    
                case kAPCUserInfoItemTypeWeight:
                {
                    APCTableViewTextFieldItem *field = [APCTableViewTextFieldItem new];
                    field.caption = NSLocalizedString(@"Weight", @"");
                    field.placeholder = NSLocalizedString(@"add weight (lb)", @"");
                    field.style = UITableViewCellStyleValue1;
                    field.identifier = kAPCTextFieldTableViewCellIdentifier;
                    field.regularExpression = kAPCMedicalInfoItemWeightRegEx;
                    field.keyboardType = UIKeyboardTypeDecimalPad;
                    field.textAlignnment = NSTextAlignmentRight;
                    
                    if (self.user.weight) {
                        field.value = [NSString stringWithFormat:@"%.0f", [APCUser weightInPounds:self.user.weight]];
                    }
                    
                    APCTableViewRow *row = [APCTableViewRow new];
                    row.item = field;
                    row.itemType = kAPCUserInfoItemTypeWeight;
                    [rowItems addObject:row];
                }
                    break;
                    
                case kAPCUserInfoItemTypeWakeUpTime:
                {
                    APCTableViewDatePickerItem *field = [APCTableViewDatePickerItem new];
                    field.caption = NSLocalizedString(@"What time do you generally wake up?", @"");
                    field.placeholder = @"--:--";
                    field.identifier = kAPCDefaultTableViewCellIdentifier;
                    field.selectionStyle = UITableViewCellSelectionStyleGray;
                    field.datePickerMode = UIDatePickerModeTime;
                    field.dateFormat = kAPCMedicalInfoItemSleepTimeFormat;
                    field.textAlignnment = NSTextAlignmentRight;
                    field.detailDiscloserStyle = YES;
                    
                    if (self.user.sleepTime) {
                        field.date = self.user.sleepTime;
                    }
                    
                    APCTableViewRow *row = [APCTableViewRow new];
                    row.item = field;
                    row.itemType = kAPCUserInfoItemTypeWakeUpTime;
                    [rowItems addObject:row];
                }
                    break;
                    
                case kAPCUserInfoItemTypeSleepTime:
                {
                    APCTableViewDatePickerItem *field = [APCTableViewDatePickerItem new];
                    field.caption = NSLocalizedString(@"What time do you generally go to sleep?", @"");
                    field.placeholder = @"--:--";
                    field.style = UITableViewCellStyleValue1;
                    field.identifier = kAPCDefaultTableViewCellIdentifier;
                    field.selectionStyle = UITableViewCellSelectionStyleGray;
                    field.datePickerMode = UIDatePickerModeTime;
                    field.dateFormat = kAPCMedicalInfoItemSleepTimeFormat;
                    field.textAlignnment = NSTextAlignmentRight;
                    field.detailDiscloserStyle = YES;
                    
                    if (self.user.wakeUpTime) {
                        field.date = self.user.wakeUpTime;
                    }
                    
                    APCTableViewRow *row = [APCTableViewRow new];
                    row.item = field;
                    row.itemType = kAPCUserInfoItemTypeSleepTime;
                    [rowItems addObject:row];;
                }
                    break;
                    
                default:
                    break;
            }
        }
        
        APCTableViewSection *section = [APCTableViewSection new];
        section.rows = [NSArray arrayWithArray:rowItems];
        [items addObject:section];
        
    }
    
    return [NSArray arrayWithArray:items];
}

- (APCOnboarding *)onboarding
{
    return ((APCAppDelegate *)[UIApplication sharedApplication].delegate).onboarding;
}

#pragma mark - UIMethods

- (void) setupProgressBar {
    [self.stepProgressBar setCompletedSteps:([self onboarding].onboardingTask.currentStepNumber - 2) animation:NO];
}


#pragma mark - Private Methods

- (void) loadProfileValuesInModel {
    
    for (NSUInteger j=0; j<self.items.count; j++) {
        
        APCTableViewSection *section = self.items[j];
        
        for (NSUInteger i = 0; i < section.rows.count; i++) {
            
            APCTableViewRow *row = section.rows[i];
            
            APCTableViewItem *item = row.item;
            APCTableViewItemType itemType = row.itemType;
            
            switch (itemType) {
                case kAPCUserInfoItemTypeMedicalCondition:
                    self.user.medicalConditions = [(APCTableViewCustomPickerItem *)item stringValue];
                    break;
                    
                case kAPCUserInfoItemTypeMedication:
                    self.user.medications = [(APCTableViewCustomPickerItem *)item stringValue];
                    break;
                    
                case kAPCUserInfoItemTypeHeight:
                {
                    double height = [APCUser heightInInchesForSelectedIndices:[(APCTableViewCustomPickerItem *)item selectedRowIndices]];
                    HKUnit *inchUnit = [HKUnit inchUnit];
                    HKQuantity *heightQuantity = [HKQuantity quantityWithUnit:inchUnit doubleValue:height];
                    
                    self.user.height = heightQuantity;
                }
                    
                    break;
                    
                case kAPCUserInfoItemTypeWeight:
                {
                    double weight = [[(APCTableViewTextFieldItem *)item value] floatValue];
                    HKUnit *poundUnit = [HKUnit poundUnit];
                    HKQuantity *weightQuantity = [HKQuantity quantityWithUnit:poundUnit doubleValue:weight];
                    
                    self.user.weight = weightQuantity;
                }
                    break;
                    
                case kAPCUserInfoItemTypeSleepTime:
                    self.user.sleepTime = [(APCTableViewDatePickerItem *)item date];
                    break;
                    
                case kAPCUserInfoItemTypeWakeUpTime:
                    self.user.wakeUpTime = [(APCTableViewDatePickerItem *)item date];
                    break;
                    
                default:
                    //#warning ASSERT_MESSAGE Require
                    NSAssert(itemType <= kAPCUserInfoItemTypeWakeUpTime, @"ASSER_MESSAGE");
                    break;
            }
        }
    }
    
}

- (IBAction) next {
    [self loadProfileValuesInModel];
    
    UIViewController *viewController = [[self onboarding] nextScene];
    [self.navigationController pushViewController:viewController animated:YES];
}

@end
