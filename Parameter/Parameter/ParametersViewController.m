//
//  ViewController.m
//  Parameters
//
//  Created by Karthik Keyan on 8/14/14.
//  Copyright (c) 2014 Karthik Keyan. All rights reserved.
//

#import "InputCell.h"
#import "Parameters.h"
#import "NSString+Extension.h"
#import "ParametersViewController.h"

@interface ParametersViewController () <InputCellDelegate>

@property (nonatomic, strong) Parameters *parameters;

@end

@implementation ParametersViewController

- (void) viewDidLoad {
    [super viewDidLoad];
    
    self.parameters = [[Parameters alloc] init];
    
    [self setupNavigationBar];
}


#pragma mark - Load UI

- (void) setupNavigationBar {
    self.title = @"Parameters";
    
    UIBarButtonItem *rightBarbutton = [UIBarButtonItem.alloc initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(save)];
    [self.navigationItem setRightBarButtonItem:rightBarbutton];
    
    UIBarButtonItem *leftBarbutton = [UIBarButtonItem.alloc initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(reset)];
    [self.navigationItem setLeftBarButtonItem:leftBarbutton];
}


#pragma mark - UITableViewDataSource

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.parameters.allKeys.count;
}

- (InputCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *key = self.parameters.allKeys[indexPath.row];
    id value = [self.parameters valueForKey:key];
    
    InputCell *cell;
    
    static NSString *identifier = @"TextInputCell";
    cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [InputCell.alloc initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier type:InputCellTypeText];
        cell.delegate = self;
    }
    
    cell.txtTitle.text = key;
    
    if ([value isKindOfClass:[NSString class]]) {
        cell.txtValue.text = value;
    }
    else {
        cell.txtValue.text = [value stringValue];
    }
    
    return cell;
}


#pragma mark - UITableViewDelegate

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}


#pragma mark - InputCellDelegate

- (void) inputCellValueChanged:(InputCell *)cell {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    NSString *key = self.parameters.allKeys[indexPath.row];
    
    id previousValue = [self.parameters valueForKey:key];
    
    if ([previousValue isKindOfClass:[NSString class]]) {
        [self.parameters setValue:cell.value forKey:key];
    }
    else {
        NSString *value = cell.value;
        if ([value isNumber]) {
            if ([value rangeOfString:@"."].location == NSNotFound) {
                [self.parameters setValue:@([value integerValue]) forKey:key];
            }
            else {
                [self.parameters setValue:@([value doubleValue]) forKey:key];
            }
        }
        else {
            cell.txtValue.text = [previousValue stringValue];
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Invalid Input" message:@"Only numbers are allowed" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alertView show];
        }
    }
}


#pragma mark - Private Methdos

- (void) reset {
    [self.tableView endEditing:YES];
    
    [self.parameters reset];
    [self.tableView reloadData];
}

- (void) save {
    [self.tableView endEditing:YES];
    
    [self.parameters save];
}

@end
