//
//  RKChoiceViewCell.h
//  ResearchKit
//
//  Copyright (c) 2014 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ResearchKit/ResearchKit_Private.h>

@interface RKChoiceViewCell : UITableViewCell

@property (nonatomic, strong) RKSelectionTitleLabel* shortLabel;
@property (nonatomic, strong) RKSelectionSubTitleLabel* longLabel;

+ (CGFloat)suggestedCellHeightForShortText:(NSString*)shortText LongText:(NSString*)longText inTableView:(UITableView*)tableView;

@end
