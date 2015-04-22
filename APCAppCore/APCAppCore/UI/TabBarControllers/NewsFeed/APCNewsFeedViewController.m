//
//  APCNewsFeedViewController.m
//  APCAppCore
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

#import "APCNewsFeedViewController.h"
#import "APCFeedParser.h"
#import "APCFeedTableViewCell.h"
#import "APCWebViewController.h"

@interface APCNewsFeedViewController ()

@property (nonatomic, strong) NSArray *feeds;

@property (nonatomic, strong) APCFeedParser *feedParser;

@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@end

@implementation APCNewsFeedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.refreshControl = [UIRefreshControl new];
    [self.refreshControl addTarget:self action:@selector(refreshFeed) forControlEvents:UIControlEventValueChanged];
    
    self.dateFormatter = [NSDateFormatter new];
    self.dateFormatter.dateFormat = @"MM/dd/yy";
    
    NSString *urlString = @"http://blogsofnote.blogspot.in/feeds/posts/default?alt=rss";// @"https://www.apple.com/main/rss/hotnews/hotnews.rss";
    
    self.feedParser = [[APCFeedParser alloc] initWithFeedURL:[NSURL URLWithString:urlString]];
    
    __weak typeof(self) weakSelf = self;
    
    [self.feedParser fetchFeedWithCompletion:^(NSArray *results, NSError *error) {
        
        if (!error) {
            weakSelf.feeds = results;
            [weakSelf.tableView reloadData];
        } else {
            //Throw error
        }
        
    }];
    
    self.title = NSLocalizedString(@"News", nil);
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)__unused tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)__unused tableView numberOfRowsInSection:(NSInteger)section {

    return self.feeds.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    APCFeedTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kAPCFeedTableViewCellIdentifier];
    
    APCFeedItem *item = self.feeds[indexPath.row];
    
    cell.titleLabel.text = item.title;
    cell.descriptionLabel.text = item.contentDescription;
    cell.dateLabel.text = [self.dateFormatter stringFromDate:item.publishDate];
    
    return cell;
}

- (void)tableView:(UITableView *)__unused tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    APCFeedItem *item = self.feeds[indexPath.row];
    
    APCWebViewController *webViewVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"APCWebViewController"];
    
    webViewVC.link = item.link;
    
    [self.navigationController pushViewController:webViewVC animated:YES];
    
}

- (void)refreshFeed
{
    __weak typeof(self) weakSelf = self;
    
    [self.feedParser fetchFeedWithCompletion:^(NSArray *results, NSError *error) {
        
        [weakSelf.refreshControl endRefreshing];
        
        if (!error) {
            weakSelf.feeds = results;
            [weakSelf.tableView reloadData];
        } else {
            //Throw error
        }
    }];
}

@end
