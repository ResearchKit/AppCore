//
//  APCDataResult.h
//  AppCore 
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import <ResearchKit/ResearchKit.h>

@interface APCDataResult : ORKResult

@property (nonatomic, strong) NSData *data;
@end
