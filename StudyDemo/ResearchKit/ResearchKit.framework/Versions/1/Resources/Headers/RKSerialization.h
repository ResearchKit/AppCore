//
//  RKSerialization.h
//  ResearchKit
//
//  Copyright (c) 2014 Apple. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol RKSerialization <NSObject>

@required
- (instancetype)initWithDictionary:(NSDictionary*)dictionary;

- (NSDictionary *)dictionaryValue;

@end
