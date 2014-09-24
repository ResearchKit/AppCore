//
//  APHActivitiesTableViewCell.h
//  Parkinson
//
//  Created by Henry McGilton on 8/20/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import <UIKit/UIKit.h>

@class  APCConfirmationView;

typedef NS_ENUM(NSUInteger, APHActivitiesTableViewCellType) {
    kActivitiesTableViewCellTypeDefault,
    kActivitiesTableViewCellTypeSubtitle,
};

@interface APCActivitiesTableViewCell : UITableViewCell

@property (weak, nonatomic)    UILabel              *titleLabel;
@property (weak, nonatomic)    UILabel              *subTitleLabel;
@property (weak, nonatomic)  UILabel *durationLabel;
@property (weak, nonatomic)    APCConfirmationView  *confirmationView;
@property (nonatomic, assign, getter = isCompleted)   BOOL   completed;
@property (nonatomic, assign) APHActivitiesTableViewCellType type;

@end
