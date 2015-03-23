//
//  APCLicenseInfoViewController.m
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import "APCLicenseInfoViewController.h"
#import "NSBundle+Helper.h"

static NSString * const kLicenseInfoCellIdentifier = @"LicenseInfoCell";
static CGFloat const kCellBaseHeight = 66.0f;
static CGFloat const klabelSidepadding = 30.f;

@interface APCLicenseInfoViewController ()

@property (nonatomic, strong) NSArray *content;

@end

@implementation APCLicenseInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.content = @[@{
                         @"title": @"Bridge SDK",
                         @"filename": @"License_BridgeSDK",
                         @"file_type": @"txt"
                         },
                     @{
                         @"title": @"Open SSL",
                         @"filename": @"License_OpenSSL",
                         @"file_type": @"txt"
                         },
                     @{
                         @"title": @"ZipZap",
                         @"filename": @"License_ZipZap",
                         @"file_type": @"txt"
                         }
                     ];
    [self prepareContent];
}

- (void)prepareContent
{
    NSMutableArray *items = [NSMutableArray new];
    
    for (NSDictionary *info in self.content) {
        NSString *filename = info[@"filename"];
        NSString *type = info[@"file_type"];
        
        NSString *content = [self contentFromFile:filename type:type];
        [items addObject:content];
    }
    
    self.items = [NSArray arrayWithArray:items];
}

- (NSString *)contentFromFile:(NSString *)filename type:(NSString *)type
{
    NSString *filePath = [[NSBundle appleCoreBundle] pathForResource:filename ofType:type];
    NSString *content = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    
    return content;
}


#pragma mark - UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)__unused tableView {
    return self.items.count;
}

- (NSInteger)tableView:(UITableView *)__unused tableView numberOfRowsInSection:(NSInteger)__unused section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kLicenseInfoCellIdentifier];
    
    NSDictionary *info = self.content[indexPath.section];
    
    cell.textLabel.text = info[@"title"];
    cell.detailTextLabel.text = self.items[indexPath.section];
    
    return cell;
}

#pragma mark - UITableViewDelegate methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 44;
    
    NSString *text = self.items[indexPath.section];
    CGRect textRect = [text boundingRectWithSize:CGSizeMake(CGRectGetWidth(tableView.frame) - klabelSidepadding, CGFLOAT_MAX) options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15.0]} context:nil];
    
    height = textRect.size.height + kCellBaseHeight;
    
    return height;
}

@end
