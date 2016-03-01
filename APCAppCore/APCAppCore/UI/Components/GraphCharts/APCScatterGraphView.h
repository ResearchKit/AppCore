//
//  APCScatterGraphView.h
//  APCAppCore
//
//  Created by Jake Krog on 2016-03-01.
//  Copyright © 2016 Apple, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "APCBaseGraphView.h"

@protocol APCScatterGraphViewDataSource;

@interface APCScatterGraphView : APCBaseGraphView

@property (weak, nonatomic) id <APCScatterGraphViewDataSource> dataSource;

@end

@protocol APCScatterGraphViewDataSource <NSObject>
@optional

@end