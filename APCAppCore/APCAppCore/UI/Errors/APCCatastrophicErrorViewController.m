//
//  APCCatastrophicErrorViewController.m
//  AppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import "APCCatastrophicErrorViewController.h"
#import "APCUtilities.h"

@interface APCCatastrophicErrorViewController ()
@property (weak, nonatomic) IBOutlet UILabel *appNameLabel;
@end

@implementation APCCatastrophicErrorViewController

- (void) viewDidLoad
{
    [super viewDidLoad];

    self.appNameLabel.text = [APCUtilities appName];
}

@end
