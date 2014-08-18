//
//  RKConsentViewController.h
//  ResearchKit
//
//  Copyright (c) 2013-2014 Apple Inc. All rights reserved.
//

#import "RKTaskViewController.h"

@interface RKConsentViewController : RKTaskViewController

/**
 * @brief Designated initializer
 * @param consentPDF    The consent PDF to be signed.
 * @param taskInstanceUUID The UUID of this instance of the task
 */
-(instancetype)initWithConsentPDF:(NSData*)consentPDF  taskInstanceUUID:(NSUUID*)taskInstanceUUID;

@end
