//
//  APCPermissionsCell.h
//  APCAppCore
//
//  Created by Ramsundar Shandilya on 9/19/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "APCPermissionButton.h"

FOUNDATION_EXPORT NSString * const kSignUpPermissionsCellIdentifier;

@class APCPermissionsCell;

@protocol APCPermissionCellDelegate <NSObject>

- (void)permissionsCellTappedPermissionsButton:(APCPermissionsCell *)cell;

@end

@interface APCPermissionsCell : UITableViewCell

@property (unsafe_unretained, nonatomic) IBOutlet UILabel *titleLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *detailsLabel;

@property (weak, nonatomic) id <APCPermissionCellDelegate> delegate;
@property (strong, nonatomic) NSIndexPath *indexPath;

- (void)setPermissionsGranted:(BOOL)granted;

@end
