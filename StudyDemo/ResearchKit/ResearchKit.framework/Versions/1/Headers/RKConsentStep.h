//
//  RKConsentStep.h
//  ResearchKit
//
//  Copyright (c) 2013-2014 Apple Inc. All rights reserved.
//

#import <ResearchKit/ResearchKit.h>

@interface RKConsentStep : RKStep

- (instancetype)initWithIdentifier:(NSString *)identifier
                              name:(NSString *)name
                       consentFile:(NSData *)consentPdfFile;

/**
 * @note The consent file has to be PDF format.
 */
@property (nonatomic, strong) NSData *consentPdfFile;

@end
