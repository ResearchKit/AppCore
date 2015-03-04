//
//  APCMedicationSummaryTableViewCell.h
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface APCMedicationSummaryTableViewCell : UITableViewCell

@property (nonatomic, weak)  IBOutlet  UIView  *colorswatch;
@property (nonatomic, weak)  IBOutlet  UILabel  *medicationName;
@property (nonatomic, weak)  IBOutlet  UILabel  *medicationDosage;
@property (nonatomic, weak)  IBOutlet  UILabel  *medicationUseDays;

@end
