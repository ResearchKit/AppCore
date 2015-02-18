// 
//  APCPermissionsCell.m 
//  AppCore 
// 
//  Copyright (c) 2014 Apple Inc. All rights reserved. 
// 
 
#import "APCPermissionsCell.h"
#import "UIColor+APCAppearance.h"
#import "UIFont+APCAppearance.h"

NSString * const kSignUpPermissionsCellIdentifier = @"APCPermissionsCell";

@interface APCPermissionsCell()

@end

@implementation APCPermissionsCell

- (void)awakeFromNib
{
    self.titleLabel.font = [UIFont appLightFontWithSize:25.0];
    self.titleLabel.textColor = [UIColor appSecondaryColor1];
    
    self.detailsLabel.textColor = [UIColor appSecondaryColor1];
    self.detailsLabel.font = [UIFont appRegularFontWithSize:16.f];
    
    [self.permissionButton setTitle:NSLocalizedString(@"Allow", @"Allow") forState:UIControlStateNormal];
    [self.permissionButton setTitle:NSLocalizedString(@"Granted", @"Granted") forState:UIControlStateDisabled];
}

- (IBAction)allowPermission:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(permissionsCellTappedPermissionsButton:)]) {
        [self.delegate permissionsCellTappedPermissionsButton:self];
    }
}

- (void)setPermissionsGranted:(BOOL)granted
{
    self.permissionButton.enabled = !granted;
}

@end
