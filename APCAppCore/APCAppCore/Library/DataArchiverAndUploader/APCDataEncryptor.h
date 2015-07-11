//
//  APCDataEncryptor.h
//  APCAppCore
//
// Copyright (c) 2015 Apple, Inc. All rights reserved.
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

/**
 This class is provided as a wrapper for your favorite encyption API.
 Its methods should return an encrypted version of whatever is passed using the certificate in the argument.
 If the certificate is nil or encryption fails, the class is guararanteed to return nil.
 */

#import <Foundation/Foundation.h>

@interface APCDataEncryptor : NSObject

/**
 @param     data        NSData to encrypt.
 
 @param     path        NSString with the location of the certificate.
 
 @return    NSData      Encrypted JSON data. Guaranteed to return nil if certificate is nil or encryption fails.
 */
+ (NSData *) encryptData: (NSData *)data withCertificateAtPath: (NSString *)path;

/**
 @param     url             URL of file to encrypt
 
 @param     completion      Completion block to be called on successful encryption
 */
- (void) encryptFileAtURL:(NSURL *)url withCompletion:(void (^)(NSURL *encryptedURL, NSError *error))completion;

/**
 Guarantees to delete the working directory container.
 Call this method when you are finished with the encrypted data, for example after uploading.
 */
- (void) removeDirectory;

@end
