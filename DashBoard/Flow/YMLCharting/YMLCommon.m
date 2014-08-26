//
//  YMLCommon.m

//
//  Created by vivek Rajanna on 05/04/12.
//  Copyright (c) 2012 YMedia Labs. All rights reserved.
//

#import "YMLCommon.h"
#import <MessageUI/MessageUI.h>
#import <CoreLocation/CoreLocation.h>

static const NSString *IS_FIRST_LAUNCH_KEY = @"FirstLaunch";

@interface YMLAlertView()

@property(nonatomic, copy) okCallback_ okCallback;
@property(nonatomic,copy) dismissCallback_ dissCallback;


@end


@implementation YMLAlertView

@synthesize okCallback;
@synthesize dissCallback;

+ (void)showAlertWithTitle:(NSString *)title message:(NSString *)message dismissTitle:(NSString *)dismissTitle okTitle:(NSString *)okTitle dismissBlock:(void (^)(void))dismissBlock okBlock:(void (^)(void))okBlock {
    [[YMLAlertView alertWithTitle:title message:message dismissTitle:dismissTitle okTitle:okTitle dismissBlock:dismissBlock okBlock:okBlock] show];
}

+ (id)alertWithTitle:(NSString *)title message:(NSString *)message dismissTitle:(NSString *)dismissTitle okTitle:(NSString *)okTitle dismissBlock:(void (^)(void))dismissBlock okBlock:(void (^)(void))okBlock {
    return [[YMLAlertView alloc] initWithTitle:title message:message dismissTitle:dismissTitle okTitle:okTitle dismissBlock:dismissBlock okBlock:okBlock];
}

+ (void)showDismissWithTitle:(NSString *)title message:(NSString *)message dismissBlock:(void (^)(void))dismissBlock {
    [[YMLAlertView alertWithTitle:title message:message dismissTitle:NSLocalizedString(@"Dismiss", nil) okTitle:nil dismissBlock:dismissBlock okBlock:nil] show];
}

- (id)initWithTitle:(NSString *)title message:(NSString *)message dismissTitle:(NSString *)dismissTitle okTitle:(NSString *)okTitle dismissBlock:(void (^)(void))dismissBlock okBlock:(void (^)(void))okBlock {
    self = [super initWithTitle:title message:message delegate:self cancelButtonTitle:dismissTitle otherButtonTitles:okTitle, nil];
    
    if (self) {
        self.okCallback = okBlock;
        self.dissCallback = dismissBlock;
//        okCallback_ = Block_copy(okBlock);
//        dismissCallback_ = Block_copy(dismissBlock);
    }
    
    return self;
}

+ (void)showAlertWithTitle:(NSString *)title message:(NSString *)message dismissTitle:(NSString *)dismissTitle dismissBlock:(void (^)(void))dismissBlock {
    [[YMLAlertView alertWithTitle:title message:message dismissTitle:dismissTitle dismissBlock:dismissBlock] show];
}

+ (id)alertWithTitle:(NSString *)title message:(NSString *)message dismissTitle:(NSString *)dismissTitle dismissBlock:(void (^)(void))dismissBlock {
    return [[YMLAlertView alloc] initWithTitle:title message:message dismissTitle:dismissTitle dismissBlock:dismissBlock];    
}

- (id)initWithTitle:(NSString *)title message:(NSString *)message dismissTitle:(NSString *)dismissTitle dismissBlock:(void (^)(void))dismissBlock {
    self = [super initWithTitle:title message:message delegate:self cancelButtonTitle:dismissTitle otherButtonTitles:nil];
    
    if (self) {
        self.dissCallback = dismissBlock;
//        dismissCallback_ = Block_copy(dismissBlock);
    }
    
    return self;
}                                                                                                                                                      

//- (void)dealloc {
//    Block_release(okCallback_);
//    Block_release(dismissCallback_);
//    
//    [super dealloc];
//}


#pragma mark -

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (self.numberOfButtons == 2) {
        if (buttonIndex == 0) {
            if (self.dissCallback) {
                self.dissCallback();
            }
        } else {
            if (self.okCallback) {
                self.okCallback();
            }
        }
    } else {
        if (self.dissCallback) {
            self.dissCallback();
        }
    }
}


@end



const NSInteger MAX_RGB_COLOR_VALUE = 0xff;
const NSInteger MAX_RGB_COLOR_VALUE_FLOAT = 255.0f;

@implementation UIColor (InnerBand)

float RGB256_TO_COL(NSInteger rgb) { return rgb / 255.0f; }

+ (UIColor *)colorWith256Red:(NSInteger)r green:(NSInteger)g blue:(NSInteger)b {
	return [UIColor colorWithRed:RGB256_TO_COL(r) green:RGB256_TO_COL(g) blue:RGB256_TO_COL(b) alpha:1.0];
}

+ (UIColor *)colorWith256Red:(NSInteger)r green:(NSInteger)g blue:(NSInteger)b alpha:(NSInteger)a {
	return [UIColor colorWithRed:RGB256_TO_COL(r) green:RGB256_TO_COL(g) blue:RGB256_TO_COL(b) alpha:RGB256_TO_COL(a)];
}

+ (UIColor *) colorWithRGBA:(uint) hex {
	return [UIColor colorWithRed:(CGFloat)((hex>>24) & MAX_RGB_COLOR_VALUE) / MAX_RGB_COLOR_VALUE_FLOAT 
						   green:(CGFloat)((hex>>16) & MAX_RGB_COLOR_VALUE) / MAX_RGB_COLOR_VALUE_FLOAT 
							blue:(CGFloat)((hex>>8) & MAX_RGB_COLOR_VALUE) / MAX_RGB_COLOR_VALUE_FLOAT 
						   alpha:(CGFloat)((hex) & MAX_RGB_COLOR_VALUE) / MAX_RGB_COLOR_VALUE_FLOAT];
}

+ (UIColor *) colorWithARGB:(uint) hex {
	return [UIColor colorWithRed:(CGFloat)((hex>>16) & MAX_RGB_COLOR_VALUE) / MAX_RGB_COLOR_VALUE_FLOAT 
						   green:(CGFloat)((hex>>8) & MAX_RGB_COLOR_VALUE) / MAX_RGB_COLOR_VALUE_FLOAT 
							blue:(CGFloat)(hex & MAX_RGB_COLOR_VALUE) / MAX_RGB_COLOR_VALUE_FLOAT 
						   alpha:(CGFloat)((hex>>24) & MAX_RGB_COLOR_VALUE) / MAX_RGB_COLOR_VALUE_FLOAT];
}

+ (UIColor *) colorWithRGB:(uint) hex {
	return [UIColor colorWithRed:(CGFloat)((hex>>16) & MAX_RGB_COLOR_VALUE) / MAX_RGB_COLOR_VALUE_FLOAT 
						   green:(CGFloat)((hex>>8) & MAX_RGB_COLOR_VALUE) / MAX_RGB_COLOR_VALUE_FLOAT 
							blue:(CGFloat)(hex & MAX_RGB_COLOR_VALUE) / MAX_RGB_COLOR_VALUE_FLOAT 
						   alpha:1.0];
}

+ (UIColor *)colorWithHexString:(NSString *)hexString {
	uint hex;
	
	// chop off hash
	if ([hexString characterAtIndex:0] == '#') {
		hexString = [hexString substringFromIndex:1];
	}
	
	// depending on character count, generate a color
	NSInteger hexStringLength = hexString.length;
	
	if (hexStringLength == 3) {
		// RGB, once character each (each should be repeated)
		hexString = [NSString stringWithFormat:@"%c%c%c%c%c%c", [hexString characterAtIndex:0], [hexString characterAtIndex:0], [hexString characterAtIndex:1], [hexString characterAtIndex:1], [hexString characterAtIndex:2], [hexString characterAtIndex:2]];
		hex = strtoul([hexString UTF8String], NULL, 16);	
        
		return [self colorWithRGB:hex];
	} else if (hexStringLength == 4) {
		// RGBA, once character each (each should be repeated)
		hexString = [NSString stringWithFormat:@"%c%c%c%c%c%c%c%c", [hexString characterAtIndex:0], [hexString characterAtIndex:0], [hexString characterAtIndex:1], [hexString characterAtIndex:1], [hexString characterAtIndex:2], [hexString characterAtIndex:2], [hexString characterAtIndex:3], [hexString characterAtIndex:3]];
		hex = strtoul([hexString UTF8String], NULL, 16);		
        
		return [self colorWithRGBA:hex];
	} else if (hexStringLength == 6) {
		// RGB
		hex = strtoul([hexString UTF8String], NULL, 16);		
		
		return [self colorWithRGB:hex];
	} else if (hexStringLength == 8) {
		// RGBA
		hex = strtoul([hexString UTF8String], NULL, 16);		
        
		return [self colorWithRGBA:hex];
	}
	
	// illegal
	[NSException raise:@"Invalid Hex String" format:@"Hex string invalid: %@", hexString];
	
	return nil;
}

- (NSString *) hexString {
	const CGFloat *components = CGColorGetComponents(self.CGColor);
	
	NSInteger red = (int)(components[0] * MAX_RGB_COLOR_VALUE);
	NSInteger green = (int)(components[1] * MAX_RGB_COLOR_VALUE);
	NSInteger blue = (int)(components[2] * MAX_RGB_COLOR_VALUE);
	NSInteger alpha = (int)(components[3] * MAX_RGB_COLOR_VALUE);
	
	if (alpha < 255) {
		return [NSString stringWithFormat:@"#%02x%02x%02x%02x", red, green, blue, alpha];
	}
	
	return [NSString stringWithFormat:@"#%02x%02x%02x", red, green, blue];
}

- (UIColor*) colorBrighterByPercent:(float) percent {
	percent = MAX(percent, 0.0f);
	percent = (percent + 100.0f) / 100.0f;
	const CGFloat* rgba = CGColorGetComponents(self.CGColor);
	CGFloat r = rgba[0];
	CGFloat g = rgba[1];
	CGFloat b = rgba[2];
	CGFloat a = rgba[3];
	CGFloat newR = r * percent;
	CGFloat newG = g * percent;
	CGFloat newB = b * percent;
	return [UIColor colorWithRed:newR green:newG blue:newB alpha:a];
}

- (UIColor*) colorDarkerByPercent:(float) percent {
	percent = MAX(percent, 0.0f);
	percent /= 100.0f;
	const CGFloat* rgba = CGColorGetComponents(self.CGColor);
	CGFloat r = rgba[0];
	CGFloat g = rgba[1];
	CGFloat b = rgba[2];
	CGFloat a = rgba[3];
	CGFloat newR = r - (r * percent);
	CGFloat newG = g - (g * percent);
	CGFloat newB = b - (b * percent);
	return [UIColor colorWithRed:newR green:newG blue:newB alpha:a];
}

- (CGFloat)r {
	const CGFloat* rgba = CGColorGetComponents(self.CGColor);
	return rgba[0];
}

- (CGFloat)g {
	const CGFloat* rgba = CGColorGetComponents(self.CGColor);
	return rgba[1];
}

- (CGFloat)b {
	const CGFloat* rgba = CGColorGetComponents(self.CGColor);
	return rgba[2];
}

- (CGFloat)a {
	const CGFloat* rgba = CGColorGetComponents(self.CGColor);
	return rgba[3];
}

@end




#import <CoreText/CoreText.h>
#import "YMLCommon.h"

@interface YMLCoreTextLabel (PRIVATE)

- (NSString *)catalogTagsInText;
- (NSMutableAttributedString *)createAttributesStringFromCatalog:(NSString *)str;
- (NSMutableAttributedString *)createMutableAttributedStringFromText;

@end




//NSString *DOCUMENTS_DIR(void) { return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]; }
//
//
//BOOL IS_IPAD(void) {
//    return [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad;
//}
//
//BOOL IS_IPHONE(void) {
//    return [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone;
//}
//
//
//BOOL IS_OBJ_NILL_OR_NULL(id obj){
//        if (obj == nil || [obj isKindOfClass:[NSNull class]]) 
//        {
//            return TRUE;
//        }
//        else
//        {
//            return FALSE;
//        }
//
//}
//
//
//
//BOOL IS_CAMERA_AVAILABLE(void) {
//    return [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
//}
//
//
//BOOL IS_EMAIL_ACCOUNT_AVAILABLE(void) {
//    return [MFMailComposeViewController canSendMail];
//}
//
//BOOL IS_GPS_ENABLED(void) {
//    return IS_GPS_ENABLED_ON_DEVICE();
//}
//
//BOOL IS_GPS_ENABLED_ON_DEVICE(void) {
//    BOOL isLocationServicesEnabled;
//    
//    Class locationClass = NSClassFromString(@"CLLocationManager");
//    NSMethodSignature *signature = [locationClass instanceMethodSignatureForSelector:@selector(locationServicesEnabled)];
//    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
//    
//    [invocation invoke];
//    [invocation getReturnValue:&isLocationServicesEnabled];
//    
//    return locationClass && isLocationServicesEnabled;    
//}
//
//BOOL IS_EMAIL_ADDRESS(NSString* astring)
//{
//    BOOL stricterFilter = YES; 
//    NSString *stricterFilterString = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
//    NSString *laxString = @".+@.+\\.[A-Za-z]{2}[A-Za-z]*";
//    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
//    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
//    return [emailTest evaluateWithObject:astring];
//    
//    
//}
//
//int SCREEN_SCALE(void)
//{
//    return [UIScreen mainScreen].scale;
//}
//
//
//
//NSString* URL_STRING_FOR_IMAGESIZE(int width, int height)
//{
//    int scale = SCREEN_SCALE();
//
//    return [NSString stringWithFormat:@"width/%i/height/%i",width*scale,height*scale];
//
//}
//
//NSString* URL_ENCODED_STRING(NSString* aString)
//{
//
//    NSString * encodedString = (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,
//                                                                                       (__bridge CFStringRef)aString,
//                                                                                       NULL,
//                                                                                       (CFStringRef)@"!*'();:@&=+$,/?%#[]",
//                                                                                       kCFStringEncodingUTF8 );
//        
//        
//    return encodedString;
//
//}
//
//
//BOOL IS_CONTAIN_EMAIL_ADDRESS(NSString* astring){
//    NSArray *words = [astring componentsSeparatedByString:@" "];
//	for (NSString *str in words) {
//		if (IS_EMAIL_ADDRESS(str)) {
//			return YES;
//		}
//	}
//	return NO;
//    
//}
//BOOL IS_PHONE_NUMBER(NSString* astring)
//{
//	NSString *phoneNumberRegExc = @"[0-9]{10,11}";
//	
//	NSPredicate *regExPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", phoneNumberRegExc];
//	return [regExPredicate evaluateWithObject:astring];
//}
//
//BOOL IS_CONTAIN_PHONE_NUMBER(NSString* astring)
//{
//    NSArray *words = [astring componentsSeparatedByString:@" "];
//	for (NSString *str in words) {
//		if (IS_PHONE_NUMBER(str)) {
//			return YES;
//		}
//	}
//	return NO;
//    
//}
//BOOL IS_URL_LINK(NSString* aString)
//{
//	NSString *urlRegExc = @"(([http:]+[/]+[/]|www.)([a-z]|[A-Z]|[0-9]|[/.]|[~])*)";
//	
//	NSPredicate *regExPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", urlRegExc];
//	return [regExPredicate evaluateWithObject:aString];
//}
//
//BOOL IS_CONTAIN_URL_LINK(NSString* aString){
//    
//	NSArray *words = [aString componentsSeparatedByString:@" "];
//	for (NSString *str in words) {
//		if (IS_URL_LINK(str)) {
//			return YES;
//		}
//	}
//	return NO;
//    
//}
//
//BOOL IS_EMPTY_STRING(NSString *str) { return !str || ![str isKindOfClass:NSString.class] || [str length] == 0; }
//
//BOOL IS_POPULATED_STRING(NSString *str) { return str && [str isKindOfClass:NSString.class] && [str length] > 0; }
//
//
//
//UIImage *IMAGE(NSString *x) { return [UIImage imageNamed:x]; }




#import <QuartzCore/QuartzCore.h>
UIImage *SCREEN_SHOT(CGRect rect ,UIView *view) {
    UIGraphicsBeginImageContext(CGSizeMake(rect.size.width, rect.size.height));
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    CGContextTranslateCTM(context,rect.origin.x,rect.origin.y);
    [view.layer renderInContext:context];
    CGContextRestoreGState(context);
    UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resultingImage;
}

NSInteger COL_TO_RGB256(float col) { return (NSInteger)(col * 255.0); }



@implementation NSObject (NSObjectCategory)

/*
 This project uses the DIN-Medium font everywhere. So the font is added to the project (see inside Font
 Folder). Then this font is also added to the info.plist, so we can use it.
 
 Ex : [self fontWithSize:12.0f];     //Return a font(Din-Medium) with size 12px
 */
- (UIFont *) fontWithSize:(CGFloat) size {
    return [UIFont fontWithName:@"Helvetica" size:size];
}

- (UIFont *) boldFontWithSize:(CGFloat) size {    
    return [UIFont fontWithName:@"Helvetica-Bold" size:size];
}


/* Return the app delegate*/
- (AppDelegate *)appDelegate {
    return (AppDelegate *) [[UIApplication sharedApplication] delegate];
}

- (BOOL) isFirstLaunch {    
    return [[[NSUserDefaults standardUserDefaults] objectForKey:IS_FIRST_LAUNCH_KEY] boolValue];
}

- (NSString *) shortMonthNameForMonthNumber:(int)monthNumber {
    NSString *month = @"Jan";
    
    switch (monthNumber) {
        case 1:
            month = @"Jan";
            break;
            
        case 2:
            month = @"Feb";
            break;
            
        case 3:
            month = @"Mar";
            break;
            
        case 4:
            month = @"Apr";
            break;
            
        case 5:
            month = @"May";
            break;
            
        case 6:
            month = @"Jun";
            break;
            
        case 7:
            month = @"Jul";
            break;
            
        case 8:
            month = @"Aug";
            break;
            
        case 9:
            month = @"Sep";
            break;
            
        case 10:
            month = @"Oct";
            break;
            
        case 11:
            month = @"Nov";
            break;
            
        case 12:
            month = @"Dec";
            break;
            
        default:
            month = @"Jan";
            break;
    }
    
    return month;
}

- (NSString *) monthNameForMonthNumber:(int)monthNumber {
    NSString *month = @"January";
    
    switch (monthNumber) {
        case 1:
            month = @"January";
            break;
            
        case 2:
            month = @"February";
            break;
            
        case 3:
            month = @"March";
            break;
            
        case 4:
            month = @"April";
            break;
            
        case 5:
            month = @"May";
            break;
            
        case 6:
            month = @"June";
            break;
            
        case 7:
            month = @"July";
            break;
            
        case 8:
            month = @"August";
            break;
            
        case 9:
            month = @"September";
            break;
            
        case 10:
            month = @"October";
            break;
            
        case 11:
            month = @"November";
            break;
            
        case 12:
            month = @"December";
            break;
            
        default:
            month = @"January";
            break;
    }
    
    return month;
}

- (NSString *) convertDateString:(NSString *)dateString fromFormat:(NSString *)fromFormat toFormat:(NSString *)toFormat {
    NSString *returnDate = @"";
    
    if ([[dateString substringWithRange:NSMakeRange(0, 4)] isEqualToString:@"0000"]) {
        NSString *year = [self convertDateToString:[NSDate date] toFormat:@"yyyy"];
        dateString = [dateString stringByReplacingOccurrencesOfString:@"0000" withString:year options:NSCaseInsensitiveSearch range:NSMakeRange(0, 4)];
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat:fromFormat];
    NSDate *date = [dateFormatter dateFromString:dateString];
    
    [dateFormatter setDateFormat:toFormat];
    returnDate = [dateFormatter stringFromDate:date];
    
//    SAFE_RELEASE(dateFormatter);
    
    if (returnDate == nil || [returnDate isEmpty]) {
        returnDate = @"";
    }
        
    return returnDate;
}

- (NSString *) convertDateToString:(NSDate *)date toFormat:(NSString *)toFormat {
    NSString *returnDate = @"";
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:toFormat];
    returnDate = [dateFormatter stringFromDate:date];
//    SAFE_RELEASE(dateFormatter);
    
    return returnDate;
}

- (NSDate *) addDays:(int)numberOfDays withDate:(NSDate *)date {
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    [dateComponents setDay:numberOfDays];
    
    NSDate *newDate = [[NSCalendar currentCalendar] dateByAddingComponents:dateComponents toDate:date options:0];
//    SAFE_RELEASE(dateComponents);
    
    return newDate;
}

- (NSString *) addDays:(int)numberOfDays withDate:(NSDate *)date returnFormat:(NSString *)toFormat {
    NSDate *newDate = [self addDays:numberOfDays withDate:date];
    
    return [self convertDateToString:newDate toFormat:toFormat];
}

- (NSDate *) dateFromString:(NSString *)dateString fromFormat:(NSString *)fromFormat {
    NSDate *returnDate;
    
    if ([[dateString substringWithRange:NSMakeRange(0, 4)] isEqualToString:@"0000"]) {
        NSString *year = [self convertDateToString:[NSDate date] toFormat:@"yyyy"];
        dateString = [dateString stringByReplacingOccurrencesOfString:@"0000" withString:year options:NSCaseInsensitiveSearch range:NSMakeRange(0, 4)];
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:fromFormat];
    returnDate = [dateFormatter dateFromString:dateString];
//    SAFE_RELEASE(dateFormatter);
    
    return returnDate;
}

- (BOOL) isNull {
    if ([self isKindOfClass:NSClassFromString(@"NSNull")]) {
        return YES;
    }
    
    return NO;
}

- (NSMutableDictionary *) splitName:(NSString *)nameToSplit {
    NSMutableString *fullName = [NSMutableString stringWithString:[nameToSplit stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
    
    NSMutableDictionary *name = [[NSMutableDictionary alloc] init];
    [name setObject:@"" forKey:@"honorificPrefix"];
    [name setObject:@"" forKey:@"givenName"];
    [name setObject:@"" forKey:@"middleName"];
    [name setObject:@"" forKey:@"familyName"];
    [name setObject:@"" forKey:@"honorificSuffix"];
    
    NSArray *prefixs = [NSArray arrayWithObjects:@"mr", @"dr", @"ms", @"miss", @"mrs", @"mstr", @"prof", @"phd", @"capt", @"lt", @"rev", @"atty", @"sir", nil];
    NSArray *suffixs = [NSArray arrayWithObjects:@"sr", @"jr", @"i", @"ii", @"iii", @"iv", @"v", @"prof", @"phd", @"capt", @"lt", @"dds", @"rev", @"md", @"do", @"dc", @"atty", @"esq", nil];
    NSArray *joiningWords = [NSArray arrayWithObjects:@"and", @"&", @"or", nil];
    
    NSMutableArray *nameParts = [[NSMutableArray alloc] init];
    
    [fullName replaceOccurrencesOfString:@"  " withString:@" " options:NSCaseInsensitiveSearch range:NSMakeRange(0, [fullName length])];
    
    if ([fullName length] == 0) {
        return name;
    }
    
    
    NSArray *inputNameParts = [fullName componentsSeparatedByString:@" "];
    int inputNamePartsLen = [inputNameParts count];
    NSMutableArray *namePartsForComparison = [[[fullName lowercaseString] componentsSeparatedByString:@" "] mutableCopy];
    
    for (int i = 0; i < [namePartsForComparison count]; i++) {
        NSMutableString *np = [NSMutableString stringWithString:[namePartsForComparison objectAtIndex:i]];
        [np replaceOccurrencesOfString:@"," withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [np length])];
        [np replaceOccurrencesOfString:@"." withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [np length])];
        [namePartsForComparison replaceObjectAtIndex:i withObject:np];
    }
    
    
    for (int i = 0; i < inputNamePartsLen; i++) {
        if ([inputNameParts count] >= (i + 1) && [inputNameParts count] >= (i + 2) && [joiningWords containsObject:[namePartsForComparison objectAtIndex:(i + 1)]]) {
			[nameParts addObject:[NSString stringWithFormat:@"%@ %@ %@", [inputNameParts objectAtIndex:i], [inputNameParts objectAtIndex:(i + 1)], [inputNameParts objectAtIndex:(i + 2)]]];
			i += 2;
		} else {
			[nameParts addObject:[inputNameParts objectAtIndex:i]];
		}
    }
    
    
    int firstWord = 0;
    int lastWord = 0;
    NSMutableString *middleName = [NSMutableString stringWithString:[name objectForKey:@"middleName"]];
    
    switch([nameParts count]) {
		case 1:
			[name setObject:[nameParts objectAtIndex:0] forKey:@"givenName"];
			break;
            
		case 2:
			if ([suffixs containsObject:[namePartsForComparison objectAtIndex:1]]) {
                [name setObject:[nameParts objectAtIndex:1] forKey:@"honorificSuffix"];
                [name setObject:[nameParts objectAtIndex:0] forKey:@"familyName"];
			} 
            else if ([prefixs containsObject:[namePartsForComparison objectAtIndex:0]]) {
                [name setObject:[nameParts objectAtIndex:0] forKey:@"honorificPrefix"];
                [name setObject:[nameParts objectAtIndex:1] forKey:@"familyName"];
			} 
            else {
                [name setObject:[nameParts objectAtIndex:0] forKey:@"givenName"];
                [name setObject:[nameParts objectAtIndex:1] forKey:@"familyName"];
			}
			break;
            
		default:
			firstWord = 0;
			lastWord = [nameParts count] - 1;
            
			if ([prefixs containsObject:[namePartsForComparison objectAtIndex:firstWord]] && [suffixs containsObject:[namePartsForComparison objectAtIndex:lastWord]]) {
                [name setObject:[nameParts objectAtIndex:firstWord] forKey:@"honorificPrefix"];
                
				if (lastWord > 2) {
                    [name setObject:[nameParts objectAtIndex:(firstWord + 1)] forKey:@"givenName"];
				}
				if (lastWord > 3) {
					for (int m = (firstWord + 2); m < (lastWord - 1); m++) {
                        [middleName appendFormat:@"%@ ", [nameParts objectAtIndex:m]];
					}
                    
                    [name setObject:middleName forKey:@"middleName"];
				}
                
                [name setObject:[nameParts objectAtIndex:(lastWord - 1)] forKey:@"familyName"];
                [name setObject:[nameParts objectAtIndex:lastWord] forKey:@"honorificSuffix"];
			} 
            else if ([prefixs containsObject:[namePartsForComparison objectAtIndex:firstWord]]) {
                [name setObject:[nameParts objectAtIndex:firstWord] forKey:@"honorificPrefix"];
                [name setObject:[nameParts objectAtIndex:(firstWord + 1)] forKey:@"givenName"];
                
                
                for (int m = 2; m < lastWord; m++) {
                    [middleName appendFormat:@"%@ ", [nameParts objectAtIndex:m]];
                }
                
                [name setObject:middleName forKey:@"middleName"];
                
                [name setObject:[nameParts objectAtIndex:lastWord] forKey:@"familyName"];
			} 
            else if ([suffixs containsObject:[namePartsForComparison objectAtIndex:lastWord]]) {
                [name setObject:[nameParts objectAtIndex:firstWord] forKey:@"givenName"];
                
                for (int m = 1; m < (lastWord - 1); m++) {
                    [middleName appendFormat:@"%@ ", [nameParts objectAtIndex:m]];
                }
                
                [name setObject:middleName forKey:@"middleName"];
                
                [name setObject:[nameParts objectAtIndex:(lastWord - 1)] forKey:@"familyName"];
                [name setObject:[nameParts objectAtIndex:lastWord] forKey:@"honorificSuffix"];
			} 
            else {
                [name setObject:[nameParts objectAtIndex:firstWord] forKey:@"givenName"];
                
                for (int m = 1; m < lastWord; m++) {
                    [middleName appendFormat:@"%@ ", [nameParts objectAtIndex:m]];
                }
                
                [name setObject:middleName forKey:@"middleName"];
                
                [name setObject:[nameParts objectAtIndex:lastWord] forKey:@"familyName"];
			}
			break;
	}
    
    if (middleName != nil && ![middleName isEmpty]) {
        [middleName replaceOccurrencesOfString:@" " withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, 1)];
        [name setObject:middleName forKey:@"middleName"];
    }
    
//    SAFE_RELEASE(nameParts);
//    SAFE_RELEASE(namePartsForComparison);
    
    return name;
}

- (NSMutableArray *) filterFromRelation:(NSString *)_relation gender:(NSString *)gender {
    NSMutableArray *filters = [[NSMutableArray alloc] init];
    
    if (_relation == nil || [_relation isEmpty]) {
        if ([[gender lowercaseString] isEqualToString:@"f"] || [[gender lowercaseString] rangeOfString:@"female"].location != NSNotFound) {
            [filters addObject:@"for her"];
        }
        else if ([[gender lowercaseString] isEqualToString:@"m"] || [[gender lowercaseString] rangeOfString:@"male"].location != NSNotFound) {
            [filters addObject:@"for him"];
        }
        else {
            [filters addObject:@"funny"];
            [filters addObject:@"friend"];
        }
    }
    else {        
        NSMutableString *relation = [NSMutableString stringWithString:_relation];
        
        if ([relation rangeOfString:@"female" options:NSCaseInsensitiveSearch].location != NSNotFound) {
            [filters addObject:@"for her"];
        }
        else if ([relation rangeOfString:@"male" options:NSCaseInsensitiveSearch].location != NSNotFound) {
            [filters addObject:@"for him"];
        }
        else {
            [relation replaceOccurrencesOfString:@"(female)" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, ([relation length]))];
            [relation replaceOccurrencesOfString:@"(male)" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, ([relation length]))];
            [relation replaceOccurrencesOfString:@" " withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, ([relation length]))];
            [filters addObject:relation];
        }
    }
    
    return filters;
}

@end



@implementation NSString (NSStringCategory)

- (BOOL) isEmpty {
    if ([self isNull] || [[self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] == 0) {
        return YES;
    }
    
    return NO;
}

@end



@implementation UIView(Extended)

- (UIImage *) imageByRenderingView {
	CGFloat oldAlpha = self.alpha;
    BOOL previousHiddenState = [self isHidden];
    	
	self.alpha = 1;
    [self setHidden:NO];
    
	UIGraphicsBeginImageContext(self.bounds.size);
	[self.layer renderInContext:UIGraphicsGetCurrentContext()];
	UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
    
    [self setHidden:previousHiddenState];
	self.alpha = oldAlpha;
	
	return resultingImage;
}

- (UIImage *) imageByRenderAndFlipView {
    CGFloat oldAlpha = self.alpha;
    BOOL previousHiddenState = [self isHidden];
    
	self.alpha = 1;
    [self setHidden:NO];
	
    
    UIGraphicsBeginImageContext(self.bounds.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGAffineTransform flipVertical = CGAffineTransformMake(1, 0, 0, -1, 0, self.frame.size.height);
    CGContextConcatCTM(context, flipVertical);  
    [self.layer renderInContext:context];
    
	[self.layer renderInContext:UIGraphicsGetCurrentContext()];
	UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
    
	[self setHidden:previousHiddenState];
	self.alpha = oldAlpha;
	
	return resultingImage;
}

@end



@implementation UIViewController (Extended)

- (void) dismissViewController {
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end

