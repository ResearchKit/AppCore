//
//  RKSTChoiceViewCell.h
//  ResearchKit
//
//  Copyright (c) 2014 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ResearchKit/ResearchKit_Private.h>

@interface RKSTChoiceViewCell : UITableViewCell

@property (nonatomic, strong) RKSTSelectionTitleLabel* shortLabel;
@property (nonatomic, strong) RKSTSelectionSubTitleLabel* longLabel;

+ (CGFloat)suggestedCellHeightForLongText:(NSString*)text;

@end
