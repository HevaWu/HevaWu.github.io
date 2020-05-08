---
layout: post
title: iOS Refresh Rate
date: 2020-05-08 17:07:00
comments: true
disqus_category_id: iOSRefreshRate
categories: [iOS]
tags: [Dispaly]
---

## Display Refresh

Under most case, UIKit handles refrawing and animation, adjusting the frame rate as necessary to provide good viewing experience with reasonable energy usage.

When configure a view animation, we could optionally specify a hint when you know that animation should run at a higher or lower rate.

We could use `CADisplayLink` and set its `preferredFramePerSecond` for an animation. This could help setting the frame rate to any value. The preferred values(rate at which the hardware can adjust the contents of the screen) are show in this graph:

![display_refresh](/images/2020-05-08-iOS-Refresh-Rate/display_refresh.png)

`SpriteKit`, `SceneKit`, `MetalKit` also provide this property on the `SKView`, `SCNView`, `MTKView` classes.

## Frame Rate (iOS and tvOS)

Most apps target frame rate is 60 FPS, equivalent to 16.67 ms per frame. If apps are consistently unable to complete a frame's work within this time should target a lower frame rate to avoid jitter.

> The minimum acceptable frame rate for real-time gaming is `30 FPS`. Lower frame rates are considered a poor user experience and should be avoided. If your app cannot maintain a minimum acceptable frame rate of 30 FPS, you should consider further optimizations or decreased workloads (spending less than 33.33 ms per frame).

## Query and Adjust Frame Rate

We could use `maximumFramesPerSecond` to get the maximum number of frames per second for iOS and tvOS devices.

For iOS devices, this value is usually 60 FPS; for tvOS devices, this value can vary based on the hardware capabilities of an attached screen or the user-selected resolution on Apple TV.

> Using an `MTKView` object is the recommended way to adjust your app’s frame rate. By `default`, the view renders at `60 FPS`; to target a different frame rate, set the view’s `preferredFramesPerSecond` property to your desired value.
>
> A `MetalKit` view always rounds the value of `preferredFramesPerSecond` to the nearest factor of the device’s maximumFramesPerSecond value. If your app cannot maintain its maximum target frame rate (e.g. 60 FPS), then set this property to a lower-factor frame rate (e.g. 30 FPS). Setting the value of `preferredFramesPerSecond` to a non-factor frame rate may produce unexpected results.
>
> Maintaining a target frame rate `requires your app to completely update, encode, schedule, and execute a frame’s work` during the allowed render interval time (e.g. less than 16.67ms per frame to maintain a 60 FPS frame rate).

## Adjust Drawable Presentation Time

Set the maximum target frame rate by `preferredFramesPerSecond`, then simply calling `presentDrawable:` method to maintain a consistent and stable frame rate.

`presentDrawable:` register a drawable presentation to occur as soon as possible. `presentDrawable:afterMinimumDuration:` could use to specify a minimum display time for each drawable, means drawbale presentations occur only after the previous drawable has spent enough time on the display. Which synchronize the drawable's presentation time with the app's render loop.

Here is the relationship between `preferredFramesPerSecond` & `presentDrawable:afterMinimumDuration:`:

```objective-c
view.preferredFramesPerSecond = 30;
/* ... */
[commandBuffer presentDrawable:view.currentDrawable afterMinimumDuration:1.0/view.preferredFramesPerSecond];
```

#### Reference

<https://developer.apple.com/library/archive/documentation/3DDrawing/Conceptual/MTLBestPracticesGuide/FrameRate.html#//apple_ref/doc/uid/TP40016642-CH23>

<https://developer.apple.com/library/archive/documentation/DeviceInformation/Reference/iOSDeviceCompatibility/Displays/Displays.html>