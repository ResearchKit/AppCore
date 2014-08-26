//
//  OverView.m
//  Flow
//
//  Created by Karthik Keyan on 8/21/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "DashBoard.h"

@implementation DashBoard

- (DashBoardCard) availableCards {
    return DashBoardCardToday | DashBoardCardActivity | DashBoardCardMedication;
}

@end
