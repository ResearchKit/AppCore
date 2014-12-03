//
//  APCPermissionButton.h
//  APCAppCore
//
//  Created by Ramsundar Shandilya on 10/14/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, APCPermissionButtonAlignment) {
    kAPCPermissionButtonAlignmentCenter,
    kAPCPermissionButtonAlignmentLeft
};

@interface APCPermissionButton : UIButton

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) NSString *unconfirmedTitle;

@property (nonatomic, strong) NSString *confirmedTitle;

@property (nonatomic) BOOL shouldHighlightText;

@property (nonatomic, getter=isSelected) BOOL selected;

@property (nonatomic, getter=isAttributed) BOOL attributed;

@property (nonatomic) APCPermissionButtonAlignment alignment;

@end
