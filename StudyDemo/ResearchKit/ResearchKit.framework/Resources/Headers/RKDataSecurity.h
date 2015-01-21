//
//  RKDataSecurity.h
//  ResearchKit
//
//  Copyright (c) 2014 Apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ResearchKit/ResearchKit.h>

typedef NS_ENUM(NSInteger, RKEncryptionAlgorithm) {
    RKEncryptionAlgorithmAES128CBC = 0,
} RK_ENUM_AVAILABLE_IOS(8_3);


/**
 * @brief Produces enveloped data using Cryptographic Message Syntax (RFC 5652)
 *
 * @discussion Bulk encryption. This is not a streaming API, so limiting
 *   the size of each message is advisable.
 *
 * @param data           Data to be encrypted.
 * @param identity       X.509 PEM certificate.
 * @param error          Error is returned here if applicable.
 * @return CMS envelope, encrypted using the specified identity, or nil on failure.
 *
 * @note An exception is thrown if the identity is invalid.
 */
RK_EXTERN NSData *RKCryptographicMessageSyntaxEnvelopedData(NSData *data, NSData *identity, RKEncryptionAlgorithm algorithm, NSError * __autoreleasing *error) RK_AVAILABLE_IOS(8_3);

