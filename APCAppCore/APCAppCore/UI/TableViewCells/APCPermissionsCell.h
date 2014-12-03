// 
//  APCPermissionsCell.h 
//  AppCore 
// 
//  Copyright (c) 2014 Apple Inc. All rights reserved. 
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
