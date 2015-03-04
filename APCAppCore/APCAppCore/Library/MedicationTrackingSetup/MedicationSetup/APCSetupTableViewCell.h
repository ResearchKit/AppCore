//
//  APCSetupTableViewCell.h
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface APCSetupTableViewCell : UITableViewCell

@property  (nonatomic, weak)  IBOutlet  UILabel  *topicLabel;
@property  (nonatomic, weak)  IBOutlet  UILabel  *extraLabel;
@property  (nonatomic, weak)  IBOutlet  UILabel  *addTopicLabel;
@property  (nonatomic, weak)  IBOutlet  UIView   *colorSwatch;

@end
