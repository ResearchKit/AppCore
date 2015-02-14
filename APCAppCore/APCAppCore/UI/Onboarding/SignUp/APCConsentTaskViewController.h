//
//  APCConsentTaskViewController.h
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import <ResearchKit/ResearchKit.h>

@interface APCConsentTaskViewController : ORKTaskViewController <ORKTaskViewControllerDelegate>
@property (strong, nonatomic) ORKConsentSignatureResult *signatureResult;
@end
