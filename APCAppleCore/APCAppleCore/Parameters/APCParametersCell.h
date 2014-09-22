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


/************************************************/
// Adapting Karthik's code to mine.
/************************************************/

@property (nonatomic, readonly) InputCellType type;

@property (nonatomic, strong) UITextField *txtValue;

@property (nonatomic, strong) UITextField *txtTitle;

@property (nonatomic, strong) UISwitch *switchView;

@property (nonatomic, strong) UIDatePicker *datePicker;

@property (nonatomic, weak) id<APCParametersCellDelegate> delegate;

- (instancetype) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier type:(InputCellType)type;

- (id) value;


@end

@protocol APCParametersCellDelegate <NSObject>

@optional
- (void) inputCellValueChanged:(APCParametersCell *)cell;

@end