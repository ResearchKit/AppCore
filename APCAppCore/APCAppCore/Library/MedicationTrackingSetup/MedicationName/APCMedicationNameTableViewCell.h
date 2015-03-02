//
//  APCMedicationNameTableViewCell.h
//  APCAppCore
//
//  Created by Henry McGilton on 3/1/15.
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface APCMedicationNameTableViewCell : UITableViewCell

@property (nonatomic, weak)  IBOutlet  UILabel  *topLabel;
@property (nonatomic, weak)  IBOutlet  UILabel  *middleLabel;
@property (nonatomic, weak)  IBOutlet  UILabel  *bottomLabel;

@end
