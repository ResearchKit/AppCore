// 
//  APCTextFieldTableViewCell.h 
//  AppCore 
// 
//  Copyright (c) 2014 Apple Inc. All rights reserved. 
// 
 
#import <UIKit/UIKit.h>

FOUNDATION_EXPORT NSString * const kAPCTextFieldTableViewCellIdentifier;

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
