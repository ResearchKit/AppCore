//
//  APCFeedParser.m
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

#import "APCFeedParser.h"

@interface APCFeedParser()

@property (nonatomic, copy) APCFeedParserCompletionBlock completionBlock;

@property (nonatomic, strong) NSMutableArray *results;

@property (nonatomic, strong) NSString *currentElement;
@property (nonatomic, strong) NSDictionary *attributeDict;

@property (nonatomic, strong) APCFeedItem *feedItem;

@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@end

@implementation APCFeedParser

- (instancetype)initWithFeedURL:(NSURL *)feedURL
{
    self = [super init];
    if (self) {
        _feedURL = feedURL;
        
        _completionBlock = nil;
        
        _results = [NSMutableArray new];
        
        _dateFormatter = [NSDateFormatter new];
        [_dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_EN"]];
        _dateFormatter.dateFormat = @"EEE, dd MMM yyyy HH:mm:ss Z";
    }
    return self;
}

- (void)setupParser
{
    if (self.parser) {
        self.parser = nil;
    }
    
    self.parser = [[NSXMLParser alloc] initWithContentsOfURL:self.feedURL];
    self.parser.delegate = self;
    self.parser.shouldResolveExternalEntities = NO;
}

- (void)fetchFeedWithCompletion:(APCFeedParserCompletionBlock)completion
{
    [self setupParser];
    
    [self.results removeAllObjects];
    
    self.completionBlock = completion;
    
    __weak typeof(self) weakSelf = self;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        BOOL success = [weakSelf.parser parse];
        
        NSLog(@"Success - %d", success);
        if (!success) {
            NSLog(@"Error : %@", weakSelf.parser.parserError);
        }
    });
    
}

#pragma mark - NSXMLParserDelegate methods

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    self.currentElement = elementName;
    self.attributeDict = attributeDict;
    
    if ([elementName isEqualToString:@"item"] || [elementName isEqualToString:@"entry"]) {
        self.feedItem = nil;
        self.feedItem = [APCFeedItem new];
    } else if ([elementName isEqualToString:@"link"]){
        self.feedItem.link = self.attributeDict[@"href"];
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    if ([self.currentElement isEqualToString:@"title"]) {
        self.feedItem.title = [self.feedItem.title stringByAppendingString:string];
    } else if ([self.currentElement isEqualToString:@"link"]) {
        self.feedItem.link = [self.feedItem.link stringByAppendingString:string];
    } else if ([self.currentElement isEqualToString:@"description"] || [self.currentElement isEqualToString:@"content"]) {
        self.feedItem.contentDescription = [self.feedItem.contentDescription stringByAppendingString:string];
    } else if ([self.currentElement isEqualToString:@"pubDate"]) {
        _dateFormatter.dateFormat = @"EEE, dd MMM yyyy HH:mm:ss Z";
        self.feedItem.publishDate = [self.dateFormatter dateFromString:string];
    } else if ([self.currentElement isEqualToString:@"updated"]) {
        _dateFormatter.dateFormat = @"yyyy-MM-ddEEEEEHH:mm:SSSz";
        self.feedItem.publishDate = [self.dateFormatter dateFromString:string];
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if ([elementName isEqualToString:@"item"] || [elementName isEqualToString:@"entry"]) {
        
        [self.results addObject:self.feedItem];
    }
}

- (void)parserDidEndDocument:(NSXMLParser *)parser
{
    __weak typeof(self) weakSelf = self;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (weakSelf.completionBlock) {
            weakSelf.completionBlock([NSArray arrayWithArray:self.results], nil);
        }
    });
    
    
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
    __weak typeof(self) weakSelf = self;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (weakSelf.completionBlock) {
            weakSelf.completionBlock(nil, parseError);
        }
    });
    
    [parser abortParsing];
}

- (void)parser:(NSXMLParser *)parser validationErrorOccurred:(NSError *)validationError
{
    __weak typeof(self) weakSelf = self;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (weakSelf.completionBlock) {
            weakSelf.completionBlock(nil, validationError);
        }
    });
    
    [parser abortParsing];
}
                         
@end


@implementation APCFeedItem

- (instancetype)init
{
    self = [super init];
    if (self) {
        _title = @"";
        _link = @"";
        _contentDescription = @"";
        
    }
    return self;
}
@end
