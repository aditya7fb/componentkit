/*
 *  Copyright (c) 2014-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the BSD-style license found in the
 *  LICENSE file in the root directory of this source tree. An additional grant
 *  of patent rights can be found in the PATENTS file in the same directory.
 *
 */

#import <XCTest/XCTest.h>

#import <array>

#import <ComponentKit/CKCasting.h>
#import <ComponentKit/CKAnimation.h>
#import <ComponentKit/ComponentUtilities.h>

using namespace CK;
using namespace CK::Animation;

template <size_t N>
static auto checkKeyPathsForAnimations(XCTestCase *self,
                                       const std::array<CAPropertyAnimation *, N> &animations,
                                       const std::array<const char *, N> &expectedKeyPaths)
{
  for (auto i = 0; i < N; ++i) {
    XCTAssertEqualObjects(animations[i].keyPath, @(expectedKeyPaths[i]));
  }
}

@interface CKAnimationTests_KeyPaths : XCTestCase
@end

@implementation CKAnimationTests_KeyPaths

- (void)testInitialAnimationsKeyPaths
{
  auto const animations = std::array<CAPropertyAnimation *, 4>{
    objCForceCast<CAPropertyAnimation>(alphaFrom(0).toCA()),
    objCForceCast<CAPropertyAnimation>(translationYFrom(0).toCA()),
    objCForceCast<CAPropertyAnimation>(backgroundColorFrom(UIColor.blackColor).toCA()),
    objCForceCast<CAPropertyAnimation>(borderColorFrom(UIColor.blackColor).toCA()),
  };

  auto const expectedKeyPaths = std::array<const char *, 4>{
    "opacity",
    "transform.translation.y",
    "backgroundColor",
    "borderColor"
  };

  checkKeyPathsForAnimations(self, animations, expectedKeyPaths);
}

- (void)testFinalAnimationsKeyPaths
{
  auto const animations = std::array<CAPropertyAnimation *, 4>{
    objCForceCast<CAPropertyAnimation>(alphaTo(0).toCA()),
    objCForceCast<CAPropertyAnimation>(translationYTo(0).toCA()),
    objCForceCast<CAPropertyAnimation>(backgroundColorTo(UIColor.blackColor).toCA()),
    objCForceCast<CAPropertyAnimation>(borderColorTo(UIColor.blackColor).toCA()),
  };

  auto const expectedKeyPaths = std::array<const char *, 4>{
    "opacity",
    "transform.translation.y",
    "backgroundColor",
    "borderColor"
  };

  checkKeyPathsForAnimations(self, animations, expectedKeyPaths);
}

- (void)testChangeAnimationsKeyPaths
{
  auto const animations = std::array<CAPropertyAnimation *, 4>{
    objCForceCast<CAPropertyAnimation>(alpha().toCA()),
    objCForceCast<CAPropertyAnimation>(backgroundColor().toCA()),
    objCForceCast<CAPropertyAnimation>(borderColor().toCA()),
    objCForceCast<CAPropertyAnimation>(position().toCA()),
  };

  auto const expectedKeyPaths = std::array<const char *, 4>{
    "opacity",
    "backgroundColor",
    "borderColor",
    "position"
  };

  checkKeyPathsForAnimations(self, animations, expectedKeyPaths);
}

@end

@interface CKAnimationTests_Initial: XCTestCase
@end

@implementation CKAnimationTests_Initial

- (void)testSettingScalarFromValue
{
  auto a = objCForceCast<CABasicAnimation>(alphaFrom(0).toCA());

  XCTAssertEqualObjects(a.fromValue, @(0));
}

- (void)testSettingUIColorFromValueForInitialAnimation
{
  auto a = objCForceCast<CABasicAnimation>(backgroundColorFrom(UIColor.blueColor).toCA());

  XCTAssertEqualObjects(a.fromValue, (id)UIColor.blueColor.CGColor);
}

- (void)test_WhenDurationIsNotSet_ItIsZero
{
  XCTAssertEqual(alphaFrom(0).toCA().duration, 0);
  XCTAssertEqual(backgroundColorFrom(UIColor.blackColor).toCA().duration, 0);
}

- (void)testSettingDuration
{
  XCTAssertEqual(alphaFrom(0).withDuration(0.25).toCA().duration, 0.25);
  XCTAssertEqual(backgroundColorFrom(UIColor.blackColor).withDuration(0.25).toCA().duration, 0.25);
}

- (void)testSettingDelay
{
  XCTAssertEqual(alphaFrom(0).withDelay(0.25).toCA().beginTime, 0.25);
  XCTAssertEqual(backgroundColorFrom(UIColor.blackColor).withDelay(0.25).toCA().beginTime, 0.25);
}

- (void)test_WhenTimingFunctionIsNotSet_UsesLinear
{
  XCTAssertEqualObjects(alphaFrom(0).toCA().timingFunction, [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]);
  XCTAssertEqualObjects(backgroundColorFrom(UIColor.blackColor).toCA().timingFunction, [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]);
}

- (void)testSettingTimingFunction
{
  XCTAssertEqualObjects(alphaFrom(0).easeIn().toCA().timingFunction, [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]);
  XCTAssertEqualObjects(backgroundColorFrom(UIColor.blackColor).easeIn().toCA().timingFunction, [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]);
  XCTAssertEqualObjects(alphaFrom(0).easeOut().toCA().timingFunction, [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]);
  XCTAssertEqualObjects(backgroundColorFrom(UIColor.blackColor).easeOut().toCA().timingFunction, [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]);
}

- (void)testSettingTimingFunctionWithDuration
{
  auto a1 = alphaFrom(0).easeIn(0.25).toCA();

  XCTAssertEqual(a1.duration, 0.25);
  XCTAssertEqualObjects(a1.timingFunction, [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]);

  auto a2 = backgroundColorFrom(UIColor.blackColor).easeIn(0.25).toCA();

  XCTAssertEqual(a2.duration, 0.25);
  XCTAssertEqualObjects(a2.timingFunction, [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]);
}

- (void)testAlwaysUsesBackwardsFillMode
{
  XCTAssertEqualObjects(alphaFrom(0).toCA().fillMode, kCAFillModeBackwards);
  XCTAssertEqualObjects(backgroundColorFrom(UIColor.blackColor).toCA().fillMode, kCAFillModeBackwards);
}

@end

@interface CKAnimationTests_Final: XCTestCase
@end

@implementation CKAnimationTests_Final

- (void)testSettingScalarToValueForFinalAnimation
{
  auto a = objCForceCast<CABasicAnimation>(alphaTo(0).toCA());

  XCTAssertEqualObjects(a.toValue, @(0));
}

- (void)testSettingUIColorToValueForFinalAnimation
{
  auto a = objCForceCast<CABasicAnimation>(backgroundColorTo(UIColor.blueColor).toCA());

  XCTAssertEqualObjects(a.toValue, (id)UIColor.blueColor.CGColor);
}

- (void)test_WhenDurationIsNotSet_ItIsZero
{
  XCTAssertEqual(alphaTo(0).toCA().duration, 0);
  XCTAssertEqual(backgroundColorTo(UIColor.blackColor).toCA().duration, 0);
}

- (void)testSettingDuration
{
  XCTAssertEqual(alphaTo(0).withDuration(0.25).toCA().duration, 0.25);
  XCTAssertEqual(backgroundColorTo(UIColor.blackColor).withDuration(0.25).toCA().duration, 0.25);
}

- (void)testSettingDelay
{
  XCTAssertEqual(alphaTo(0).withDelay(0.25).toCA().beginTime, 0.25);
  XCTAssertEqual(backgroundColorTo(UIColor.blackColor).withDelay(0.25).toCA().beginTime, 0.25);
}

- (void)test_WhenTimingFunctionIsNotSet_UsesLinear
{
  XCTAssertEqualObjects(alphaTo(0).toCA().timingFunction, [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]);
  XCTAssertEqualObjects(backgroundColorTo(UIColor.blackColor).toCA().timingFunction, [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]);
}

- (void)testSettingTimingFunction
{
  XCTAssertEqualObjects(alphaTo(0).easeIn().toCA().timingFunction, [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]);
  XCTAssertEqualObjects(backgroundColorTo(UIColor.blackColor).easeIn().toCA().timingFunction, [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]);
  XCTAssertEqualObjects(alphaTo(0).easeOut().toCA().timingFunction, [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]);
  XCTAssertEqualObjects(backgroundColorTo(UIColor.blackColor).easeOut().toCA().timingFunction, [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]);
}

- (void)testSettingTimingFunctionWithDuration
{
  auto a1 = alphaTo(0).easeIn(0.25).toCA();

  XCTAssertEqual(a1.duration, 0.25);
  XCTAssertEqualObjects(a1.timingFunction, [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]);

  auto a2 = backgroundColorTo(UIColor.blackColor).easeIn(0.25).toCA();

  XCTAssertEqual(a2.duration, 0.25);
  XCTAssertEqualObjects(a2.timingFunction, [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]);
}

- (void)testAlwaysUsesForwardsFillMode
{
  XCTAssertEqualObjects(alphaTo(0).toCA().fillMode, kCAFillModeForwards);
  XCTAssertEqualObjects(backgroundColorTo(UIColor.blackColor).toCA().fillMode, kCAFillModeForwards);
}

@end

@interface CKAnimationTests_Change: XCTestCase
@end

@implementation CKAnimationTests_Change

- (void)test_WhenDurationIsNotSet_ItIsZero
{
  auto a = alpha().toCA();

  XCTAssertEqual(a.duration, 0);
}

- (void)testSettingDuration
{
  auto a = alpha().withDuration(0.25).toCA();

  XCTAssertEqual(a.duration, 0.25);
}

- (void)testSettingDelay
{
  auto a = alpha().withDelay(0.25).toCA();

  XCTAssertEqual(a.beginTime, 0.25);
}

- (void)test_WhenTimingFunctionIsNotSet_UsesLinear
{
  XCTAssertEqualObjects(alpha().toCA().timingFunction, [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]);
}

- (void)testSettingTimingFunction
{
  XCTAssertEqualObjects(alpha().easeIn().toCA().timingFunction, [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]);
  XCTAssertEqualObjects(alpha().easeOut().toCA().timingFunction, [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]);
}

- (void)testSettingTimingFunctionWithDuration
{
  auto a = alpha().easeIn(0.25).toCA();

  XCTAssertEqual(a.duration, 0.25);
  XCTAssertEqualObjects(a.timingFunction, [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]);
}

@end

@interface CKAnimationTests_Parallel : XCTestCase
@end

@implementation CKAnimationTests_Parallel

- (void)testComposingAnimations
{
  auto group = objCForceCast<CAAnimationGroup>(parallel(alphaFrom(0), translationYFrom(0)).toCA());

  XCTAssertEqual(group.animations.count, 2);
  auto a1 = objCForceCast<CAPropertyAnimation>(group.animations[0]);
  XCTAssertEqualObjects(a1.keyPath, @"opacity");
  auto a2 = objCForceCast<CAPropertyAnimation>(group.animations[1]);
  XCTAssertEqualObjects(a2.keyPath, @"transform.translation.y");
}

- (void)test_WhenDurationIsNotSet_ItIsZero
{
  auto a = parallel(alphaFrom(0), translationYFrom(0)).toCA();

  XCTAssertEqual(a.duration, 0);
}

- (void)testSettingDuration
{
  auto a = parallel(alphaFrom(0), translationYFrom(0)).withDuration(0.25).toCA();

  XCTAssertEqual(a.duration, 0.25);
}

- (void)testSettingDelay
{
  auto a = parallel(alphaFrom(0), translationYFrom(0)).withDelay(0.25).toCA();

  XCTAssertEqual(a.beginTime, 0.25);
}

- (void)test_WhenTimingFunctionIsNotSet_UsesLinear
{
  XCTAssertEqualObjects(parallel(alphaFrom(0), translationYFrom(0)).toCA().timingFunction, [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]);
}

- (void)testSettingTimingFunction
{
  XCTAssertEqualObjects(parallel(alphaFrom(0), translationYFrom(0)).easeIn().toCA().timingFunction, [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]);
  XCTAssertEqualObjects(parallel(alphaFrom(0), translationYFrom(0)).easeOut().toCA().timingFunction, [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]);
}

- (void)testSettingTimingFunctionWithDuration
{
  auto a = parallel(alphaFrom(0), translationYFrom(0)).easeIn(0.25).toCA();

  XCTAssertEqual(a.duration, 0.25);
  XCTAssertEqualObjects(a.timingFunction, [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]);
}

- (void)test_WhenComposingInitialAnimations_UsesBackwardsFillMode
{
  auto a = parallel(alphaFrom(0), translationYFrom(0)).toCA();

  XCTAssertEqualObjects(a.fillMode, kCAFillModeBackwards);
}

@end

@interface CKAnimationTests_Sequence : XCTestCase
@end

@implementation CKAnimationTests_Sequence

- (void)testComposingAnimations
{
  auto group = objCForceCast<CAAnimationGroup>(sequence(alphaFrom(0), translationYFrom(0)).toCA());

  XCTAssertEqual(group.animations.count, 2);
  auto a1 = objCForceCast<CAPropertyAnimation>(group.animations[0]);
  XCTAssertEqualObjects(a1.keyPath, @"opacity");
  auto a2 = objCForceCast<CAPropertyAnimation>(group.animations[1]);
  XCTAssertEqualObjects(a2.keyPath, @"transform.translation.y");
}

- (void)testSecondAnimationStartsAfterFirst
{
  auto group = objCForceCast<CAAnimationGroup>(sequence(alphaFrom(0), translationYFrom(0)).toCA());

  XCTAssertEqual(group.animations.count, 2);
  auto a1 = objCForceCast<CAPropertyAnimation>(group.animations[0]);
  XCTAssertEqual(a1.beginTime, 0);
  auto a2 = objCForceCast<CAPropertyAnimation>(group.animations[1]);
  XCTAssertEqual(a2.beginTime, 0.25);
}

- (void)test_DurationIsEqualToSumOfComposedAnimationDurations
{
  XCTAssertEqual(sequence(alphaFrom(0), translationYFrom(0)).toCA().duration, 0.5);
  XCTAssertEqual(sequence(alphaFrom(0).withDuration(0.5), translationYFrom(0)).toCA().duration, 0.75);
  XCTAssertEqual(sequence(alphaFrom(0), translationYFrom(0).withDuration(0.5)).toCA().duration, 0.75);
}

- (void)testSettingDelay
{
  auto a = sequence(alphaFrom(0), translationYFrom(0)).withDelay(0.25).toCA();

  XCTAssertEqual(a.beginTime, 0.25);
}

- (void)test_WhenTimingFunctionIsNotSet_UsesLinear
{
  XCTAssertEqualObjects(sequence(alphaFrom(0), translationYFrom(0)).toCA().timingFunction, [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]);
}

- (void)testSettingTimingFunction
{
  XCTAssertEqualObjects(sequence(alphaFrom(0), translationYFrom(0)).easeIn().toCA().timingFunction, [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]);
  XCTAssertEqualObjects(sequence(alphaFrom(0), translationYFrom(0)).easeOut().toCA().timingFunction, [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]);
}

- (void)testSettingTimingFunctionWithDuration
{
  auto a = sequence(alphaFrom(0), translationYFrom(0)).easeIn().toCA();

  XCTAssertEqualObjects(a.timingFunction, [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]);
}

- (void)test_WhenComposingInitialAnimations_UsesBackwardsFillMode
{
  auto a = sequence(alphaFrom(0), translationYFrom(0)).toCA();

  XCTAssertEqualObjects(a.fillMode, kCAFillModeBackwards);
}


@end
