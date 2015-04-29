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
@property (nonatomic, strong) NSMutableString *tempString;

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
        
        if (!success) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (weakSelf.completionBlock) {
                    weakSelf.completionBlock(nil, weakSelf.parser.parserError);
                }
            });
        }
    });
    
}

#pragma mark - NSXMLParserDelegate methods

- (void)parser:(NSXMLParser *)__unused parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)__unused namespaceURI qualifiedName:(NSString *)__unused qName attributes:(NSDictionary *)attributeDict
{
    self.currentElement = elementName;
    self.attributeDict = attributeDict;
    
    if ([elementName isEqualToString:@"item"] || [elementName isEqualToString:@"entry"]) {
        self.feedItem = nil;
        self.feedItem = [APCFeedItem new];
    }
    
    self.tempString = nil;
    self.tempString = [NSMutableString new];
}

- (void)parser:(NSXMLParser *)__unused parser foundCharacters:(NSString *)string
{
    [self.tempString appendString:string];
}

- (void)parser:(NSXMLParser *)__unused parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)__unused namespaceURI qualifiedName:(NSString *)__unused qName
{
    if ([elementName isEqualToString:@"item"] || [elementName isEqualToString:@"entry"]) {
        
        [self.results addObject:self.feedItem];
    }
    
    if (self.feedItem != nil && self.tempString != nil) {
        
        if ([elementName isEqualToString:@"title"]) {
            self.feedItem.title = self.tempString;
        } else if ([elementName isEqualToString:@"description"]) {
            self.feedItem.itemDescription = self.tempString;
        } else if ([elementName isEqualToString:@"content:encoded"] || [elementName isEqualToString:@"content"]) {
            self.feedItem.content = self.tempString;
        } else if ([elementName isEqualToString:@"link"]) {
            self.feedItem.link = self.tempString;
        } else if ([elementName isEqualToString:@"pubDate"]) {
            _dateFormatter.dateFormat = @"EEE, dd MMM yyyy HH:mm:ss Z";
            self.feedItem.pubDate = [self.dateFormatter dateFromString:self.tempString];
        } else if ([elementName isEqualToString:@"dc:creator"]) {
            self.feedItem.author = self.tempString;
        } else if ([elementName isEqualToString:@"guid"]) {
            self.feedItem.guid = self.tempString;
        }
        
        // sometimes the URL is inside enclosure element, not in link. Reference: http://www.w3schools.com/rss/rss_tag_enclosure.asp
        if ([elementName isEqualToString:@"enclosure"] && self.attributeDict != nil) {
            NSString *url = [self.attributeDict objectForKey:@"url"];
            if(url) {
                self.feedItem.link = url;
            }
        }
    }
}

- (void)parserDidEndDocument:(NSXMLParser *)__unused parser
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
        _content = @"";
        _itemDescription = @"";
        
    }
    return self;
}

- (NSArray *)imagesFromItemDescription
{
    if (self.itemDescription) {
        return [self imagesFromHTMLString:self.itemDescription];
    }
    
    return nil;
}

- (NSArray *)imagesFromContent
{
    if (self.content) {
        return [self imagesFromHTMLString:self.content];
    }
    
    return nil;
}

#pragma mark - retrieve images from html string using regexp (private methode)

- (NSArray *)imagesFromHTMLString:(NSString *)htmlstr
{
    NSMutableArray *imagesURLStringArray = [[NSMutableArray alloc] init];
    
    NSError *error;
    
    NSRegularExpression *regex = [NSRegularExpression
                                  regularExpressionWithPattern:@"(https?)\\S*(png|jpg|jpeg|gif)"
                                  options:NSRegularExpressionCaseInsensitive
                                  error:&error];
    
    [regex enumerateMatchesInString:htmlstr
                            options:0
                              range:NSMakeRange(0, htmlstr.length)
                         usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
                             [imagesURLStringArray addObject:[htmlstr substringWithRange:result.range]];
                         }];
    
    return [NSArray arrayWithArray:imagesURLStringArray];
}

@end
