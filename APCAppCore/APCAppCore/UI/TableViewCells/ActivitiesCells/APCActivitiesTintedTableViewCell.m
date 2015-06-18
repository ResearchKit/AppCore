// 
//  APCActivitiesTintedTableViewCell.m 
//  APCAppCore 
// 
// Copyright (c) 2015, Apple Inc. All rights reserved. 
// 
// Redistribution and use in source and binary forms, with or without modification,
// are permitted provided that the following conditions are met:
// 
// 1.  Redistributions of source code must retain the above copyright notice, this
// list of conditions and the following disclaimer.
// 
// 2.  Redistributions in binary form must reproduce the above copyright notice, 
// this list of conditions and the following disclaimer in the documentation and/or 
// other materials provided with the distribution. 
// 
// 3.  Neither the name of the copyright holder(s) nor the names of any contributors 
// may be used to endorse or promote products derived from this software without 
// specific prior written permission. No license is granted to the trademarks of 
// the copyright holders even if such marks are included in this software. 
// 
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE 
// FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL 
// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR 
// SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER 
// CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, 
// OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE 
// OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. 
// 
 
#import "APCActivitiesTintedTableViewCell.h"
#import "UIColor+APCAppearance.h"
#import "UIFont+APCAppearance.h"
#import "APCUtilities.h"
#import "APCTaskGroup.h"
#import "APCLog.h"
#import "APCSchedule+AddOn.h"
#import "APCTask+AddOn.h"


NSString * const kAPCActivitiesTintedTableViewCellIdentifier = @"APCActivitiesTintedTableViewCell";

static CGFloat const kTitleLabelCenterYConstant = 10.5f;

@interface APCActivitiesTintedTableViewCell ()
@property (nonatomic, weak)   IBOutlet  UILabel            *subTitleLabel;
@property (nonatomic, weak)   IBOutlet  UIView             *tintView;
@property (nonatomic, weak)   IBOutlet  APCBadgeLabel      *countLabel;
@property (nonatomic, weak)   IBOutlet  NSLayoutConstraint *titleLabelCenterYConstraint;
@property (nonatomic, strong)           APCTaskGroup       *taskGroup;
@end


@implementation APCActivitiesTintedTableViewCell

- (void)configureWithTaskGroup:(APCTaskGroup *)taskGroup
                   isTodayCell:(BOOL)cellRepresentsToday
             showDebuggingInfo:(BOOL)shouldShowDebuggingInfo
{
    //
    // General configuration data.
    //

    NSCharacterSet  *whitespace                     = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSString        *subtitle                       = [taskGroup.task.taskCompletionTimeString stringByTrimmingCharactersInSet: whitespace];
    NSUInteger      countOfRemainingRequiredTasks   = taskGroup.requiredRemainingTasks.count;
    NSUInteger      countOfCompletedTasks           = taskGroup.requiredCompletedTasks.count + taskGroup.gratuitousCompletedTasks.count;
    BOOL            isOptionalTask                  = taskGroup.task.taskIsOptional.boolValue;


    //
    // Tint color.
    //

    self.tintColor = (cellRepresentsToday ?
                      [UIColor colorForTaskId: taskGroup.task.taskID] :
                      [UIColor appTertiaryGrayColor]);

    if (self.tintColor == nil)
    {
        self.tintColor = [UIColor lightGrayColor];
    }
    


    //
    // General settings.
    //

    self.taskGroup                  = taskGroup;
    self.titleLabel.text            = taskGroup.task.taskTitle;
    self.titleLabel.textColor       = (cellRepresentsToday || isOptionalTask) ? [UIColor appSecondaryColor1] : [UIColor appSecondaryColor3];
    self.subTitleLabel.textColor    = [UIColor appSecondaryColor3];
    self.titleLabel.font            = [UIFont appRegularFontWithSize: kAPCActivitiesNormalFontSize];
    self.subTitleLabel.font         = [UIFont appRegularFontWithSize: kAPCActivitiesSmallFontSize];
    self.tintView.backgroundColor   = self.tintColor;
    self.countLabel.tintColor       = cellRepresentsToday ? [UIColor appPrimaryColor] : [UIColor appSecondaryColor3];


    //
    // The "to do" count in this cell (like, "4 tasks of this type to do today").
    // Note that the tint color is set above.
    //

    if (taskGroup.totalRequiredTasksForThisTimeRange > 1 &&
        ! taskGroup.isFullyCompleted)
    {
        self.countLabel.text    = @(countOfRemainingRequiredTasks).stringValue;
        self.countLabel.hidden  = NO;
    }
    else
    {
        self.countLabel.text    = nil;
        self.countLabel.hidden  = YES;
    }


    //
    // The checkmark.
    //

    self.confirmationView.completed = ! isOptionalTask && taskGroup.isFullyCompleted;
    self.confirmationView.hidden    = isOptionalTask;



    //
    // The subtitle.
    // If needed, hide the subtitle and vertically center the title.
    //

    if (subtitle.length == 0)
    {
        self.subTitleLabel.text                     = nil;
        self.subTitleLabel.hidden                   = YES;
        self.titleLabelCenterYConstraint.constant   = 0;
    }
    else
    {
        self.subTitleLabel.text                     = subtitle;
        self.subTitleLabel.hidden                   = NO;
        self.titleLabelCenterYConstraint.constant   = kTitleLabelCenterYConstant;
    }



    //
    // Debugging info, if requested.
    //

    if ([APCUtilities isInDebuggingMode] && shouldShowDebuggingInfo)
    {
        BOOL isServerTask = NO;

        if (taskGroup.task.schedules.count)
        {
            APCSchedule *anySchedule = taskGroup.task.schedules.anyObject;
            isServerTask = ((APCScheduleSource) anySchedule.scheduleSource.integerValue) == APCScheduleSourceServer;
        }

        if (isServerTask)
        {
            self.titleLabel.text = [NSString stringWithFormat: @"%@ (server)", self.titleLabel.text];
            self.titleLabel.textColor = [UIColor blueColor];
        }

        self.countLabel.hidden = NO;
        self.countLabel.text = [NSString stringWithFormat: @"%@/%@", @(countOfCompletedTasks), @(taskGroup.totalRequiredTasksForThisTimeRange)];
    }


    //
    // Draw the cell border -- the colored strip that shows
    // how this cell maps to the Dashboard.
    //

    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGFloat borderWidth = 0.25;
    
    UIColor *borderColor = [UIColor appBorderLineColor];
    
    // Top border
    CGContextSaveGState(context);
    CGContextSetLineCap(context, kCGLineCapSquare);
    CGContextSetStrokeColorWithColor(context, borderColor.CGColor);
    CGContextSetLineWidth(context, borderWidth);
    CGContextMoveToPoint(context, 0, 0);
    CGContextAddLineToPoint(context, rect.size.width, 0);
    CGContextStrokePath(context);
    CGContextRestoreGState(context);
    
    // Bottom border
    CGContextSaveGState(context);
    CGContextSetLineCap(context, kCGLineCapSquare);
    CGContextSetStrokeColorWithColor(context, borderColor.CGColor);
    CGContextSetLineWidth(context, borderWidth);
    CGContextMoveToPoint(context, 0, rect.size.height);
    CGContextAddLineToPoint(context, rect.size.width, rect.size.height);
    CGContextStrokePath(context);
    CGContextRestoreGState(context);
    
    // Sidebar
    CGFloat sidebarWidth = 4.0;
    CGFloat sidbarHeight = rect.size.height;
    CGRect sidebar = CGRectMake(0, 0, sidebarWidth, sidbarHeight);
    
    UIColor *sidebarColor = self.tintColor;
    [sidebarColor setFill];
    UIRectFill(sidebar);
}

@end
