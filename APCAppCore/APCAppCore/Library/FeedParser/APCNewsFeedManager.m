//
//  APCNewsFeedManager.m
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


#import "APCNewsFeedManager.h"
#import "APCFeedParser.h"
#import "APCLog.h"

NSString * const kAPCNewsFeedUpdateNotification = @"APCNewsFeedUpdateNotification";

static NSString * const kAPCReadPostsKey = @"ReadPostsKey";
static NSString * const kAPCBlogUrlKey   = @"BlogUrlKey";

@interface APCNewsFeedManager()

@property (nonatomic, strong) APCFeedParser *feedParser;

@property (nonatomic, strong) NSArray *readPosts;

@end

@implementation APCNewsFeedManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        NSString *urlString = [self blogUrlFromJSONFile:@"StudyOverview"];
        _feedParser = [[APCFeedParser alloc] initWithFeedURL:[NSURL URLWithString:urlString]];
        
        NSString *savedBlogUrl = [[NSUserDefaults standardUserDefaults] stringForKey:kAPCBlogUrlKey];
        
        //Clear read links if blog URL has changed.
        if (![savedBlogUrl isEqualToString:urlString]) {
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:kAPCReadPostsKey];
            
            [[NSUserDefaults standardUserDefaults] setObject:urlString forKey:kAPCBlogUrlKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        
    }
    return self;
}

/**********************************/
#pragma mark - Public methods
/**********************************/

- (void)fetchFeedWithCompletion:(APCNewsFeedManagerCompletionBlock)completion
{
    __weak typeof(self) weakSelf = self;
    
    [self.feedParser fetchFeedWithCompletion:^(NSArray *results, NSError *error) {
        
        __strong typeof(self) strongSelf = weakSelf;
        
        strongSelf.feedPosts = results;
        
        APCLogError2(error);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) {
                completion(results, error);
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:kAPCNewsFeedUpdateNotification object:nil];
        });
    }];
}

- (BOOL)hasUserReadPostWithURL:(NSString *)postURL
{
    return [self.readPosts containsObject:postURL];
}

- (void)userDidReadPostWithURL:(NSString *)postURL
{
    if (![self.readPosts containsObject:postURL]) {
        NSMutableArray *readPosts = [[NSMutableArray alloc] initWithArray:self.readPosts];
        [readPosts addObject:postURL];
        self.readPosts = [NSArray arrayWithArray:readPosts];
    }
}

- (NSUInteger)unreadPostsCount
{
    NSUInteger totalCount = (self.feedPosts) ? [self.feedPosts count] : 0;
    NSUInteger readCount = (self.readPosts) ? [self.readPosts count] : 0;
    
    NSUInteger unreadCount = totalCount - readCount;
    
    return unreadCount;
}

/**********************************/
#pragma mark - Helper methods
/**********************************/

- (NSString *)blogUrlFromJSONFile:(NSString *)jsonFileName
{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:jsonFileName ofType:@"json"];
    NSString *JSONString = [[NSString alloc] initWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:NULL];
    
    NSError *parseError;
    NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:[JSONString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&parseError];
    
    NSString *url = @"";
    
    if (jsonDictionary && !parseError) {
        url = jsonDictionary[@"blog_url"];
    }
    
    return url;
}

/**********************************/
#pragma mark - Getter/Setter methods
/**********************************/

- (NSArray *)readPosts
{
    return [[NSUserDefaults standardUserDefaults] arrayForKey:kAPCReadPostsKey];
}

- (void)setReadPosts:(NSArray *)readPosts
{
    [[NSUserDefaults standardUserDefaults] setObject:readPosts forKey:kAPCReadPostsKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
