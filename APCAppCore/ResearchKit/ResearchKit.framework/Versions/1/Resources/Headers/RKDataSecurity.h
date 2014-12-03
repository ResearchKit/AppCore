//
//  RKDataSecurity.h
//  ResearchKit
//
//  Copyright (c) 2014 Apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ResearchKit/ResearchKit.h>


/**
 * @brief Produces enveloped data using Cryptographic Message Syntax (RFC 5652)
 *
 * @discussion Bulk encryption using 128-bit AES CBC
 *   (OID 2.16.840.1.101.3.4.1.2). This is not a streaming API, so limiting
 *   the size of each message is advisable.
 *
 * @param data           Data to be encrypted.
 * @param identity       X.509 PEM certificate.
 * @param error          Error is returned here if applicable.
 * @return CMS envelope, encrypted using the specified identity, or nil on failure.
 *
 * @note An exception is thrown if the identity is invalid.
 */
RK_EXTERN NSData *RKCryptographicMessageSyntaxEnvelopedDataAES128CBC(NSData *data, NSData *identity, NSError * __autoreleasing *error);

