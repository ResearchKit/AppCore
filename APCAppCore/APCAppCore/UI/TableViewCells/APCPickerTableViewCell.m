// 
//  APCPickerTableViewCell.m 
//  APCAppCore 
// 
// Copyright (c) 2015, Apple Inc. All rights reserved. 
// 
// Redistribution and use in source and binary forms, with or without modification,
// are permitted provided that the following conditions are met:
// 
// 1.  Redistributions of source code must retain the above copyright notice, this
// list of conditions and the following disclaimer.
// 
// 2.  Redistributions in binary form must reproduce the above copyright notice, 
// this list of conditions and the following disclaimer in the documentation and/or 
// other materials provided with the distribution. 
// 
// 3.  Neither the name of the copyright holder(s) nor the names of any contributors 
// may be used to endorse or promote products derived from this software without 
// specific prior written permission. No license is granted to the trademarks of 
// the copyright holders even if such marks are included in this software. 
// 
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE 
// FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL 
// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR 
// SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER 
// CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, 
// OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE 
// OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. 
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
