//
//  APCConfigurableCell.h
//  APCAppleCore
//
//  Created by Karthik Keyan on 9/11/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import <UIKit/UIKit.h>

@class APCSegmentControl;

@protocol APCConfigurableCellDelegate;


@interface APCConfigurableCell : UITableViewCell <UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate>

@property (nonatomic, strong) NSString *valueTextRegularExpression;

@property (nonatomic, strong) UITextField *valueTextField;

@property (nonatomic, strong) UISwitch *switchView;

@property (nonatomic, strong) APCSegmentControl *segmentControl;

@property (nonatomic, strong) UIDatePicker *datePicker;

@property (nonatomic, strong) UIPickerView *customPickerView;

@property (nonatomic, readonly) NSArray *customPickerValues;

@property (nonatomic, weak) id<APCConfigurableCellDelegate> delegate;

- (void) setSegments:(NSArray *)segments selectedIndex:(NSInteger)selectedIndex;

- (void) setCustomPickerValues:(NSArray *)customPickerValues selectedRowIndices:(NSArray *)selectedRowIndices;

@end


@protocol APCConfigurableCellDelegate <NSObject>

@optional
- (void) configurableCellDidBecomFirstResponder:(APCConfigurableCell *)cell;

- (void) configurableCellDidReturnInputView:(APCConfigurableCell *)cell;

- (void) configurableCell:(APCConfigurableCell *)cell textValueChanged:(NSString *)text;

- (void) configurableCell:(APCConfigurableCell *)cell switchValueChanged:(BOOL)isOn;

- (void) configurableCell:(APCConfigurableCell *)cell segmentIndexChanged:(NSUInteger)index;

- (void) configurableCell:(APCConfigurableCell *)cell dateValueChanged:(NSDate *)date;

- (void) configurableCell:(APCConfigurableCell *)cell customPickerValueChanged:(NSArray *)selectedRowIndices;

@end
