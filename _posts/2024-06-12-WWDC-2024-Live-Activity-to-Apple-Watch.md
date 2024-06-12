---
layout: post
title: WWDC 2024 Live Activity to Apple Watch
date: 2024-06-12 21:50:38
comment_id: 248
categories: [WWDC2024, LiveActivity, watchOS]
---

![](/images/2024-06-12-WWDC-2024-Live-Activity-to-Apple-Watch/liveActivityOnWatch.png)

- From iOS 18 and watchOS 11, iOS Live Activity will appear in the Smart Stack on Apple Watch automatically

In lock screen on iPhone with Dynamic Island, Live Activity shifts to show the `compact leading and trailing views`.

On Apple Watch, these same views are automatically shown in the Smart Stack, along with a title indicating that they were provided by which app.

Updates to the Live Activity on iOS are `automatically` sent to Apple Watch.

- iOS: alert updates animate to display the Dynamic Island `Expanded Views`
- Apple Watch:
  - if it is currently at the watch face, system automatically launches the `Smart Stack`, displays the alert, then show Live Activity
  - if there is an app in the foreground, `banner` displayed at the bottom of the screen with Dynamic Island `compact` views. `Tapping` a Live Activity shows a `full-screen` presentation, `with an option to open the app` on `iPhone`.

```swift
// Existing Live Activity Views
struct DeliveryLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(
            for: DeliveryActivityAttributes.self
        ) { context in
            DeliveryActivityContent(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    DeliveryExpandedLeadingView(context: context)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    DeliveryExpandedTrailingView(context: context)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    DeliveryExpandedBottomView(context: context)
                }
            } compactLeading: {
                DeliveryCompactLeading(context: context)
            } compactTrailing: {
                DeliveryCompactTrailing(context: context)
            } minimal: {
                DeliveryMinimal(context: context)
            }
        }
    }
}

extension DeliveryActivityAttributes.ContentState {
    static var shippedOrder: DeliveryActivityAttributes.ContentState {
        .init(
            status: .shipped,
            courierName: "Johnny"
        )
     }

     static var packedOrder: DeliveryActivityAttributes.ContentState {
         .init(
            status: .packed,
            courierName: "Contacting Courier...")
     }
}

// Preview Live Activities
#Preview(
    "Dynamic Island Compact",
    as: .dynamicIsland(.compact),
    using: DeliveryActivityAttributes.preview
) {
    DeliveryLiveActivity()
} contentStates: {
    DeliveryActivityAttributes.ContentState.packedOrder
    DeliveryActivityAttributes.ContentState.shippedOrder
}
```

## Review app's Live Activity

- Apple Watch displays Dynamic Island compact Views
- Provide relevant and timely information

## Customize for Apple Watch

- Xcode
  - In Canvas Device Settings, can see all View Styles in the Canvas together by selecting by `All Variants`
  - Can go to the select mode and update the Canvas Device Settings to show `Content Smart Stack`
- Add `.supplementalActivityFamilies` to indicate support for the Smart Stack

```swift
// Add .supplementalActivityFamilies
struct DeliveryLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(
            for: DeliveryActivityAttributes.self
        ) { context in
            DeliveryActivityContent(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    DeliveryExpandedLeadingView(context: context)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    DeliveryExpandedTrailingView(context: context)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    DeliveryExpandedBottomView(context: context)
                }
            } compactLeading: {
                DeliveryCompactLeading(context: context)
            } compactTrailing: {
                DeliveryCompactTrailing(context: context)
            } minimal: {
                DeliveryMinimal(context: context)
            }
        }
        .supplementalActivityFamilies([.small]) // here, `.small` to indicate support for the Smart Stack
    }
}

// Customize view layout for `small` activity family
struct DeliveryActivityContent: View {
    @Environment(\.activityFamily) var activityFamily
    var context: ActivityViewContext<DeliveryActivityAttributes>

    var body: some View {
        switch activityFamily {
        case .small:
            DeliverySmallContent(context: context)
        case .medium:
            DeliveryMediumContent(context: context)
        @unknown default:
            DeliveryMediumContent(context: context)
        }
    }
}

// Preview customized layouts for the Smart Stack
#Preview("Content", as: .content, using: DeliveryActivityAttributes.preview) {
   DeliveryLiveActivity()
} contentStates: {
    DeliveryActivityAttributes.ContentState.packedOrder
    DeliveryActivityAttributes.ContentState.shippedOrder
}
```

Note:

- Live Activity work on Apple Watch even the app don't have a Watch App.
- If app does have a Watch App, can also opt-in to open it from a tap on the Live Activity in the Smart Stack
  - In `Build Settings` for the `Watch App` target, add value for `Supports Launch for Live Activity Attribute Types` key in the `Info.plist` section. Leave the value `empty` to launch the Watch app for all app's Live Activities. To launch specific Live Activities, add an item for each `Activity Attributes conforming type` that should launch the Watch app.

## Update frequency

- Updates synchronize to Apple Watch
- Synchronization is budgeted
- Budget threshold is similar to iOS
- High-frequency updates are supported

### Local update budget

- Local iOS updates sent to Apple Watch are budgeted
- Over-budget updates may `not` be processed `immediately`
- Latest available update is shown on `wrist raise`

## Limited connectivity

- Start, end, alerting updates are prioritized
- Smart Stack displays last connected time

## Always on display

- When watch is in Always On mode, system will `auto-switch` the Color Scheme to `dark` and set reduced luminance when people puts their `wrist down`
- Use `isLuminanceReduced` environment value to remove bright elements or reduce their brightness
- Use `preferredColorScheme` to make Live Activity to have light appearance

```swift
// Use isLuminanceReduced to remove bright elements with Always On Display
struct DeliveryGauge: View {
    @Environment(\.isLuminanceReduced) private var isLuminanceReduced
    var context: ActivityViewContext<DeliveryActivityAttributes>

    var body: some View {
        Gauge(value: context.state.progressPercent) {
            GaugeLabel(context: context)
        }
        .tint(isLuminanceReduced ? .gaugeDim : .gauge) // here
    }
}

// For Live Activities with light appearance, use light preferredColorScheme
struct DeliveryActivityContent: View {
    @Environment(\.activityFamily) var activityFamily
    var context: ActivityViewContext<DeliveryActivityAttributes>

    var body: some View {
        switch activityFamily {
        case .small:
            DeliverySmallContent(context: context)
                .preferredColorScheme(.light) // here
        case .medium:
            DeliveryMediumContent(context: context)
        @unknown default:
            DeliveryMediumContent(context: context)
        }
    }
}
```

#### References

- <https://developer.apple.com/wwdc24/10068>
