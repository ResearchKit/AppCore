//
//  Translation.h
//  Serializer
//
//  Created by Karthik Keyan on 8/20/14.
//  Copyright (c) 2014 Karthik Keyan. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol Translation <NSObject>

+ (NSDictionary *) translateToResearchKit:(NSDictionary *)aDictionary;

+ (NSDictionary *) translateToAPIManager:(NSDictionary *)aDictionary;

@end
