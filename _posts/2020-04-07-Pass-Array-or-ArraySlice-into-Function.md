---
layout: post
title: Pass Array or ArraySlice into Function
date: 2020-04-07 16:31:00
comments: true
disqus_category_id: PassArrayORArraySliceIntoFunction
categories: [Swift]
tags: [Array, ArraySlice]
---

## Array & ArraySlice

- `Array` is Swift ordered, random-access collection.
- `ArraySlice` is a slice of an Array, ContiguousArray or ArraySlice instance.

We could simply get a ArraySlice element by Array's subsequence. ex:

```swift
let absences = [0, 2, 0, 4, 0, 3, 1, 0]
let midpoint = absences.count / 2

let firstHalf = absences[..<midpoint]
let secondHalf = absences[midpoint...]
```

## Test Measurement

We could simply test its behavior by ⬇️

```swift
let points = (0..<100_000).map { CGPoint(x: $0 % 100, y: $0 % 100) }

func testArrSlices() {
    measure {
        _ = points[...]
    }
}

func testArrCopy() {
    measure {
        _ = points
    }
}
```

Result:

```shell
Test Case '-[__lldb_expr_13.MyTestCase testArrCopy]' started.
<unknown>:0: Test Case '-[__lldb_expr_13.MyTestCase testArrCopy]' measured [Time, seconds] average: 0.000, relative standard deviation: 262.929%, values: [0.004014, 0.000099, 0.000048, 0.000041, 0.000041, 0.000038, 0.000038, 0.000084, 0.000066, 0.000046], performanceMetricID:com.apple.XCTPerformanceMetric_WallClockTime, baselineName: "", baselineAverage: , maxPercentRegression: 10.000%, maxPercentRelativeStandardDeviation: 10.000%, maxRegression: 0.100, maxStandardDeviation: 0.100
Test Case '-[__lldb_expr_13.MyTestCase testArrCopy]' passed (0.499 seconds).

Test Case '-[__lldb_expr_13.MyTestCase testArrSlices]' started.
<unknown>:0: Test Case '-[__lldb_expr_13.MyTestCase testArrSlices]' measured [Time, seconds] average: 0.000, relative standard deviation: 51.664%, values: [0.000201, 0.000072, 0.000061, 0.000062, 0.000065, 0.000065, 0.000072, 0.000066, 0.000056, 0.000075], performanceMetricID:com.apple.XCTPerformanceMetric_WallClockTime, baselineName: "", baselineAverage: , maxPercentRegression: 10.000%, maxPercentRelativeStandardDeviation: 10.000%, maxRegression: 0.100, maxStandardDeviation: 0.100
Test Case '-[__lldb_expr_13.MyTestCase testArrSlices]' passed (0.315 seconds).
```

We could find under 10 reference tests, copy array using `0.499s` where ArraySlice using `0.315s`. This is only at the copy part. If you pass this element into function, you will find ArraySlice processing speed is faster than copy array into the function.

## Conclusion

- Use ArraySlice when we wanna recursively processing array element

**Note:** But as doc said:

> To safely reference the starting and ending indices of a slice, always use the startIndex and endIndex properties instead of specific values.

ArraySlice startIndex will change according to current slice indices, so we should always use its `startIndex` & `endIndex` to retrieve the first & last element in the slice.

#### Reference

<https://developer.apple.com/documentation/swift/array>

<https://developer.apple.com/documentation/swift/arrayslice>