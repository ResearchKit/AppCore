// 
//  APCParametersUserDefaultCell.h 
//  AppCore 
// 
//  Copyright (c) 2014 Apple Inc. All rights reserved. 
// 
 
#import <UIKit/UIKit.h>

@protocol APCParametersUserDefaultsCellDelegate;


@interface APCParametersUserDefaultCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *parameterTitle;
@property (weak, nonatomic) IBOutlet UITextField *parameterTextInput;
@property (nonatomic, weak) id<APCParametersUserDefaultsCellDelegate> delegate;


+ (float)heightOfCell;
@end


//Protocol
/*********************************************************************************/
@protocol APCParametersUserDefaultsCellDelegate <NSObject>


@optional
- (void) resetDidComplete:(APCParametersUserDefaultCell *)cell;

@end
/*********************************************************************************/
