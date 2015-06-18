//
//  APCCubicCurveAlgorithm.m
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

#import "APCCubicCurveAlgorithm.h"

@interface APCCubicCurveAlgorithm()

@property (nonatomic, strong) NSMutableArray *firstControlPoints;
@property (nonatomic, strong) NSMutableArray *secondControlPoints;

@end

@implementation APCCubicCurveAlgorithm

- (instancetype)init
{
    self = [super init];
    if (self) {
        _firstControlPoints = [NSMutableArray new];
        _secondControlPoints = [NSMutableArray new];
    }
    
    return self;
}

- (NSArray *)emptyArrayTillLength:(NSUInteger)length
{
    NSMutableArray *emptyArray = [NSMutableArray new];
    
    for (NSUInteger i=0; i<length; i++) {
        [emptyArray addObject:[NSNull null]];
    }
    
    return [NSArray arrayWithArray:emptyArray];
}

- (NSArray *)controlPointsFromPoints:(NSArray *)dataPoints
{
    //Number of segments.
    NSInteger count = [dataPoints count] - 1;
    
    //P0, P1, P2, P3 are the points for each segment, where P0 & P3 are the knots and P1, P2 are the control points.
    
    if (count == 1) {
        CGPoint P0 = [dataPoints[0] CGPointValue];
        CGPoint P3 = [dataPoints[1] CGPointValue];
        
        //3P1 = 2P0 + P3
        CGFloat P1x = (2*P0.x + P3.x)/3;
        CGFloat P1y = (2*P0.y + P3.y)/3;
        
        [self.firstControlPoints addObject:[NSValue valueWithCGPoint:CGPointMake(P1x, P1y)]];
        
        //P2 = 2P1 - P0
        CGFloat P2x = (2*P1x - P0.x);
        CGFloat P2y = (2*P1y - P0.y);
        
        [self.secondControlPoints addObject:[NSValue valueWithCGPoint:CGPointMake(P2x, P2y)]];
    } else {
        
        self.firstControlPoints = [NSMutableArray arrayWithArray:[self emptyArrayTillLength:count]];
        
        NSMutableArray *rhsArray = [NSMutableArray new];

        //Array of Coefficients
        NSMutableArray *a = [NSMutableArray new];
        NSMutableArray *b = [NSMutableArray new];
        NSMutableArray *c = [NSMutableArray new];
        
        for (int i=0; i<count; i++) {
            
            CGFloat rhsValueX = 0;
            CGFloat rhsValueY = 0;
            
            CGPoint P0 = [dataPoints[i] CGPointValue];
            CGPoint P3 = [dataPoints[i+1] CGPointValue];
            
            if (i == 0) {
                [a addObject:@0];
                [b addObject:@2];
                [c addObject:@1];
                
                //rhs for first segment
                rhsValueX = P0.x + 2*P3.x;
                rhsValueY = P0.y + 2*P3.y;
            } else if (i == count-1){
                [a addObject:@2];
                [b addObject:@7];
                [c addObject:@0];
                
                //rhs for last segment
                rhsValueX = 8*P0.x + P3.x;
                rhsValueY = 8*P0.y + P3.y;
            } else {
                [a addObject:@1];
                [b addObject:@4];
                [c addObject:@1];
                
                rhsValueX = 4*P0.x + 2*P3.x;
                rhsValueY = 4*P0.y + 2*P3.y;
            }
            
            [rhsArray addObject:[NSValue valueWithCGPoint:CGPointMake(rhsValueX, rhsValueY)]];
        }
        
        //Solve Ax=B. Use Tridiagonal matrix algorithm a.k.a Thomas Algorithm
        
        for (int i=1; i<count; i++) {
            
            CGFloat rhsValueX = [rhsArray[i] CGPointValue].x;
            CGFloat rhsValueY = [rhsArray[i] CGPointValue].y;
            
            CGFloat prevRhsValueX = [rhsArray[i-1] CGPointValue].x;
            CGFloat prevRhsValueY = [rhsArray[i-1] CGPointValue].y;
            
            CGFloat m = [a[i] doubleValue]/[b[i-1] doubleValue];
            
            CGFloat b1 = [b[i] doubleValue] - m * [c[i-1] doubleValue];
            [b replaceObjectAtIndex:i withObject:@(b1)];
            
            CGFloat r2x = rhsValueX - m * prevRhsValueX;
            CGFloat r2y = rhsValueY - m * prevRhsValueY;
            
            [rhsArray replaceObjectAtIndex:i withObject:[NSValue valueWithCGPoint:CGPointMake(r2x, r2y)]];
        }
        
        //Get First Control Points
        
        //Last control Point
        CGFloat lastControlPointX = [rhsArray[count - 1] CGPointValue].x/[b[count-1] doubleValue];
        CGFloat lastControlPointY = [rhsArray[count - 1] CGPointValue].y/[b[count-1] doubleValue];
        
        [self.firstControlPoints replaceObjectAtIndex:count-1 withObject:[NSValue valueWithCGPoint:CGPointMake(lastControlPointX, lastControlPointY)]];
        
        for (int i=(int)count-2; i>=0; --i) {
            CGFloat rhsValueX = [rhsArray[i] CGPointValue].x;
            CGFloat rhsValueY = [rhsArray[i] CGPointValue].y;
            
            CGFloat nextControlPointX = [self.firstControlPoints[i+1] CGPointValue].x;
            CGFloat nextControlPointY = [self.firstControlPoints[i+1] CGPointValue].y;
            
            CGFloat controlPointX = (rhsValueX - [c[i] doubleValue] * nextControlPointX)/[b[i] doubleValue];
            CGFloat controlPointY = (rhsValueY - [c[i] doubleValue] * nextControlPointY)/[b[i] doubleValue];
            
            [self.firstControlPoints replaceObjectAtIndex:i withObject:[NSValue valueWithCGPoint:CGPointMake(controlPointX, controlPointY)]];
        }
        
        //Compute second Control Points from first
        
        for (int i=0; i<count; i++) {
            
            if (i == count-1) {
                CGPoint P3 = [dataPoints[i+1] CGPointValue];
                CGPoint P1 = [self.firstControlPoints[i] CGPointValue];
                
                CGFloat controlPointX = (P3.x + P1.x)/2;
                CGFloat controlPointY = (P3.y + P1.y)/2;
                
                [self.secondControlPoints addObject:[NSValue valueWithCGPoint:CGPointMake(controlPointX, controlPointY)]];

            } else {
                CGPoint P3 = [dataPoints[i+1] CGPointValue];
                CGPoint nextP1 = [self.firstControlPoints[i+1] CGPointValue];
                
                CGFloat controlPointX = 2*P3.x - nextP1.x;
                CGFloat controlPointY = 2*P3.y - nextP1.y;
                
                [self.secondControlPoints addObject:[NSValue valueWithCGPoint:CGPointMake(controlPointX, controlPointY)]];
            }
        }
    }
    
    NSMutableArray *controlPoints = [NSMutableArray new];
    
    for (int i=0; i<count; i++) {
        APCCubicCurveSegment *segment = [APCCubicCurveSegment new];
        segment.controlPoint1 = [self.firstControlPoints[i] CGPointValue];
        segment.controlPoint2 = [self.secondControlPoints[i] CGPointValue];
        
        [controlPoints addObject:segment];
    }
    
    return [NSArray arrayWithArray:controlPoints];
}

@end

@implementation APCCubicCurveSegment

@end
