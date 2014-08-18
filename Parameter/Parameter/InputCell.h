//
//  InputCell.h
//  Configuration
//
//  Created by Karthik Keyan on 8/11/14.
//  Copyright (c) 2014 Karthik Keyan. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_OPTIONS (NSUInteger, InputCellType) {
    InputCellTypeNone = 0,
    InputCellTypeText,
    InputCellTypeSwitch,
    InputCellTypeDatePicker,
    InputCellTypeEntity
};

@protocol InputCellDelegate;

@interface InputCell : UITableViewCell

@property (nonatomic, readonly) InputCellType type;

@property (nonatomic, strong) UITextField *txtValue;

@property (nonatomic, strong) UITextField *txtTitle;

@property (nonatomic, strong) UISwitch *switchView;

@property (nonatomic, strong) UIDatePicker *datePicker;

@property (nonatomic, weak) id<InputCellDelegate> delegate;

- (instancetype) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier type:(InputCellType)type;

- (id) value;

@end


@protocol InputCellDelegate <NSObject>

@optional
- (void) inputCellValueChanged:(InputCell *)cell;

@end