//
//  YMLCommon.h

//
//  Created by vivek Rajanna on 05/04/12.
//  Copyright (c) 2012 YMedia Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>






//#define TFServerLog TFLog






typedef void (^okCallback_)(void) ;
typedef     void (^dismissCallback_)(void); ;
@interface YMLAlertView : UIAlertView <UIAlertViewDelegate> {

}

- (id)initWithTitle:(NSString *)title message:(NSString *)message dismissTitle:(NSString *)dismissTitle okTitle:(NSString *)okTitle dismissBlock:(void (^)(void))dismissBlock okBlock:(void (^)(void))okBlock;
+ (id)alertWithTitle:(NSString *)title message:(NSString *)message dismissTitle:(NSString *)dismissTitle okTitle:(NSString *)okTitle dismissBlock:(void (^)(void))dismissBlock okBlock:(void (^)(void))okBlock;
+ (void)showAlertWithTitle:(NSString *)title message:(NSString *)message dismissTitle:(NSString *)dismissTitle okTitle:(NSString *)okTitle dismissBlock:(void (^)(void))dismissBlock okBlock:(void (^)(void))okBlock;

- (id)initWithTitle:(NSString *)title message:(NSString *)message dismissTitle:(NSString *)dismissTitle dismissBlock:(void (^)(void))dismissBlock;
+ (id)alertWithTitle:(NSString *)title message:(NSString *)message dismissTitle:(NSString *)dismissTitle dismissBlock:(void (^)(void))dismissBlock;
+ (void)showAlertWithTitle:(NSString *)title message:(NSString *)message dismissTitle:(NSString *)dismissTitle dismissBlock:(void (^)(void))dismissBlock;

+ (void)showDismissWithTitle:(NSString *)title message:(NSString *)message dismissBlock:(void (^)(void))dismissBlock;

@end





#import <Foundation/Foundation.h>


@interface YMLCoreTextLabel : UIControl {
	UIColor *_textColor;
	
	NSString *_text;
	NSMutableAttributedString *_attrStr;
	
	NSMutableArray *_boldRanges;
	NSMutableArray *_italicRanges;
	NSMutableArray *_fontRanges;
	NSMutableArray *_underlineRanges;
}

@property (nonatomic, retain) NSString *text;
@property (nonatomic, retain) UIColor *textColor;
@property (nonatomic, retain) UIFont *font;
@property (nonatomic, readonly) float measuredHeight;

@end



#import <UIKit/UIKit.h>

@protocol YMLHTMLLabelLinkClicked 

@optional 
-(void) webLinkClicked:(NSURL*)URL;
@end



#import <Foundation/Foundation.h>

@interface UIColor (Hex)

+ (UIColor *)colorWith256Red:(NSInteger)r green:(NSInteger)g blue:(NSInteger)b;
+ (UIColor *)colorWith256Red:(NSInteger)r green:(NSInteger)g blue:(NSInteger)b alpha:(NSInteger)a;

/*usage
 RGBA style hex value
 UIColor *solidColor = [UIColor colorWithRGBA:0xFF0000FF];
 UIColor *alphaColor = [UIColor colorWithRGBA:0xFF000099];
 */
+ (UIColor *) colorWithRGBA:(uint) hex;

/*usage
 ARGB style hex value
 UIColor *alphaColor = [UIColor colorWithHex:0x99FF0000];
 */
+ (UIColor *) colorWithARGB:(uint) hex;

/*usage
 RGB style hex value, alpha set to full
 UIColor *solidColor = [UIColor colorWithHex:0xFF0000];
 */
+ (UIColor *) colorWithRGB:(uint) hex;

/*usage 
 UIColor *solidColor = [UIColor colorWithWeb:@"#FF0000"];
 safe to omit # sign as well
 UIColor *solidColor = [UIColor colorWithWeb:@"FF0000"];
 */
+ (UIColor *)colorWithHexString:(NSString *)hexString;

- (NSString *) hexString;

- (UIColor*) colorBrighterByPercent:(float) percent;
- (UIColor*) colorDarkerByPercent:(float) percent;

@property (nonatomic, readonly) CGFloat r;
@property (nonatomic, readonly) CGFloat g;
@property (nonatomic, readonly) CGFloat b;
@property (nonatomic, readonly) CGFloat a;

@end



@class AppDelegate;

@interface NSObject (NSObjectCategory)

- (UIFont *) fontWithSize:(CGFloat) size;
- (UIFont *) boldFontWithSize:(CGFloat) size;
- (NSString *) shortMonthNameForMonthNumber:(int)month;
- (NSString *) monthNameForMonthNumber:(int)month;
- (NSString *) convertDateString:(NSString *)dateString fromFormat:(NSString *)fromFormat toFormat:(NSString *)toFormat;
- (NSString *) convertDateToString:(NSDate *)date toFormat:(NSString *)toFormat;
- (NSDate *) addDays:(int)numberOfDays withDate:(NSDate *)date;
- (NSString *) addDays:(int)numberOfDays withDate:(NSDate *)date returnFormat:(NSString *)toFormat;
- (NSDate *) dateFromString:(NSString *)dateString fromFormat:(NSString *)fromFormat;
- (NSMutableDictionary *) splitName:(NSString *)nameToSplit;
- (NSMutableArray *) filterFromRelation:(NSString *)_relation gender:(NSString *)gender;

- (AppDelegate *)appDelegate;

- (BOOL) isFirstLaunch;
- (BOOL) isNull;

@end


@interface NSString (NSStringCategory)

- (BOOL) isEmpty;

@end


@interface UIView(Extended) 

- (UIImage *) imageByRenderingView;
- (UIImage *) imageByRenderAndFlipView;

@end


@interface UIViewController (Extended)

- (void) dismissViewController;

@end

