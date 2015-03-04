// 
//  APCPickerTableViewCell.h 
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//
 
#import <UIKit/UIKit.h>

FOUNDATION_EXPORT NSString * const kAPCPickerTableViewCellIdentifier;

typedef NS_ENUM(NSUInteger, APCPickerCellType) {
    kAPCPickerCellTypeDate,
    kAPCPickerCellTypeCustom
};

@protocol APCPickerTableViewCellDelegate;

@interface APCPickerTableViewCell : UITableViewCell <UIPickerViewDataSource, UIPickerViewDelegate>

@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;

@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;

@property (nonatomic, strong) NSArray *pickerValues;

@property (nonatomic) APCPickerCellType type;

@property (nonatomic, weak) id <APCPickerTableViewCellDelegate> delegate;

@property (nonatomic, strong) NSArray *selectedRowIndices;

@end


@protocol APCPickerTableViewCellDelegate <NSObject>

- (void)pickerTableViewCell:(APCPickerTableViewCell *)cell datePickerValueChanged:(NSDate *)date;

- (void)pickerTableViewCell:(APCPickerTableViewCell *)cell pickerViewDidSelectIndices:(NSArray *)selectedIndices;

@end
