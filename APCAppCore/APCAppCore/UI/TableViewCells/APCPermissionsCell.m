//
//  APCPermissionsCell.m
//  APCAppCore
//
//  Created by Ramsundar Shandilya on 9/19/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APCPermissionsCell.h"
#import "UIColor+APCAppearance.h"

NSString * const kSignUpPermissionsCellIdentifier = @"APCPermissionsCell";

@interface APCPermissionsCell()

@property (weak, nonatomic) IBOutlet APCPermissionButton *permissionsButton;

@end

@implementation APCPermissionsCell

- (void)awakeFromNib
{
    self.backgroundColor = [UIColor colorWithWhite:248/255.f alpha:1.0];
    
    self.permissionsButton.confirmedTitle = NSLocalizedString(@"Access Granted", @"");
    self.permissionsButton.unconfirmedTitle = NSLocalizedString(@"Grant Access", @"");
}

- (IBAction)permissionButtonTapped:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(permissionsCellTappedPermissionsButton:)]) {
        [self.delegate permissionsCellTappedPermissionsButton:self];
    }
}

- (void)setPermissionsGranted:(BOOL)granted
{
    [self.permissionsButton setSelected:granted];
}

@end
