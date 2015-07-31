//
// APCLicenseInfoViewController.m
// APCAppCore
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
