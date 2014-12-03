//
//  APCTextFieldTableViewCell.m
//  APCAppleCore
//
//  Created by Ramsundar Shandilya on 10/13/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APCTextFieldTableViewCell.h"
#import "NSString+Helper.h"
#import "UIColor+APCAppearance.h"
#import "UIFont+APCAppearance.h"

NSString * const kAPCTextFieldTableViewCellIdentifier = @"APCTextFieldTableViewCell";

@interface APCTextFieldTableViewCell ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textLabelWidthConstraint;

@end

@implementation APCTextFieldTableViewCell

@synthesize textLabel = _textLabel;

- (void)awakeFromNib {
    // Initialization code
    self.textField.delegate = self;
    
    [self setupAppearance];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setupAppearance
{
    [self.textLabel setFont:[UIFont appRegularFontWithSize:14.0f]];
    [self.textLabel setTextColor:[UIColor appSecondaryColor1]];
    
    [self.textField setFont:[UIFont appRegularFontWithSize:17.0f]];
    [self.textField setTextColor:[UIColor appSecondaryColor1]];
    self.textField.adjustsFontSizeToFitWidth = YES;
    self.textField.minimumFontSize = 15.0;
}

- (void)setType:(APCTextFieldCellType)type
{
    if (type == kAPCTextFieldCellTypeLeft) {
        self.textLabelWidthConstraint.constant = 111;
        self.textField.textAlignment = NSTextAlignmentLeft;
    } else {
        self.textLabelWidthConstraint.constant = 183;
        self.textField.textAlignment = NSTextAlignmentRight;
    }
    [self layoutIfNeeded];
}

#pragma mark - UITextFieldDelegate methods

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if ([self.delegate respondsToSelector:@selector(textFieldTableViewCellDidBeginEditing:)]) {
        [self.delegate textFieldTableViewCellDidBeginEditing:self];
    }
}
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if ([self.delegate respondsToSelector:@selector(textFieldTableViewCellDidEndEditing:)]) {
        [self.delegate textFieldTableViewCellDidEndEditing:self];
    }
}

- (BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if ([self.delegate respondsToSelector:@selector(textFieldTableViewCell:shouldChangeCharactersInRange:replacementString:)]) {
        [self.delegate textFieldTableViewCell:self shouldChangeCharactersInRange:range replacementString:string];
    }
    
    return YES;
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    
    if ([self.delegate respondsToSelector:@selector(textFieldTableViewCellDidReturn:)]) {
        [self.delegate textFieldTableViewCellDidReturn:self];
    }
    
    return YES;
}

@end
