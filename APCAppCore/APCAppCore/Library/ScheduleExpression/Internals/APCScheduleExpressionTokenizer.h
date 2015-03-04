//
//  APCScheduleExpressionTokenizer.h
//  APCAppCore
//
//  Copyright © 2015 Apple, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class APCScheduleExpressionToken;


/*
 
 I found these helpful:
 http://en.wikipedia.org/wiki/Tokenization_(lexical_analysis)
 http://en.wikipedia.org/wiki/Lexical_analysis
 
 */
@interface APCScheduleExpressionTokenizer : NSObject

- (APCScheduleExpressionToken *) nextTokenFromString: (NSString *) string;

@end
