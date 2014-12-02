//
//  APCSignUpMedicalInfoViewController.m
//  APCAppleCore
//
//  Created by Ramsundar Shandilya on 11/26/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APCSignUpMedicalInfoViewController.h"
#import "APCSpinnerViewController.h"
#import "APCStepProgressBar.h"
#import "UIAlertController+Helper.h"
#import "APCUser+Bridge.h"
#import "APCAppDelegate.h"

@interface APCSignUpMedicalInfoViewController ()

@end

@implementation APCSignUpMedicalInfoViewController

#pragma mark - View Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.tableHeaderView = nil;
    
    self.items = [self prepareContent];
    [self setupProgressBar];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.stepProgressBar setCompletedSteps:1 animation:YES];
}

- (NSArray *)prepareContent {
    
    NSMutableArray *items = [NSMutableArray new];
    
    NSMutableArray *rowItems = [NSMutableArray new];
    
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
    
    {
        APCTableViewCustomPickerItem *field = [APCTableViewCustomPickerItem new];
        field.caption = NSLocalizedString(@"Height", @"");
        field.identifier = kAPCDefaultTableViewCellIdentifier;
        field.selectionStyle = UITableViewCellSelectionStyleGray;
        field.detailDiscloserStyle = YES;
        field.textAlignnment = NSTextAlignmentRight;
        field.pickerData = [APCUser heights];
        if (self.user.height) {
            double heightInInches = [APCUser heightInInches:self.user.height];
            NSString *feet = [NSString stringWithFormat:@"%d'", (int)heightInInches/12];
            NSString *inches = [NSString stringWithFormat:@"%d''", (int)heightInInches%12];
            
            field.selectedRowIndices = @[ @([field.pickerData[0] indexOfObject:feet]), @([field.pickerData[1] indexOfObject:inches]) ];
        }
        else {
            field.selectedRowIndices = @[ @(5), @(0) ];
        }
        
        APCTableViewRow *row = [APCTableViewRow new];
        row.item = field;
        row.itemType = kAPCUserInfoItemTypeHeight;
        [rowItems addObject:row];
    }
    
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
    
    {
        APCTableViewDatePickerItem *field = [APCTableViewDatePickerItem new];
        field.caption = NSLocalizedString(@"What time do you wake up?", @"");
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
    
    {
        APCTableViewDatePickerItem *field = [APCTableViewDatePickerItem new];
        field.caption = NSLocalizedString(@"What time do you go to sleep?", @"");
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
    
    APCTableViewSection *section = [APCTableViewSection new];
    section.rows = [NSArray arrayWithArray:rowItems];
    [items addObject:section];
    
    return [NSArray arrayWithArray:items];
}

- (APCOnboarding *)onboarding
{
    return ((APCAppDelegate *)[UIApplication sharedApplication].delegate).onboarding;
}

#pragma mark - UIMethods

- (void) setupProgressBar {
    [self.stepProgressBar setCompletedSteps:0 animation:NO];
}


#pragma mark - Private Methods

- (void) loadProfileValuesInModel {
    
    for (int j=0; j<self.items.count; j++) {
        
        APCTableViewSection *section = self.items[j];
        
        for (int i = 0; i < section.rows.count; i++) {
            
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
