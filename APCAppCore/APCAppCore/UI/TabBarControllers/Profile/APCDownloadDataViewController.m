//
//  APCDownloadDataViewController.m
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

#import "APCDownloadDataViewController.h"
#import "APCAppDelegate.h"
#import "APCUser+Bridge.h"
#import "NSDate+Helper.h"
#import "APCAppCore.h"

@interface APCDownloadDataViewController ()

@property (nonatomic, strong) APCUser *user;
@property (nonatomic, strong) UIToolbar *inputDoneBar;
@property (nonatomic, strong) UIDatePicker *startDatePicker;
@property (nonatomic, strong) UIDatePicker *endDatePicker;

@end

@implementation APCDownloadDataViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupTextFields];
    [self updateDateTextFields];
    [self setupNavAppearance];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Setup

- (void)setupNavAppearance
{
    UIBarButtonItem  *backster = [APCCustomBackButton customBackBarButtonItemWithTarget:self action:@selector(back:) tintColor:[UIColor appPrimaryColor]];
    [self.navigationItem setLeftBarButtonItem:backster];
}

- (void)setupTextFields {
    [self.startTextField setFont:[UIFont appRegularFontWithSize:16.0f]];
    [self.startTextField setTextColor:[UIColor appSecondaryColor1]];
    [self.endTextField setFont:[UIFont appRegularFontWithSize:16.0f]];
    [self.endTextField setTextColor:[UIColor appSecondaryColor1]];
    
    [self.startTextField setInputView:self.startDatePicker];
    [self.endTextField setInputView:self.endDatePicker];
    
    if (_inputDoneBar == nil) {
        _inputDoneBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 44)];
        UIBarButtonItem *extraSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(updateDates:)];
        [_inputDoneBar setItems:[[NSArray alloc] initWithObjects: extraSpace, done, nil]];
    }
    
    self.startTextField.inputAccessoryView = _inputDoneBar;
    self.endTextField.inputAccessoryView = _inputDoneBar;
}

#pragma mark - Getters

- (UIDatePicker *) startDatePicker {
    if (!_startDatePicker) {
        _startDatePicker = [[UIDatePicker alloc] init];
        NSDate *today = [NSDate date];
        _startDatePicker.date = today.startOfYear;
        [_startDatePicker setMaximumDate:today];
        _startDatePicker.datePickerMode = UIDatePickerModeDate;
    }
    
    return _startDatePicker;
}

- (UIDatePicker *) endDatePicker {
    if (!_endDatePicker) {
        _endDatePicker = [[UIDatePicker alloc] init];
        NSDate *today = [NSDate date];
        _endDatePicker.date = today;
        [_endDatePicker setMaximumDate:today];
        _endDatePicker.datePickerMode = UIDatePickerModeDate;
    }
    
    return _endDatePicker;
}

- (APCUser *) user {
    if (!_user) {
        _user = ((APCAppDelegate *)[UIApplication sharedApplication].delegate).dataSubstrate.currentUser;
    }
    
    return _user;
}

#pragma mark - Actions

-(void)updateDates:(id) __unused sender
{
    [self.startTextField resignFirstResponder];
    [self.endTextField resignFirstResponder];
    [self updateDateTextFields];
}

-(void)updateDateTextFields
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.timeStyle = NSDateFormatterNoStyle;
    dateFormatter.dateStyle = NSDateFormatterMediumStyle;
    self.startTextField.text = [dateFormatter stringFromDate:self.startDatePicker.date];
    self.endTextField.text = [dateFormatter stringFromDate:self.endDatePicker.date];
}

- (IBAction)downloadData:(id) __unused sender {
    self.user.downloadDataStartDate = self.startDatePicker.date;
    self.user.downloadDataEndDate = self.endDatePicker.date;
    [self.user sendDownloadDataOnCompletion:nil];
}

- (void)back:(id) __unused sender
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

@end
