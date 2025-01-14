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

#import <string>

#import <ComponentKit/CKOptional.h>

using namespace CK;

@interface CKOptionalTests : XCTestCase
@end

@implementation CKOptionalTests

- (void)test_EqualityWithNone
{
  Optional<int> const a = none;

  XCTAssert(a == none);
  XCTAssert(none == a);
  XCTAssert(none == none);
  XCTAssert(Optional<int>{} == none);
  XCTAssert(none == Optional<int>{});

  auto const b = Optional<int>{2};
  XCTAssert(b != none);
  XCTAssert(none != b);
}

- (void)test_Equality
{
  auto const a = Optional<int>{2};
  auto const b = Optional<int>{3};
  auto const c = Optional<int>{};
  auto const d = Optional<int>{2};
  auto const e = Optional<int>{};

  XCTAssert(a == d);
  XCTAssert(c == e);
  XCTAssert(a != b);
  XCTAssert(a != c);
}

- (void)test_EqualityWithValues
{
  auto const a = Optional<int>{2};

  XCTAssert(a == 2);
  XCTAssert(2 == a);
  XCTAssert(a != 3);
  XCTAssert(3 != a);
}

static auto toInt(const std::string& s) -> Optional<int> {
  if (s.empty()) {
    return none;
  }
  return std::stoi(s);
}

- (void)test_FlatMap
{
  auto const a = Optional<std::string>{"123"};
  auto const b = Optional<std::string>{""};
  auto const c = Optional<std::string>{};

  XCTAssert(a.flatMap(toInt) == 123);
  XCTAssert(b.flatMap(toInt) == none);
  XCTAssert(c.flatMap(toInt) == none);
}

struct HasOptional {
  Optional<int> x;
};

- (void)test_FlatMap_PointerToMember
{
  Optional<HasOptional> const a = HasOptional { 123 };
  Optional<HasOptional> const b = HasOptional { none };

  XCTAssert(a.flatMap(&HasOptional::x) == 123);
  XCTAssert(b.flatMap(&HasOptional::x) == none);
}

- (void)test_WhenEmpty_ValuePtrIsNull
{
  auto const empty = Optional<int>{};

  if (auto const x = empty.unsafeValuePtrOrNull()) {
    XCTFail();
  }
}

- (void)test_WhenHasValue_ValuePtrPointsToValue
{
  auto const a = Optional<int>{2};

  if (auto i = a.unsafeValuePtrOrNull()) {
    XCTAssert(*i == 2);
  } else {
    XCTFail();
  }
}

- (void)test_WhenHasValue_ValueOrTakingFunctionDoesNotInvokeIt
{
  auto fail = ^{
    XCTFail();
    return 3;
  };
  auto x = Optional<int>{2};

  auto y = x.valueOr(fail);
  XCTAssertEqual(y, 2);

  auto z = toInt("2").valueOr(fail);
  XCTAssertEqual(z, 2);
}

static auto toNSString(int x) -> NSString * {
  return [NSString stringWithFormat:@"%d", x];
}

- (void)test_MappingToPointer
{
  auto const x = Optional<int>{2};

  XCTAssertEqualObjects(x.mapToPtr(toNSString), @"2");

  auto const y = Optional<int>{};

  XCTAssertNil(y.mapToPtr(toNSString));
}

@end

static int numCopies = 0;
static int numMoves = 0;

struct CopyMoveTracker {
  CopyMoveTracker() {}

  CopyMoveTracker(const CopyMoveTracker &other)
  {
    numCopies += 1;
  }

  auto operator =(const CopyMoveTracker &) -> CopyMoveTracker &
  {
    numCopies += 1;
    return *this;
  }

  CopyMoveTracker(CopyMoveTracker &&other)
  {
    numMoves += 1;
  }

  auto operator =(CopyMoveTracker &&) -> CopyMoveTracker &
  {
    numMoves += 1;
    return *this;
  }
};

@interface CKOptionalTests_CopiesAndMoves: XCTestCase
@end

@implementation CKOptionalTests_CopiesAndMoves

- (void)setUp
{
  [super setUp];
  numCopies = 0;
  numMoves = 0;
}

- (void)test_CopyConstruction
{
  auto const x = Optional<CopyMoveTracker>{CopyMoveTracker {}};

  auto const y = x;

  XCTAssertEqual(numCopies, 1);
}

- (void)test_Matching
{
  auto const x = Optional<CopyMoveTracker>{CopyMoveTracker {}};

  x.match([](const CopyMoveTracker &){}, [](){});

  XCTAssertEqual(numCopies, 0);
}

- (void)test_Mapping
{
  auto const x = Optional<CopyMoveTracker>{CopyMoveTracker {}};

  x.map([](const CopyMoveTracker &){ return 0; });

  XCTAssertEqual(numCopies, 0);
}

- (void)test_WhenMapping_ReturnValueIsMoved
{
  auto const x = Optional<CopyMoveTracker>{CopyMoveTracker {}}; // Move

  __unused auto const y = x.map([](const CopyMoveTracker &){
    return CopyMoveTracker {};
  }); // Move when constructing the resulting optional

  XCTAssertEqual(numCopies, 0);
  XCTAssertEqual(numMoves, 2);
}

- (void)test_WhenHasValue_ValueOrCopiesValueOut
{
  auto const x = Optional<CopyMoveTracker>{CopyMoveTracker {}}; // Move

  __unused auto const y = x.valueOr({}); // Copy the value out of the optional

  XCTAssertEqual(numCopies, 1);
  XCTAssertEqual(numMoves, 1);
}

- (void)test_WhenEmpty_ValueOrMovesDefaultValue
{
  Optional<CopyMoveTracker> const x = none;

  __unused auto const y = x.valueOr({}); // Move

  XCTAssertEqual(numCopies, 0);
  XCTAssertEqual(numMoves, 1);
}

static auto returnsOptional() -> Optional<CopyMoveTracker> { return CopyMoveTracker {}; }
static auto returnsNone() -> Optional<CopyMoveTracker> { return none; }

- (void)test_WhenMatchingOnRValueAndHasValue_MovesValueOut
{
  __unused auto const y = returnsOptional() // Move
  .match([](CopyMoveTracker &&t){
    return std::move(t); // Move
  }, [](){ return CopyMoveTracker {}; });

  XCTAssertEqual(numCopies, 0);
  XCTAssertEqual(numMoves, 2);
}

- (void)test_WhenRValueHasValue_ValueOrMovesValueOut
{
  __unused auto const x = returnsOptional() // Move + Move
    .valueOr({});

  XCTAssertEqual(numCopies, 0);
  XCTAssertEqual(numMoves, 2);

  auto const dflt = CopyMoveTracker {};

  __unused auto const y = returnsOptional() // Move + Move
    .valueOr(dflt);

  XCTAssertEqual(numCopies, 0);
  XCTAssertEqual(numMoves, 4);

  __unused auto const z = returnsOptional() // Move + Move
    .valueOr([](){ return CopyMoveTracker {}; });

  XCTAssertEqual(numCopies, 0);
  XCTAssertEqual(numMoves, 6);
}

- (void)test_WhenRValueEmpty_ValueOrMovesDefaultValue
{
  __unused auto const x = returnsNone()
    .valueOr({}); // Move

  XCTAssertEqual(numCopies, 0);
  XCTAssertEqual(numMoves, 1);

  __unused auto const z = returnsNone()
    .valueOr([](){ return CopyMoveTracker {}; }); // RVO

  XCTAssertEqual(numCopies, 0);
  XCTAssertEqual(numMoves, 1);
}

- (void)test_WhenRValueEmpty_ValueOrCopiesDefaultValue
{
  auto const dflt = CopyMoveTracker {};
  __unused auto const x = returnsNone()
    .valueOr(dflt); // Copy

  XCTAssertEqual(numCopies, 1);
  XCTAssertEqual(numMoves, 0);
}

- (void)test_WhenAssigningFromRValue_MovesValueOut
{
  Optional<CopyMoveTracker> x = none;

  x = returnsOptional(); // Move + Move assign

  XCTAssertEqual(numCopies, 0);
  XCTAssertEqual(numMoves, 2);
}

- (void)test_WhenApplyingRValue_MovesValueOut
{
  auto x = CopyMoveTracker{};
  returnsOptional() // Move
    .apply([&](CopyMoveTracker &&t){ x = std::move(t); }); // Move assign

  XCTAssertEqual(numMoves, 2);
}

@end
