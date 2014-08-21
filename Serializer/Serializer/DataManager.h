//
//  TaskManager.h
//  Serializer
//
//  Created by Karthik Keyan on 8/20/14.
//  Copyright (c) 2014 Karthik Keyan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Translation.h"

@interface DataManager : NSObject

- (instancetype) initWithTranslator:(Class<Translation>)translator;

- (void) fetchTask:(void (^)(NSDictionary *response, NSError *error))completion;

@end
