// 
//  APCParametersCell.h 
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//
 
#import <UIKit/UIKit.h>

typedef NS_OPTIONS (NSUInteger, InputCellType) {
    InputCellTypeNone = 0,
    InputCellTypeText,
    InputCellTypeSwitch,
    InputCellTypeDatePicker,
    InputCellTypeEntity
};

@protocol APCParametersCellDelegate;

@interface APCParametersCell : UITableViewCell <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UILabel *parameterTitle;

@property (weak, nonatomic) IBOutlet UITextField *parameterTextInput;

@property (weak, nonatomic) IBOutlet UIButton *resetButton;

+ (float)heightOfCell;

@property (nonatomic, weak) id<APCParametersCellDelegate> delegate;

@end

//Protocol
/*********************************************************************************/
@protocol APCParametersCellDelegate <NSObject>

@optional
- (void) inputCellValueChanged:(APCParametersCell *)cell;
@end
/*********************************************************************************/
