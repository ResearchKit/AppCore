//
//  AppDelegate.h
//  StudyDemo
//
//  Copyright (c) 2014 Apple Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RKStudyStore;

extern NSString *const MainStudyIdentifier;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) RKStudyStore *studyStore;

@property (assign, nonatomic) BOOL justJoined;

@end

