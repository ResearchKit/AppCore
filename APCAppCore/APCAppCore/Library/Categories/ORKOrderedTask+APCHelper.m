//
//  ORKOrderedTask+APCHelper.m
//  APCAppCore
//
//  Created by Shannon Young on 12/9/15.
//  Copyright © 2015 Apple, Inc. All rights reserved.
//

#import "ORKOrderedTask+APCHelper.h"
#import "APCLocalization.h"
#import "UIImage+APCHelper.h"

NSString *const APCTapInstructionStepIdentifier  = @"tappingInstruction";
NSString *const APCTapTappingStepIdentifier      = @"tapping";
NSString *const APCRightHandIdentifier           = @"right";
NSString *const APCLeftHandIdentifier            = @"left";

@implementation ORKOrderedTask (APCHelper)

+ (ORKOrderedTask *)twoFingerTappingIntervalTaskWithIdentifier:(NSString *)identifier
                                        intendedUseDescription:(NSString *)intendedUseDescription
                                                      duration:(NSTimeInterval)duration
                                                       options:(ORKPredefinedTaskOption)options
                                                   handOptions:(APCTapHandOption)handOptions
{
    ORKOrderedTask  *orkTask = [self twoFingerTappingIntervalTaskWithIdentifier:identifier
                                                         intendedUseDescription:intendedUseDescription
                                                                       duration:duration
                                                                        options:options];
    if (handOptions == APCTapHandOptionUndefined) {
        return orkTask;
    }
    
    // Create mutable copy of the steps
    NSMutableArray *steps = [orkTask.steps mutableCopy];
    
    // Look for the tapping instrution step
    const NSUInteger tappingInstructionIdx = 1;
    ORKInstructionStep *tappingInstructionStep = nil;
    if ((orkTask.steps.count > tappingInstructionIdx) &&
        [orkTask.steps[tappingInstructionIdx] isKindOfClass:[ORKInstructionStep class]])
    {
        tappingInstructionStep = (ORKInstructionStep *)orkTask.steps[tappingInstructionIdx];
        tappingInstructionStep.detailText = NSLocalizedStringWithDefaultValue(@"Step Detail Text", @"APCAppCore", APCBundle(),
                                                                              @"Tap the Next button to begin.",
                                                                              @"Tap the Next button to begin.");
        [steps removeObject:tappingInstructionStep];
    }
    
    // Look for a tapping activity step
    ORKActiveStep *tappingStep = nil;
    NSUInteger tappingIdx = NSNotFound;
    for (NSUInteger idx=1; idx < steps.count && tappingIdx == NSNotFound; idx++)
    {
        if ([steps[idx] isKindOfClass:[ORKActiveStep class]]) {
            tappingStep = steps[idx];
            tappingIdx = idx;
        }
    }
    
    // If either the instruction step or the tapping activity step is not found
    // then this is no longer pointing at a valid version of ResearchKit and needs to be fixed
    if ((tappingIdx == NSNotFound) || (tappingInstructionStep == nil))
    {
        NSAssert(tappingIdx != NSNotFound, @"Could not find tapping activity");
        NSAssert(tappingInstructionStep != nil, @"Could not find tapping instruction");
        return orkTask;
    }
    
    // Remove the existing tapping step
    [steps removeObjectAtIndex:tappingIdx];
    
    // Setup which hand to start with and how many hands to add based on the handOptions parameter
    // Hand order is randomly determined.
    NSUInteger handCount = ((handOptions & APCTapHandOptionBoth) == APCTapHandOptionBoth) ? 2 : 1;
    BOOL rightHand;
    switch (handOptions) {
        case APCTapHandOptionLeft:
            rightHand = NO; break;
        case APCTapHandOptionRight:
            rightHand = YES; break;
        default:
            rightHand = (((NSUInteger)[NSDate timeIntervalSinceReferenceDate])%2 == 0); break;
    }
    
    for (NSUInteger hand=1; hand <= handCount; hand++)
    {
        // Copy steps to duplicate for both right and left hands
        NSString *handIdentifier = rightHand ? APCRightHandIdentifier : APCLeftHandIdentifier;
        ORKInstructionStep *instructionStep = [tappingInstructionStep copyWithIdentifier:[NSString stringWithFormat:@"%@_%@", APCTapInstructionStepIdentifier, handIdentifier]];
        ORKActiveStep *activeStep = [tappingStep copyWithIdentifier:[NSString stringWithFormat:@"%@_%@", APCTapTappingStepIdentifier, handIdentifier]];
        activeStep.optional = YES;

        // Set instructions and image for right/left hands
        if (rightHand) {
            instructionStep.title = NSLocalizedStringWithDefaultValue(@"Right Hand", @"APCAppCore", APCBundle(), @"Right Hand", @"Title for instruction step for right hand.");
            activeStep.title = NSLocalizedStringWithDefaultValue(@"Right Hand Tap Step Title", @"APCAppCore", APCBundle(),
                                                                 @"Tap the buttons as quickly as you can using your RIGHT hand.",
                                                                 @"Tapping activity instructions explicitly calling out using the right hand.");
        }
        else {
            instructionStep.title = NSLocalizedStringWithDefaultValue(@"Left Hand", @"APCAppCore", APCBundle(), @"Left Hand", @"Title for instruction step for left hand.");
            activeStep.title = NSLocalizedStringWithDefaultValue(@"Left Hand Tap Step Title", @"APCAppCore", APCBundle(),
                                                                 @"Tap the buttons as quickly as you can using your LEFT hand.",
                                                                 @"Tapping activity instructions explicitly calling out using the left hand.");
            instructionStep.image = [instructionStep.image flippedImage:UIImageOrientationUpMirrored];
        }
        
        // Update the instructions for the tapping test screen that is displayed prior to each hand test
        NSString *restText = NSLocalizedStringWithDefaultValue(@"Instructions Flat Surface", @"APCAppCore", APCBundle(),
                                                               @"Rest your phone on a flat surface.",
                                                               @"Instruction to rest phone on a flat surface before beginning test.");
        NSString *durationString = [APCDurationStringFormatter() stringFromTimeInterval:duration];
        NSString *tappingTextFormat = NSLocalizedStringWithDefaultValue(@"Instructions Tap Consistently", @"APCAppCore", APCBundle(),
                                                                        @"Keep tapping for %@ and time your taps to be as consistent as possible.",
                                                                        @"Instruction to tap consistentently for a given period of time defined by %@");
        NSString *tappingText = [NSString stringWithFormat:tappingTextFormat, durationString];
        NSString *handText = nil;
        
        if (hand == 1) {
            if (rightHand) {
                handText = NSLocalizedStringWithDefaultValue(@"Right Hand Tap Instructions", @"APCAppCore", APCBundle(),
                                                             @"Then use two fingers on your right hand to alternately tap the buttons that appear.",
                                                             @"Instructions for the tapping test with the right hand.");
            }
            else {
                handText = NSLocalizedStringWithDefaultValue(@"Left Hand Tap Instructions", @"APCAppCore", APCBundle(),
                                                             @"Then use two fingers on your left hand to alternately tap the buttons that appear.",
                                                             @"Instructions for the tapping test with the left hand.");
            }
        }
        else {
            if (rightHand) {
                handText = NSLocalizedStringWithDefaultValue(@"Right Hand Repeat Instructions", @"APCAppCore", APCBundle(),
                                                  @"Now repeat the same test using your right hand.",
                                                  @"Instructions for repeating the tapping test with the right hand.");
            }
            else {
                handText = NSLocalizedStringWithDefaultValue(@"Left Hand Repeat Instructions", @"APCAppCore", APCBundle(),
                                                  @"Now repeat the same test using your left hand.",
                                                  @"Instructions for repeating the tapping test with the left hand.");
            }
        }
        instructionStep.text = [NSString stringWithFormat:@"%@ %@ %@", restText, handText, tappingText];
        
        // Insert the instruction step and tapping activity step
        [steps insertObject:instructionStep atIndex:tappingIdx++];
        [steps insertObject:activeStep atIndex:tappingIdx++];
        
        // Flip to the other hand (ignored if handCount == 1)
        rightHand = !rightHand;
    }
        
    return [[ORKOrderedTask alloc] initWithIdentifier:identifier steps:steps];
}

@end
