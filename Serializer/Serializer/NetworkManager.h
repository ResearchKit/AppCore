//
//  NetworkManager.h
//  Serializer
//
//  Created by Karthik Keyan on 8/20/14.
//  Copyright (c) 2014 Karthik Keyan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NetworkManager : NSObject

- (void) callAPI:(void (^)(NSDictionary *tasks, NSError *error))completion;

@end
