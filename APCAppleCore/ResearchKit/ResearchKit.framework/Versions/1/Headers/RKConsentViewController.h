//
//  RKConsentViewController.h
//  ResearchKit
//
//  Copyright (c) 2013-2014 Apple Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ResearchKit/RKConsentDocument.h>

@class RKConsentViewController;

@protocol RKConsentViewControllerDelegate <NSObject>

@optional

/**
 * @brief Tells the delegate that the consent process completed.
 */
- (void)consentViewControllerDidComplete: (RKConsentViewController *)consentViewController;

/**
 * @brief Tells the delegate that the consent process failed.
 */
- (void)consentViewController: (RKConsentViewController *)consentViewController didFailWithError:(NSError*)error;

/**
 * @brief Tells the delegate that the consent process was cancelled by participant.
 */
- (void)consentViewControllerDidCancel:(RKConsentViewController *)consentViewController;

@end

@interface RKConsentViewController : UIViewController

- (instancetype)initWithConsent:(RKConsentDocument*)consent;

@property (nonatomic, readonly) RKConsentDocument* consent;

@property (nonatomic, weak) id<RKConsentViewControllerDelegate> delegate;

@end


