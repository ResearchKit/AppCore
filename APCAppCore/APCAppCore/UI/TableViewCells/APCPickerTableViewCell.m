// 
//  APCPickerTableViewCell.m 
//  APCAppCore
//
//  Copyright © 2015 Apple, Inc. All rights reserved.
//
 
#import "APCPickerTableViewCell.h"

NSString * const kAPCPickerTableViewCellIdentifier = @"APCPickerTableViewCell";

@implementation APCPickerTableViewCell

- (void)awakeFromNib {
    // Initialization code
    self.pickerView.dataSource = self;
    self.pickerView.delegate = self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setType:(APCPickerCellType)type
{
    _type = type;
    
    switch (type) {
        case kAPCPickerCellTypeDate:
        {
            self.datePicker.hidden = NO;
            self.pickerView.hidden = YES;
        }
            break;
        case kAPCPickerCellTypeCustom:
        {
            self.datePicker.hidden = YES;
            self.pickerView.hidden = NO;
        }
            break;
        default:
            break;
    }
}

#pragma mark - Getter/Setter

- (NSArray *)selectedRowIndices
{
    NSMutableArray *selectedRowIndices = [NSMutableArray array];
    
    for (NSUInteger i = 0 ; i < self.pickerValues.count; i++) {
        [selectedRowIndices addObject:@([self.pickerView selectedRowInComponent:i])];
    }
    
    return selectedRowIndices;
}

- (void)setSelectedRowIndices:(NSArray *)selectedRowIndices
{
    for (NSUInteger i = 0 ; i < selectedRowIndices.count; i++) {
        [self.pickerView selectRow:[selectedRowIndices[i] integerValue] inComponent:i animated:NO];
    }
}

#pragma mark - UIPickerViewDataSource methods

- (NSInteger) numberOfComponentsInPickerView: (UIPickerView *) __unused pickerView
{
    return self.pickerValues.count;
}

- (NSInteger) pickerView: (UIPickerView *) __unused pickerView
 numberOfRowsInComponent: (NSInteger) component
{
    return [self.pickerValues[component] count];
}

- (NSString *) pickerView: (UIPickerView *) __unused pickerView
              titleForRow: (NSInteger) row
             forComponent: (NSInteger) component
{
    return self.pickerValues[component][row];
}

#pragma mark - UIPickerViewDelegate Methods

- (void) pickerView: (UIPickerView *) pickerView
       didSelectRow: (NSInteger) __unused row
        inComponent: (NSInteger) __unused component
{
    NSMutableArray *selectedRowIndices = [NSMutableArray array];
    
    for (NSUInteger i = 0 ; i < self.pickerValues.count; i++) {
        [selectedRowIndices addObject:@([pickerView selectedRowInComponent:i])];
    }
    
    if ([self.delegate respondsToSelector:@selector(pickerTableViewCell:pickerViewDidSelectIndices:)]) {
        [self.delegate pickerTableViewCell:self pickerViewDidSelectIndices:selectedRowIndices];
    }
}

#pragma mark - Selectors

- (IBAction)dateChanged:(UIDatePicker *)picker
{
    if ([self.delegate respondsToSelector:@selector(pickerTableViewCell:datePickerValueChanged:)]) {
        [self.delegate pickerTableViewCell:self datePickerValueChanged:picker.date];
    }
}

@end
