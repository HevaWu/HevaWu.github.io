---
layout: post
title: Diagnose Performance Issue
date: 2021-04-20 21:44:00
comment_id: 149
categories: [WWDC2020, Xcode]
tags: [Performance]
---

# Scroll **hitches**

> Scroll hitches:
>
> When a rendered frame does not end up on-screen at its expected time

![](/images/2021-04-20-Diagnose-Performance-Issue/frames.png)

- Hitch Time: Time in ms that a frame is late to display
- Hitch Ratio: Hitch time in ms per second for a given duration

$$
\displaystyle
\frac{\text{Hitch time (ms)}}{\text{Scroll duration (s)}} = \text{Hitch rate}
$$

![](/images/2021-04-20-Diagnose-Performance-Issue/level.png)

## Catch Hitches using Performance XCTests

Xcode11 introduce [XCTMatric](https://developer.apple.com/documentation/xctest/xctmetric), which can gather metrics during performance tests.

Inside it, [XCTOSSignpostMetric](https://developer.apple.com/documentation/xctest/xctossignpostmetric) is a metric to record the time a performance tests spends executing a signposted region of code.

- Duration
- Total count of hitches
- Total duration of hitches
- Hitch time ratio
- Frame rate
- Frame count

### Emit an os_signpost interval

- Non-animation interval
  - Custom `os_signpost` with `.begin`
- Animation interval
  - Custom `os_signpost` with `.animationBegin`
  - UIKit instrumented animation interval

```swift
/*
 Create an animation os_signpost interval
 Use `.animationBegin`
*/
os_signpost(.animationBegin, log: logHandle, name: "performAnimationInterval")
os_signpost(.end, log: logHandle, name: "performAnimationInterval")

/*
Use a UIKit instrumented animation os_signpost interval
*/
extension XCTOSSignpostMetric {
     open class var navigationTransitionMetric: XCTMetric { get }
     open class var customNavigationTransitionMetric: XCTMetric { get }
     open class var scrollDecelerationMetric: XCTMetric { get }
     open class var scrollDraggingMetric: XCTMetric { get }
}

// TEST

// Measure scrolling animation performance using a Performance XCTest
func testScrollingAnimationPerformance() throws {
    app.launch()
    app.staticTexts["Meal Planner"].tap()
    let foodCollection = app.collectionViews.firstMatch

    let measureOptions = XCTMeasureOptions()
    measureOptions.invocationOptions = [.manuallyStop]

    measure(metrics: [XCTOSSignpostMetric.scrollDecelerationMetric],
            options: measureOptions) {
        foodCollection.swipeUp(velocity: .fast)
        stopMeasuring()
        foodCollection.swipeDown(velocity: .fast)
    }
}
```

Before Test, change some settings:

- Select performance test target
- Select `Release` build configuration
- Disable `Debugger`
- Disable `Automatic Screenshots`
- Disable `Code Coverage`xXXX$
- Turn off all diagnostic options under `Runtime Sanitization`, `Runtime API Checking`, `Memory Management`

Test screenshot:

![](/images/2021-04-20-Diagnose-Performance-Issue/test.png)

# Disk write diagnostics

> Created when an app performs more than 1 GB of logical writes within 24hrs

#### Reference

- <https://developer.apple.com/wwdc20/10076>
- <https://developer.apple.com/documentation/xctest/xctmetric>
- <https://developer.apple.com/documentation/xctest/xctossignpostmetric>
