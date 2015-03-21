/*
 Copyright (c) 2015, Apple Inc. All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:
 
 1.  Redistributions of source code must retain the above copyright notice, this
 list of conditions and the following disclaimer.
 
 2.  Redistributions in binary form must reproduce the above copyright notice,
 this list of conditions and the following disclaimer in the documentation and/or
 other materials provided with the distribution.
 
 3.  Neither the name of the copyright holder(s) nor the names of any contributors
 may be used to endorse or promote products derived from this software without
 specific prior written permission. No license is granted to the trademarks of
 the copyright holders even if such marks are included in this software.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
 FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import <Foundation/Foundation.h>


/**
 Model object representing one "game" in the spatial span memory task.
 
 A game consists of a subset of a permutation of the integers [0 .. gameSize-1],
 which represent the sequence of targets that should be tapped.
 
 */
@interface ORKSpatialSpanGame : NSObject

/**
 Designated initializer.
 @param gameSize         Number of tiles in the game
 @param sequenceLength   Number of elements in the sequence the user has to remember
 @param seed             The generator that should be used for generating the sequence.
        A generator of 0 indicates to select a random seed.
 */
- (instancetype)initWithGameSize:(NSInteger)gameSize
                  sequenceLength:(NSInteger)sequenceLength
                            seed:(uint32_t)seed NS_DESIGNATED_INITIALIZER;

/// Number of tiles in the game.
@property (nonatomic, readonly) NSInteger gameSize;

/// Length of the sequence. The sequence is a sub-array of length sequenceLength of a random permutation of integers (0..gameSize-1)
@property (nonatomic, readonly) NSInteger sequenceLength;

/// Seed for the sequence. Pass to another game, and you get the same game
@property (nonatomic, readonly) uint32_t seed;

/**
 Enumerate the sequence, calling the block once for each element.
 
 @param handler Block to be called for each element in the sequence. The block parameters are:
 
 step  The step in the enumeration. Starts at 0, increments by one on each call.
 tileIndex The index in [ 0 .. gameSize ] corresponding to this step'th element of the sequence.
 isLastStep True if this is the last step in the sequence.
 stop   Set to NO to terminate the enumeration.
 */

/// Step parameter is the step in the sequence; tileIndex is the value of that step of the sequence.
- (void)enumerateSequenceWithHandler:(void(^)(NSInteger step, NSInteger tileIndex, BOOL isLastStep, BOOL *stop))handler;

/// Random access into the sequence.
- (NSInteger)tileIndexForStep:(NSInteger)step;


@end
