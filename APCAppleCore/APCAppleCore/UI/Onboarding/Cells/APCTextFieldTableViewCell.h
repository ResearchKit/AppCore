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

@interface APCTextFieldTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *textLabel;

@property (weak, nonatomic) IBOutlet UITextField *textField;

@property (nonatomic, strong) NSString *valueTextRegularExpression;

@property (nonatomic) APCTextFieldCellType type;

@property (nonatomic, weak) id <APCTextFieldTableViewCellDelegate> delegate;

@end

@protocol APCTextFieldTableViewCellDelegate <NSObject>

- (void)textFieldTableViewCellDidBecomeFirstResponder:(APCTextFieldTableViewCell *)cell;

- (void)textFieldTableViewCellDidReturn:(APCTextFieldTableViewCell *)cell;

@end