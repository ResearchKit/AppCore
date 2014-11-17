//
//  APCConsentResult.h
//  APCAppleCore
//
//  Created by Dhanush Balachandran on 9/12/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "APCResult.h"


@interface APCConsentResult : APCResult

@property (nonatomic, retain) NSString * signatureName;
@property (nonatomic, retain) NSString * signatureDate;

@end
