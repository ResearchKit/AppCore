//
//  NSError+Bridge.m
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

#import "NSError+Bridge.h"
#import "NSError+APCAdditions.h"
#import "APCLog.h"
#import <BridgeSDK/BridgeSDK.h>
#import "APCLog.h"
#import "APCLocalization.h"

static NSString *kSageMessageKey                 = @"message";
static NSString *kSageErrorsKey                  = @"errors";
static NSString *kSageErrorPasswordKey           = @"password";
static NSString *kSageErrorEmailKey              = @"email";
static NSString *kSageInvalidUsernameOrPassword  = @"Invalid username or password.";


@implementation NSError (Bridge)

+ (void)initialize
{
    // This class depends on strings that are localized in the +initialize method of NSError+APCAdditions, so we need to
    // ensure that it has been initialized before anything in this class gets used
    [NSError errorWithCode:0 domain:@"APCDummyErrorDomain" failureReason:nil recoverySuggestion:nil];
}

- (NSString*)bridgeErrorMessage
{
	if (![self.domain isEqualToString:SBB_ERROR_DOMAIN]) {
		return nil;
	}
	
	NSString*   message;
	id          code = self.userInfo[SBB_ORIGINAL_ERROR_KEY];
	
	if ([code isKindOfClass:[NSError class]])
	{
		NSError*    e = (NSError*)code;
		
		if (e.code == kCFURLErrorNotConnectedToInternet)
		{
			message = kAPCNotConnectedErrorMessage;
		}
		else
		{
			APCLogError(@"Network error: %@", code);
		}
	}
	else if (self.code == 400)
	{
		// There are several messages that need to be displayed within the 400
		// Extract the internal message then act appropriately.
		NSDictionary * errors = [code valueForKey: kSageErrorsKey];
		if([errors valueForKey: kSageErrorEmailKey])
		{
			message = kAPCBadEmailAddressErrorMessage;
		}
		else if([errors valueForKey: kSageErrorPasswordKey])
		{
			message = kAPCBadPasswordErrorMessage;
		} else
		{
			message = kAPCInvalidEmailAddressOrPasswordErrorMessage;
		}
		
	}
	else if (self.code == 409)
	{
		message = kAPCAccountAlreadyExistsErrorMessage;
	}
	else if (self.code == 404)
	{
		message = kAPCAccountDoesNotExistErrorMessage;
	}
	else if ([code isEqual:@(503)] || self.code == 503)
	{
		message = kAPCServerBusyErrorMessage;
	}
	else if ([code  isEqual: @(SBBErrorCodeInternetNotConnected)])
	{
		message = kAPCNotConnectedErrorMessage;
	}
	else if ([code isEqual:@(SBBErrorCodeServerNotReachable)])
	{
		message = kAPCNotReachableErrorMessage;
	}
	else if ([code isEqual:@(SBBErrorCodeServerUnderMaintenance)])
	{
		message = kAPCServerUnderMaintanenceErrorMessage;
	}
	else
	{
		message = kAPCUnexpectedConditionErrorMessage;
	}
	
	return message;
}

@end
