//
//  ORKConsentSignature.h
//  ResearchKit
//
//  Created by Yuan Zhu on 2/11/15.
//  Copyright (c) 2015 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>


ORK_CLASS_AVAILABLE
@interface ORKConsentSignature : NSObject<NSSecureCoding, NSCopying>

+ (ORKConsentSignature *)signatureForPersonWithTitle:(NSString *)title
                                   dateFormatString:(NSString *)dateFormatString
                                         identifier:(NSString *)identifier
                                          firstName:(NSString *)firstName
                                           lastName:(NSString *)lastName
                                     signatureImage:(UIImage *)signatureImage
                                         dateString:(NSString *)signatureDate;

+ (ORKConsentSignature *)signatureForPersonWithTitle:(NSString *)title
                                   dateFormatString:(NSString *)dateFormatString
                                         identifier:(NSString *)identifier;

// Default YES
@property (nonatomic, assign) BOOL requiresName;

// Default YES
@property (nonatomic, assign) BOOL requiresSignatureImage;

/**
 * @brief Unique identifier
 */
@property (nonatomic, copy) NSString *identifier;

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *firstName; // "first" name (the name part displayed first)
@property (nonatomic, copy) NSString *lastName; // "last" name (the name part displayed second)
@property (nonatomic, copy) UIImage *signatureImage;
@property (nonatomic, copy) NSString *signatureDate;

/**
 * @example @"yyyy-MM-dd 'at' HH:mm"
 * If left with nil, use the user's system locale
 */
@property (nonatomic, copy) NSString *signatureDateFormatString;

@end


