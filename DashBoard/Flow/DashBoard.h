//
//  OverView.h
//  Flow
//
//  Created by Karthik Keyan on 8/21/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_OPTIONS(NSUInteger, DashBoardCard) {
    DashBoardCardToday = 1 << 0,
    DashBoardCardWeeklyProgress = 1 << 2,
    DashBoardCardAlert = 1 << 3,
    DashBoardCardActivity = 1 << 4,
    DashBoardCardSteps = 1 << 5,
    DashBoardCardMedication = 1 << 6,
    DashBoardCardMyJournal = 1 << 7,
    DashBoardCardComparisionOverview = 1 << 8,
    DashBoardCardHealthOverview = 1 << 9
};

@interface DashBoard : NSObject

- (DashBoardCard) availableCards;

@end
