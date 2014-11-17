//
//  APCTextFieldTableViewCell.h
//  APCAppleCore
//
//  Created by Ramsundar Shandilya on 10/13/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString * const kAPCTextFieldTableViewCellIdentifier = @"APCTextFieldTableViewCell";

typedef NS_ENUM(NSUInteger, APCTextFieldCellType) {
    kAPCTextFieldCellTypeLeft,
    kAPCTextFieldCellTypeRight,
};

@protocol APCTextFieldTableViewCellDelegate ;

@interface APCTextFieldTableViewCell : UITableViewCell <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UILabel *textLabel;

@property (weak, nonatomic) IBOutlet UITextField *textField;

@property (nonatomic, strong) NSString *valueTextRegularExpression;

@property (nonatomic) APCTextFieldCellType type;

@property (nonatomic, weak) id <APCTextFieldTableViewCellDelegate> delegate;

@end

@protocol APCTextFieldTableViewCellDelegate <NSObject>

@optional

- (void)textFieldTableViewCellDidBeginEditing:(APCTextFieldTableViewCell *)cell;

- (void)textFieldTableViewCellDidReturn:(APCTextFieldTableViewCell *)cell;

- (void)textFieldTableViewCell:(APCTextFieldTableViewCell *)cell shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string;

- (void)textFieldTableViewCellDidEndEditing:(APCTextFieldTableViewCell *)cell;

@end
