//
//  APCUserInfoCell.m
//  APCAppleCore
//
//  Created by Karthik Keyan on 8/11/14.
//  Copyright (c) 2014 Karthik Keyan. All rights reserved.
//

#import "APCUserInfoCell.h"
#import "UIView+Category.h"
#import "APCSegmentControl.h"
#import "UITableView+Appearance.h"

@interface APCUserInfoCell ()

@property (nonatomic, strong) CALayer *profileImageCircleLayer;

@end

@implementation APCUserInfoCell

- (instancetype) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.textLabel.font = [UITableView textLabelFont];
        self.textLabel.textColor = [UITableView textLabelTextColor];
        
        self.detailTextLabel.font = [UITableView detailLabelFont];
        self.detailTextLabel.textColor = [UITableView detailLabelTextColor];
    }
    
    return self;
}

- (UIEdgeInsets) layoutMargins {
    return UIEdgeInsetsZero;
}


#pragma mark - Public Methods

- (void) setNeedsHiddenField {
    self.valueTextField.hidden = YES;
    [self addSubview:self.valueTextField];
}

@end
