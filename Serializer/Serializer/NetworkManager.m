//
//  NetworkManager.m
//  Serializer
//
//  Created by Karthik Keyan on 8/20/14.
//  Copyright (c) 2014 Karthik Keyan. All rights reserved.
//

#import "NetworkManager.h"

@implementation NetworkManager

- (void) callAPI:(void (^)(NSDictionary *tasks, NSError *error))completion {
    completion(nil, nil);
}

@end
