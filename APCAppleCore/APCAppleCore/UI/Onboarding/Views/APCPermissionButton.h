//
//  APCPermissionButton.h
//  APCAppleCore
//
//  Created by Ramsundar Shandilya on 10/14/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface APCPermissionButton : UIButton

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) NSString *unconfirmedTitle;

@property (nonatomic, strong) NSString *confirmedTitle;

@property (nonatomic) BOOL shouldHighlightText;

@property (nonatomic, getter=isSelected) BOOL selected;
@end
