//
//  PurpleRecorder.m
//  StudyDemo
//
//  Copyright (c) 2014 Apple. All rights reserved.
//

#import "PurpleRecorder.h"

@implementation PurpleRecorder

- (UIView*)customView{
    UIView* view  = [[UIView alloc] init];
    [view setBackgroundColor:[UIColor purpleColor]];
    return view;
}

@end

@implementation PurpleRecorderConfigration

- (RKRecorder*)recorderForStep:(RKStep*)step taskInstanceUUID:(NSUUID*)taskInstanceUUID{
    return [PurpleRecorder new];
}

#pragma mark - RKSerialization

- (instancetype)initWithDictionary:(NSDictionary *)dictionary{
    
    self = [self init];
    if (self) {
        
    }
    return self;
}

- (NSDictionary*)dictionaryValue{
    
    NSMutableDictionary* dict = [NSMutableDictionary new];
    
    dict[@"_class"] = NSStringFromClass([self class]);
    
    return dict;
}

@end