//
//  AppearanceControlViewController.m
//
//  Copyright (c) 2014 Apple. All rights reserved.
//

#import "AppearanceControlViewController.h"
#import <ResearchKit/ResearchKit_Private.h>

@interface AppearanceControlViewController ()

@property (nonatomic, strong) NSArray* classes;

@end

@implementation AppearanceControlViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"Appearance status";
    
    _classes =  @[[RKSTHeadlineLabel class],
                 [RKSTSubheadlineLabel class],
                 [RKSTCaption1Label class],
                 [RKSTCaption2Label class],
                 [RKSTSelectionTitleLabel class],
                 [RKSTSelectionSubTitleLabel class],
                 [RKSTScaleRangeLabel class],
                 [RKSTScaleValueLabel class],
                 [RKSTPickerLabel class],
                 [RKSTAnswerTextField class],
                 [RKSTAnswerTextView class],
                 [RKSTTextButton class],
                 [RKSTBoldTextCell class],
                 [RKSTRegularTextCell class],
                 [RKSTCountdownLabel class]];
    
    self.tableView.allowsSelection = NO;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(cancel)];
}

- (IBAction)cancel{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)switchUpdated:(UISwitch*)switchControl{
     Class class = _classes[switchControl.tag];
    
    
    switchControl.enabled = !switchControl.isOn;
    
    UIFont* font = [UIFont italicSystemFontOfSize:10];
    
    if ([class isSubclassOfClass:[RKSTLabel class]] || [class isSubclassOfClass:[UITableViewCell class]]) {
        
        if (switchControl.isOn) {
            [[class appearance] setLabelFont:font];
        }else{
            [[class appearance] setLabelFont:nil];
        }
        
    }else if ([class isSubclassOfClass:[UITextField class]] || [class isSubclassOfClass:[UITextView class]]) {
        
        if (switchControl.isOn) {
            [[class appearance] setFieldFont:font];
        }else{
            [[class appearance] setFieldFont:nil];
        }
       
    }else if ([class isSubclassOfClass:[UIButton class]]) {
        
        if (switchControl.isOn) {
            [[class appearance] setTitleFont:font];
        }else{
            [[class appearance] setTitleFont:nil];
        }
    }
    
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:switchControl.tag inSection:0]] withRowAnimation:NO];
}

#pragma mark - Table view data source


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return [_classes count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    Class class = _classes[indexPath.row];
    NSString* className = NSStringFromClass(class);
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    UIView* view = [class new];
    view.frame = cell.bounds;
    
    BOOL fontSet = NO;
    if ([class isSubclassOfClass:[RKSTCountdownLabel class]]) {
        fontSet = [[class appearance] labelFont]?YES:NO;
        [(RKSTLabel*)view setTextAlignment:NSTextAlignmentCenter];
    }else if ([class isSubclassOfClass:[RKSTLabel class]]) {
        [(RKSTLabel*)view setText:className];
         [(RKSTLabel*)view setTextAlignment:NSTextAlignmentCenter];
        fontSet = [[class appearance] labelFont]?YES:NO;
    }else if ([class isSubclassOfClass:[UITextField class]]) {
        [(RKSTAnswerTextField*)view setText:className];
        [(RKSTAnswerTextField*)view setTextAlignment:NSTextAlignmentCenter];
        fontSet = [[class appearance] fieldFont]?YES:NO;
    }else if ([class isSubclassOfClass:[UITextView class]]) {
        [(RKSTAnswerTextView*)view setText:className];
        [(RKSTAnswerTextView*)view setTextAlignment:NSTextAlignmentCenter];
        fontSet = [[class appearance] fieldFont]?YES:NO;
    }else if ([class isSubclassOfClass:[RKSTTextButton class]]) {
        view = [RKSTTextButton buttonWithType:UIButtonTypeSystem];
        [(RKSTTextButton*)view setTitle:className forState:UIControlStateNormal];
        fontSet = [[class appearance] titleFont]?YES:NO;
    }else if ([class isSubclassOfClass:[UITableViewCell class]]) {
        [[(UITableViewCell*)view textLabel] setText:className];
        [[(UITableViewCell*)view textLabel] setTextAlignment:NSTextAlignmentCenter];
        fontSet = [[class appearance] labelFont]?YES:NO;
    }
    
    UISwitch* switchControl = [UISwitch new];
    
    switchControl.on = fontSet;
    switchControl.enabled = !switchControl.isOn;
    
    [switchControl addTarget:self action:@selector(switchUpdated:) forControlEvents:UIControlEventValueChanged];
    
    {
        NSDictionary* views = @{@"view": view, @"switch": switchControl};
        
        [views enumerateKeysAndObjectsUsingBlock:^(id key, UIView *obj, BOOL *stop) {
            [obj setTranslatesAutoresizingMaskIntoConstraints:NO];
            [cell.contentView addSubview:obj];
        }];
        
        switchControl.tag = indexPath.row;
        
        [cell.contentView addConstraint:[NSLayoutConstraint constraintWithItem:switchControl
                                                                     attribute:NSLayoutAttributeCenterY
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:cell.contentView
                                                                     attribute:NSLayoutAttributeCenterY
                                                                    multiplier:1
                                                                      constant:0]];
        
        
        [cell.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[view]|" options:(NSLayoutFormatOptions)0 metrics:nil views:views]];
        [cell.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-5-[switch]-5-[view]-5-|" options:(NSLayoutFormatOptions)0 metrics:nil views:views]];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == [_classes indexOfObject:[RKSTCountdownLabel class]]) {
        return 90;
    }
    
    return 60;
}

@end
