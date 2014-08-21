//
//  TaskManager.m
//  Serializer
//
//  Created by Karthik Keyan on 8/20/14.
//  Copyright (c) 2014 Karthik Keyan. All rights reserved.
//

#import "NetworkManager.h"
#import "DataManager.h"

@interface DataManager ()

@property (nonatomic, strong) Class<Translation> translator;

@end

@implementation DataManager

- (instancetype) initWithTranslator:(Class<Translation>)atranslator {
    self = [super init];
    if (self) {
        _translator = atranslator;
    }
    
    return self;
}

- (void) fetchTask:(void (^)(NSDictionary *response, NSError *error))completion {
    NetworkManager *network = [NetworkManager new];
    [network callAPI:^(NSDictionary *response, NSError *error) {
        if (!error) {
            NSArray *tasks = response[@"Steps"];
            if (tasks.count > 0) {
                
                NSDictionary *translator = [self.translator translateToResearchKit:tasks[0]];
            }
        }
    }];
}

@end
