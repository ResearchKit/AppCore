//
//  APCConsentTaskViewController.h
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import <ResearchKit/ResearchKit.h>

@interface APCConsentTaskViewController : RKSTTaskViewController <RKSTTaskViewControllerDelegate>
@property (strong, nonatomic) RKSTConsentSignatureResult *signatureResult;
@end
