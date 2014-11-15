//
//  AppDelegate.h
//  StudyDemo
//
//  Copyright (c) 2014 Apple Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RKSTStudyStore;

extern NSString *const MainStudyIdentifier;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) RKSTStudyStore *studyStore;

@property (assign, nonatomic) BOOL justJoined;

@end

