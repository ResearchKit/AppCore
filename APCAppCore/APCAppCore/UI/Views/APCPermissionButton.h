// 
//  APCPermissionButton.h 
//  AppCore 
// 
//  Copyright (c) 2014 Apple Inc. All rights reserved. 
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
