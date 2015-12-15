//
//  APCTaskResultArchiverTests.m
//  APCAppCore
//
// Copyright (c) 2015 Apple, Inc. All rights reserved.
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

#import <XCTest/XCTest.h>
#import <APCAppCore/APCAppCore.h>

@interface MockDataArchive : APCDataArchive
@property (nonatomic) NSMutableArray <NSDictionary*> *insertObjects;
@end

@interface APCTaskResultArchiverTests : XCTestCase

@end

@implementation APCTaskResultArchiverTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

#pragma mark - filenameForFileResultIdentifier:stepIdentifier:

- (void)testFilenameForFileResultIdentifierWithStepIdentifier_NoMap_NilResultId_NilExtension
{
    APCTaskResultArchiver *archiver = [[APCTaskResultArchiver alloc] init];
    archiver.filenameTranslationDictionary = @{};
    NSString *result = [archiver filenameForFileResultIdentifier:nil stepIdentifier:@"xyz" extension:nil];
    XCTAssertEqualObjects(result, @"xyz");
}

- (void)testFilenameForFileResultIdentifierWithStepIdentifier_NoMap_NilStepId_NilExtension
{
    APCTaskResultArchiver *archiver = [[APCTaskResultArchiver alloc] init];
    archiver.filenameTranslationDictionary = @{};
    NSString *result = [archiver filenameForFileResultIdentifier:@"abc" stepIdentifier:nil extension:nil];
    XCTAssertEqualObjects(result, @"abc");
}

- (void)testFilenameForFileResultIdentifierWithStepIdentifier_NoMap_NilExtension
{
    APCTaskResultArchiver *archiver = [[APCTaskResultArchiver alloc] init];
    archiver.filenameTranslationDictionary = @{};
    NSString *result = [archiver filenameForFileResultIdentifier:@"abc" stepIdentifier:@"xyz" extension:nil];
    XCTAssertEqualObjects(result, @"abc_xyz");
}

- (void)testFilenameForFileResultIdentifierWithStepIdentifier_NoMap
{
    APCTaskResultArchiver *archiver = [[APCTaskResultArchiver alloc] init];
    archiver.filenameTranslationDictionary = @{};
    NSString *result = [archiver filenameForFileResultIdentifier:@"abc" stepIdentifier:@"xyz" extension:@"json"];
    XCTAssertEqualObjects(result, @"abc_xyz.json");
}

- (void)testFilenameForFileResultIdentifierWithStepIdentifier_WithMap
{
    APCTaskResultArchiver *archiver = [[APCTaskResultArchiver alloc] init];
    archiver.filenameTranslationDictionary = @{ @"abc_xyz" : @"abc_xyz.dat"};
    NSString *result = [archiver filenameForFileResultIdentifier:@"abc" stepIdentifier:@"xyz" extension:@"json"];
    XCTAssertEqualObjects(result, @"abc_xyz.dat");
}

#pragma mark - filenameForResult:stepResult:

- (void)testFilenameForResult_APCDataResult
{
    APCDataResult *result = [[APCDataResult alloc] initWithIdentifier:@"abc"];
    ORKStepResult *stepResult = [[ORKStepResult alloc] initWithStepIdentifier:@"xyz" results:@[result]];
    
    APCTaskResultArchiver *archiver = [[APCTaskResultArchiver alloc] init];
    NSString *response = [archiver filenameForResult:result stepResult:stepResult];
    XCTAssertEqualObjects(response, @"abc_data");
}

- (void)testFilenameForResult_ORKFileResult
{
    ORKFileResult *result = [[ORKFileResult alloc] initWithIdentifier:@"abc"];
    ORKStepResult *stepResult = [[ORKStepResult alloc] initWithStepIdentifier:@"xyz" results:@[result]];
    
    APCTaskResultArchiver *archiver = [[APCTaskResultArchiver alloc] init];
    NSString *response = [archiver filenameForResult:result stepResult:stepResult];
    XCTAssertEqualObjects(response, @"abc_xyz");
}

- (void)testFilenameForResult_ORKQuestionResult
{
    ORKQuestionResult *result = [[ORKQuestionResult alloc] initWithIdentifier:@"abc"];
    ORKStepResult *stepResult = [[ORKStepResult alloc] initWithStepIdentifier:@"xyz" results:@[result]];
    
    APCTaskResultArchiver *archiver = [[APCTaskResultArchiver alloc] init];
    NSString *response = [archiver filenameForResult:result stepResult:stepResult];
    XCTAssertEqualObjects(response, @"abc.json");
}

#pragma mark -appendArchive:withTaskResult:

- (void)testAppendArchive_ORKQuestionResult
{
    ORKBooleanQuestionResult *result = [[ORKBooleanQuestionResult alloc] initWithIdentifier:@"abc"];
    result.booleanAnswer = @YES;
    ORKStepResult *stepResult = [[ORKStepResult alloc] initWithStepIdentifier:@"xyz" results:@[result]];
    ORKTaskResult *taskResult = [[ORKTaskResult alloc] initWithIdentifier:@"test"];
    taskResult.results = @[stepResult];
    
    MockDataArchive *mockArchive = [[MockDataArchive alloc] initWithReference:@"test"];
    
    APCTaskResultArchiver *archiver = [[APCTaskResultArchiver alloc] init];
    [archiver appendArchive:mockArchive withTaskResult:taskResult];
    
    XCTAssertEqual(mockArchive.insertObjects.count, 1);
    NSDictionary *archivedObject = [mockArchive.insertObjects firstObject];
    XCTAssertEqualObjects(archivedObject[@"filename"], @"abc.json");
    
    NSDictionary *json =archivedObject[@"dictionary"];
    XCTAssertNotNil(json);
    XCTAssertEqualObjects(json[@"answer"], @1);
    XCTAssertEqualObjects(json[@"booleanAnswer"], @1);
    XCTAssertEqualObjects(json[@"item"], @"abc");
    XCTAssertEqualObjects(json[@"questionType"], @0);
    XCTAssertEqualObjects(json[@"questionTypeName"], @"None");
    XCTAssertNotNil(json[@"startDate"]);
    XCTAssertNotNil(json[@"endDate"]);
}

- (void)testAppendArchive_ORKTappingIntervalResult
{
    ORKTappingIntervalResult *result = [[ORKTappingIntervalResult alloc] initWithIdentifier:@"abc"];
    
    result.stepViewSize = CGSizeMake(100, 120);
    result.buttonRect1 = CGRectMake(1, 2, 30, 40);
    result.buttonRect2 = CGRectMake(5, 6, 70, 80);
    result.samples = @[[self createSampleWithTimestamp:0 button:ORKTappingButtonIdentifierLeft location:CGPointMake(1,2)],
                       [self createSampleWithTimestamp:1 button:ORKTappingButtonIdentifierRight location:CGPointMake(3,4)]];

    ORKStepResult *stepResult = [[ORKStepResult alloc] initWithStepIdentifier:@"xyz" results:@[result]];
    ORKTaskResult *taskResult = [[ORKTaskResult alloc] initWithIdentifier:@"test"];
    taskResult.results = @[stepResult];
    
    MockDataArchive *mockArchive = [[MockDataArchive alloc] initWithReference:@"test"];
    
    APCTaskResultArchiver *archiver = [[APCTaskResultArchiver alloc] init];
    archiver.filenameTranslationDictionary = @{@"abc": @"abc_123.json"};
    
    
    [archiver appendArchive:mockArchive withTaskResult:taskResult];
    
    XCTAssertEqual(mockArchive.insertObjects.count, 1);
    NSDictionary *archivedObject = [mockArchive.insertObjects firstObject];
    XCTAssertEqualObjects(archivedObject[@"filename"], @"abc_123.json");
    
    NSDictionary *json = archivedObject[@"dictionary"];
    XCTAssertNotNil(json);
    XCTAssertNotNil(json[@"startDate"]);
    XCTAssertNotNil(json[@"endDate"]);
    XCTAssertEqualObjects(json[@"item"],@"abc_123.json");
    XCTAssertEqualObjects(json[@"TappingViewSize"],@"{100, 120}");
    XCTAssertEqualObjects(json[@"ButtonRectLeft"],@"{{1, 2}, {30, 40}}");
    XCTAssertEqualObjects(json[@"ButtonRectRight"],@"{{5, 6}, {70, 80}}");
    
    NSArray *tappingSamples = json[@"TappingSamples"];
    NSArray *expectedSamples = @[@{  @"TapCoordinate" : @"{1, 2}",
                                    @"TapTimeStamp" : @0,
                                    @"TappedButtonId" : @"TappedButtonLeft"},
                                @{  @"TapCoordinate" : @"{3, 4}",
                                    @"TapTimeStamp" : @1,
                                    @"TappedButtonId" : @"TappedButtonRight"}];
    XCTAssertEqualObjects(tappingSamples, expectedSamples);
}

- (void)testAppendArchive_ORKFileResult
{
    ORKFileResult *result = [[ORKFileResult alloc] initWithIdentifier:@"abc"];
    result.fileURL = [NSURL URLWithString:@"http://test.org/12345"];
    ORKStepResult *stepResult = [[ORKStepResult alloc] initWithStepIdentifier:@"xyz" results:@[result]];
    ORKTaskResult *taskResult = [[ORKTaskResult alloc] initWithIdentifier:@"test"];
    taskResult.results = @[stepResult];
    
    MockDataArchive *mockArchive = [[MockDataArchive alloc] initWithReference:@"test"];
    
    APCTaskResultArchiver *archiver = [[APCTaskResultArchiver alloc] init];
    archiver.filenameTranslationDictionary = @{@"abc_xyz" : @"abc_xyz.json"};
    [archiver appendArchive:mockArchive withTaskResult:taskResult];
    
    XCTAssertEqual(mockArchive.insertObjects.count, 1);
    NSDictionary *archivedObject = [mockArchive.insertObjects firstObject];
    XCTAssertEqualObjects(archivedObject[@"filename"], @"abc_xyz.json");
    XCTAssertEqualObjects(archivedObject[@"url"], [NSURL URLWithString:@"http://test.org/12345"]);
}

- (void)testAppendArchive_APCDataResult
{
    APCDataResult *result = [[APCDataResult alloc] initWithIdentifier:@"abc"];
    result.data = [NSJSONSerialization dataWithJSONObject:@{@"abc": @"123"} options:0 error:nil];
    ORKStepResult *stepResult = [[ORKStepResult alloc] initWithStepIdentifier:@"xyz" results:@[result]];
    ORKTaskResult *taskResult = [[ORKTaskResult alloc] initWithIdentifier:@"test"];
    taskResult.results = @[stepResult];
    
    MockDataArchive *mockArchive = [[MockDataArchive alloc] initWithReference:@"test"];
    
    APCTaskResultArchiver *archiver = [[APCTaskResultArchiver alloc] init];
    [archiver appendArchive:mockArchive withTaskResult:taskResult];
    
    XCTAssertEqual(mockArchive.insertObjects.count, 1);
    NSDictionary *archivedObject = [mockArchive.insertObjects firstObject];
    XCTAssertEqualObjects(archivedObject[@"filename"], @"abc_data");
    XCTAssertNotNil(archivedObject[@"jsonData"]);
}

- (void)testAppendArchive_ORKSpatialSpanMemoryResult
{
    ORKSpatialSpanMemoryResult *result = [[ORKSpatialSpanMemoryResult alloc] initWithIdentifier:@"cognitive.memory.spatialspan"];
    result.score = 1;
    result.numberOfGames = 3;
    result.numberOfFailures = 2;
    result.gameRecords = [self createMemoryGameRecords:3];
    
    ORKStepResult *stepResult = [[ORKStepResult alloc] initWithStepIdentifier:@"xyz" results:@[result]];
    ORKTaskResult *taskResult = [[ORKTaskResult alloc] initWithIdentifier:@"test"];
    taskResult.results = @[stepResult];
    
    MockDataArchive *mockArchive = [[MockDataArchive alloc] initWithReference:@"test"];
    
    APCTaskResultArchiver *archiver = [[APCTaskResultArchiver alloc] init];
    archiver.filenameTranslationDictionary = @{@"cognitive.memory.spatialspan" : @"abc.json"};
    [archiver appendArchive:mockArchive withTaskResult:taskResult];
    
    XCTAssertEqual(mockArchive.insertObjects.count, 1);
    NSDictionary *archivedObject = [mockArchive.insertObjects firstObject];
    XCTAssertEqualObjects(archivedObject[@"filename"], @"abc.json");
    
    NSDictionary *json = archivedObject[@"dictionary"];
    XCTAssertNotNil(json);
    XCTAssertNotNil(json[@"startDate"]);
    XCTAssertNotNil(json[@"endDate"]);
    XCTAssertEqualObjects(json[@"item"],@"cognitive.memory.spatialspan");
    XCTAssertEqualObjects(json[@"MemoryGameNumberOfFailures"],@2);
    XCTAssertEqualObjects(json[@"MemoryGameNumberOfGames"],@3);
    XCTAssertEqualObjects(json[@"MemoryGameOverallScore"],@1);
    
    NSArray *gameRecords = json[@"MemoryGameGameRecords"];
    XCTAssertEqual(gameRecords.count, 3);
    // TODO: syoung 12/14/2015 Check the values in the game records for validity. (Outside scope of this refactor)
}


#pragma mark - helper methods

- (ORKTappingSample*)createSampleWithTimestamp:(NSTimeInterval)timestamp button:(ORKTappingButtonIdentifier)button location:(CGPoint)location
{
    ORKTappingSample *sample = [[ORKTappingSample alloc] init];
    sample.timestamp = timestamp;
    sample.buttonIdentifier = button;
    sample.location = location;
    return sample;
}

- (NSArray*)createMemoryGameRecords:(NSUInteger)count
{
    NSMutableArray *records = [NSMutableArray new];
    
    for (int ii=0; ii < count; ii++) {
        ORKSpatialSpanMemoryGameRecord *record = [[ORKSpatialSpanMemoryGameRecord alloc] init];
        record.seed = 100 + ii;
        record.sequence = @[@(ii+1), @(ii+2), @(ii+3)];
        record.gameSize = record.sequence.count;
        record.gameStatus = ii==0 ? ORKSpatialSpanMemoryGameStatusSuccess : ORKSpatialSpanMemoryGameStatusFailure;
        record.targetRects = @[[NSValue valueWithCGRect:CGRectMake(1, 2, 3, 4)],
                               [NSValue valueWithCGRect:CGRectMake(5, 6, 7, 8)],
                               [NSValue valueWithCGRect:CGRectMake(9, 10, 11, 12)]];
        record.touchSamples = @[[self createTouchSampleWithTimestamp:ii targetIndex:ii x:ii y:ii+1 correct:ii==0]];
        [records addObject:record];
    }
    
    return [records copy];
}

- (ORKSpatialSpanMemoryGameTouchSample*)createTouchSampleWithTimestamp:(NSTimeInterval)timestamp
                                                           targetIndex:(NSInteger)targetIndex
                                                                     x:(CGFloat)x y:(CGFloat)y
                                                               correct:(BOOL)correct
{
    ORKSpatialSpanMemoryGameTouchSample *sample = [[ORKSpatialSpanMemoryGameTouchSample alloc] init];
    sample.timestamp = timestamp;
    sample.targetIndex = targetIndex;
    sample.location = CGPointMake(x, y);
    sample.correct = correct;
    return sample;
}

@end

@implementation MockDataArchive

- (NSMutableArray *)insertObjects {
    if (!_insertObjects) {
        _insertObjects = [NSMutableArray new];
    }
    return _insertObjects;
}

- (void)insertJSONDataIntoArchive:(NSData *)jsonData filename:(NSString *)filename
{
    [self.insertObjects addObject: @{ @"filename": filename,
                                      @"jsonData": jsonData}];
}

- (void)insertDictionaryIntoArchive:(NSDictionary *)dictionary filename: (NSString *)filename
{
    [self.insertObjects addObject: @{ @"filename": filename,
                                      @"dictionary": dictionary}];
}

- (void)insertDataAtURLIntoArchive: (NSURL*) url fileName: (NSString *) filename
{
    [self.insertObjects addObject: @{ @"filename": filename,
                                      @"url": url}];
}

- (void)insertDataIntoArchive :(NSData *)data filename: (NSString *)filename
{
    [self.insertObjects addObject: @{ @"filename": filename,
                                      @"data": data}];
}


@end
