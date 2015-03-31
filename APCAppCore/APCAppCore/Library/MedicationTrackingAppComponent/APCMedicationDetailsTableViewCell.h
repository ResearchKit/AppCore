// 
//  APCMedicationDetailsTableViewCell.h 
//  APCAppCore 
// 
// Copyright (c) 2015, Apple Inc. All rights reserved. 
// 
 
#import <UIKit/UIKit.h>

@class  APCConfirmationView;

@interface APCMedicationDetailsTableViewCell : UITableViewCell

@property  (nonatomic, weak)  IBOutlet  UIView               *colorSwatch;
@property  (nonatomic, weak)  IBOutlet  UILabel              *medicationName;
@property  (nonatomic, weak)  IBOutlet  UILabel              *doseAmount;
@property  (nonatomic, weak)  IBOutlet  UILabel              *doseNumber;
@property  (nonatomic, weak)  IBOutlet  APCConfirmationView  *confirmer;

@end
