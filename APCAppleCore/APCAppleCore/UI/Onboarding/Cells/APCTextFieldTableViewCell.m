//
//  APCTextFieldTableViewCell.m
//  APCAppleCore
//
//  Created by Ramsundar Shandilya on 10/13/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APCTextFieldTableViewCell.h"
#import "NSString+Helper.h"

@interface APCTextFieldTableViewCell ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textLabelWidthConstraint;

@end

@implementation APCTextFieldTableViewCell

@synthesize textLabel = _textLabel;

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setType:(APCTextFieldCellType)type
{
    if (type == kAPCTextFieldCellTypeLeft) {
        self.textLabelWidthConstraint.constant = 120;
        self.textField.textAlignment = NSTextAlignmentLeft;
    } else {
        self.textLabelWidthConstraint.constant = 183;
        self.textField.textAlignment = NSTextAlignmentRight;
    }
}

#pragma mark - UITextFieldDelegate methods

- (BOOL) textFieldShouldBeginEditing:(UITextField *)textField {
    if ([self.delegate respondsToSelector:@selector(textFieldTableViewCellDidBecomeFirstResponder:)]) {
        [self.delegate textFieldTableViewCellDidBecomeFirstResponder:self];
    }
    
    return YES;
}

- (BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    BOOL isValid = NO;
    
    NSString *text = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    if (text.length > 0 && self.valueTextRegularExpression) {
        isValid = [text isValidForRegex:self.valueTextRegularExpression];
    }
    else {
        isValid = YES;
    }
    
    return isValid;
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    
    if ([self.delegate respondsToSelector:@selector(textFieldTableViewCellDidReturn:)]) {
        [self.delegate textFieldTableViewCellDidReturn:self];
    }
    
    return YES;
}

@end
