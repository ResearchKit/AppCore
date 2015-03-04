//
//  APCCMS.h
//  APCAppCore
//
//  Copyright © 2015 Apple, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

NSData * cmsEncrypt(NSData *data, NSString *identityPath, NSError * __autoreleasing *error);
