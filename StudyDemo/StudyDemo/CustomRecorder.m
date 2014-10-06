//
//  PurpleRecorder.m
//  StudyDemo
//
//  Copyright (c) 2014 Apple. All rights reserved.
//

#import "CustomRecorder.h"

@interface CustomRecorder ()

@property (nonatomic, strong) UIView* containerView;
@property (nonatomic, strong) UIButton* button;
@property (nonatomic, strong) NSTimer* timer;
@property (nonatomic, strong) NSMutableArray* records;

@end

@implementation CustomRecorder

- (void)viewController:(UIViewController*)viewController willStartStepWithView:(UIView*)view{
    [super viewController:viewController willStartStepWithView:view];
    self.containerView = view;
}

- (BOOL)start:(NSError *__autoreleasing *)error{
    BOOL ret = [super start:error];
    
    NSAssert(self.containerView != nil, @"No container view attached.");
    
    if (_button) {
        [_button removeFromSuperview];
    }
    
    _button = [UIButton buttonWithType:UIButtonTypeSystem];
    [_button setTitle:@"Tap here" forState:UIControlStateNormal];
    _button.frame = CGRectInset(_containerView.bounds, 10, 10);
    _button.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleHeight;
    _button.backgroundColor = [UIColor orangeColor];
    _button.hidden = YES;
    [_button addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchDown];
    [_containerView addSubview:_button];
    
    _records = [NSMutableArray array];
    
    [self.timer invalidate];
    
    double delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerFired:) userInfo:nil repeats:YES];
    });
    
    return ret;
}


- (IBAction)timerFired:(id)sender{
    _button.hidden = !_button.hidden;
    
    NSDictionary* dictionary = @{@"event": _button.hidden? @"buttonHide": @"buttonShow",
                                 @"time": @([[NSDate date] timeIntervalSinceReferenceDate])};
    
    [_records addObject:dictionary];
    
}

- (IBAction)buttonTapped:(id)sender{
    NSDictionary* dictionary = @{@"event": @"userTouchDown",
                                 @"time": @([[NSDate date] timeIntervalSinceReferenceDate])};
    
    [_records addObject:dictionary];
    
}

- (BOOL)stop:(NSError *__autoreleasing *)error{
    BOOL ret = [super stop:error];
    
    [self.timer invalidate];
    [_button removeFromSuperview];
    _button = nil;
    
    if (self.records) {
        
        NSLog(@"%@", self.records);
        
        id<RKRecorderDelegate> localDelegate = self.delegate;
        if (localDelegate && [localDelegate respondsToSelector:@selector(recorder:didCompleteWithResult:)]) {
            RKDataResult* result = [[RKDataResult alloc] initWithStep:self.step];
            result.contentType = [self mimeType];
            NSError* err;
            result.data = [NSJSONSerialization dataWithJSONObject:self.records options:(NSJSONWritingOptions)0 error:&err];
            
            if (err) {
                if (error) {
                    *error = err;
                }
                return NO;
            }
            
            result.filename = self.fileName;
            [localDelegate recorder:self didCompleteWithResult:result];
            self.records = nil;
        }
    }else{
        if (error) {
            *error = [NSError errorWithDomain:RKErrorDomain
                                         code:RKErrorObjectNotFound
                                     userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"Records object is nil.", nil)}];
        }
        ret = NO;
    }
    
    
    return ret;
}

- (NSString*)dataType{
    return @"tapTheButton";
}

- (NSString*)mimeType{
    return @"application/json";
}

- (NSString*)fileName{
    return @"tapTheButton.json";
}

@end

@implementation CustomRecorderConfiguration

- (RKRecorder*)recorderForStep:(RKStep*)step taskInstanceUUID:(NSUUID*)taskInstanceUUID{
    return [[CustomRecorder alloc] initWithStep:step taskInstanceUUID:taskInstanceUUID];
}

#pragma mark - RKSerialization

- (instancetype)initWithDictionary:(NSDictionary *)dictionary{
    
    self = [self init];
    if (self) {
        
    }
    return self;
}

- (NSDictionary*)dictionaryValue{
    
    NSMutableDictionary* dict = [NSMutableDictionary new];
    
    dict[@"_class"] = NSStringFromClass([self class]);
    
    return dict;
}

@end

