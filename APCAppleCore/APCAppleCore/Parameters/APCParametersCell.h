//
//  APCParametersCellTableViewCell.h
//  ParametersDashboard
//
//  Created by Justin Warmkessel on 9/19/14.
//  Copyright (c) 2014 Justin Warmkessel. All rights reserved.
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
