// 
//  APCParametersCoreDataCell.h 
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//
 
#import <UIKit/UIKit.h>

@protocol APCParametersCoreDataCellDelegate;

@interface APCParametersCoreDataCell : UITableViewCell

@property (nonatomic, weak) id<APCParametersCoreDataCellDelegate> delegate;

+ (float)heightOfCell;

@property (weak, nonatomic) IBOutlet UIButton *resetButton;
@property (weak, nonatomic) IBOutlet UILabel *resetTitle;
@property (weak, nonatomic) IBOutlet UITextView *resetInstructions;

@end

//Protocol
/*********************************************************************************/
@protocol APCParametersCoreDataCellDelegate <NSObject>

@optional
- (void) resetDidComplete:(APCParametersCoreDataCell *)cell;

@end
/*********************************************************************************/
