//
//  APCParametersCoreDataCell.h
//  APCAppCore
//
//  Created by Justin Warmkessel on 9/23/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
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
