---
layout: post
title: Xcode Active Compilation Conditions
date: 2020-02-26 10:13:00
comments: true
disqus_category_id: XcodeActiveCompilationConditions
categories: [Xcode]
tags: [Condition]
---

Most of time, we will only want the code run under a specific environment. ex: BETA, ALPHA, DEBUG, RC, etc. So, how should we control this?

Start from Xcode 8, Apple provide a `Active Compilation Condition` to help setting it.

There are 2 ways to set it:

- Build Settings
- Xcode Build Configuration Files

## Build Settings

The first solution would be using the `Build Settings - Active Compilation Conditions` part. ⬇️

![buildsettings](/images/2020-02-26-Xcode-Active-Compilation-Conditions/buildsettings.png)

## Xcode Build Configuration Files

We all know other than Build Settings, we could also control this by using the configuration files (`xcconfig`). If you have any problems about how to use it, here is a nice [guide](http://www.jontolof.com/cocoa/using-xcconfig-files-for-you-xcode-project/) about how to use Xcode Build Configuration Files into the project.

Inside the Configuration Files, we could add a `SWIFT_ACTIVE_COMPILATION_CONDITIONS` which working same as the `Build Settings - Active Compilation Conditions` one.

You could set it as ⬇️

```swift
SWIFT_ACTIVE_COMPILATION_CONDITIONS = $(inherited) BETA
```

## Note

Don't forget to append the `$(inherited) ` before it. Otherwise, if you are using like `cocoapods` or `carthage` which might contains the compilation conditions settings. It will have conflicts with them 🙁

Please check the follow link:
<https://github.com/CocoaPods/CocoaPods/issues/6625>
