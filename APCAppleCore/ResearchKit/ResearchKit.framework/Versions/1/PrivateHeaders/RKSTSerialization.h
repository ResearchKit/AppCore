//
//  RKSTSerialization.h
//  ResearchKit
//
//  Copyright (c) 2014 Apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ResearchKit/ResearchKit.h>

@protocol RKSTSerialization <NSObject>

@required
- (instancetype)initWithDictionary:(NSDictionary*)dictionary;

- (NSDictionary *)dictionaryValue;

@end


