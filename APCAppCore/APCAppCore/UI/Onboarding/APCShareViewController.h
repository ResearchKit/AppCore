// 
//  APCShareViewController.h 
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//
 
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, APCShareType) {
    kAPCShareTypeTwitter,
    kAPCShareTypeFacebook,
    kAPCShareTypeEmail,
    kAPCShareTypeSMS
};

@interface APCShareViewController : UIViewController

@property (nonatomic) BOOL hidesOkayButton;

@end
