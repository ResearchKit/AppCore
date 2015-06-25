//
//  APCCMSSupport.h
//  APCAppCore
//
// Copyright (c) 2015, Apple Inc. All rights reserved.
//
// Redistribution and use in source and binary forms, with or without modification,
// are permitted provided that the following conditions are met:
//
// 1.  Redistributions of source code must retain the above copyright notice, this
// list of conditions and the following disclaimer.
//
// 2.  Redistributions in binary form must reproduce the above copyright notice,
// this list of conditions and the following disclaimer in the documentation and/or
// other materials provided with the distribution.
//
// 3.  Neither the name of the copyright holder(s) nor the names of any contributors
// may be used to endorse or promote products derived from this software without
// specific prior written permission. No license is granted to the trademarks of
// the copyright holders even if such marks are included in this software.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
// FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
// SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
// CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
// OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
// OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import <Foundation/Foundation.h>

/*!
 This defines the APCCMSSupport class. If an implementation of this class exists in the app in which AppCore is running,
 the cmsEncrypt() function in APCCMS.m will call its cmsEncrypt:identityPath:error: class method to encrypt data
 before it is sent to the back-end storage server, or before being saved on device to be sent on later.
 
 If no implementation of this class is found, the default behavior for cmsEncrypt() is to save and send the data
 with no encryption.
 */
@interface APCCMSSupport : NSObject

/*!
 *  Encrypt data using CMS. See https://en.wikipedia.org/wiki/Cryptographic_Message_Syntax and https://tools.ietf.org/html/rfc5652 for details.
 *
 *  @param data         The data to be encrypted.
 *  @param identityPath Path to the .pem (X.509) public key file to be used for encryption.
 *  @param error        Error, if any, encountered while attempting to encrypt the data.
 *
 *  @return The CMS-encrypted data.
 */
+ (NSData *)cmsEncrypt:(NSData *)data identityPath:(NSString *)identityPath error:(NSError * __autoreleasing *)error;

@end
