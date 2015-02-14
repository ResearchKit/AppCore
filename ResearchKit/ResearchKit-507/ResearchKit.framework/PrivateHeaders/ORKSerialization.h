//
//  ORKSerialization.h
//  ResearchKit
//
//  Copyright (c) 2014 Apple. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ORKSerialization <NSObject>

@required
- (instancetype)initWithDictionary:(NSDictionary*)dictionary;

- (NSDictionary *)dictionaryValue;

@end


