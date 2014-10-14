//
//  APCPickerTableViewCell.h
//  APCAppleCore
//
//  Created by Ramsundar Shandilya on 10/13/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import <UIKit/UIKit.h>

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

@end


@protocol APCPickerTableViewCellDelegate <NSObject>

- (void)pickerTableViewCell:(APCPickerTableViewCell *)cell datePickerValueChanged:(NSDate *)date;

- (void)pickerTableViewCell:(APCPickerTableViewCell *)cell pickerViewDidSelectIndices:(NSArray *)selectedIndices;

@end