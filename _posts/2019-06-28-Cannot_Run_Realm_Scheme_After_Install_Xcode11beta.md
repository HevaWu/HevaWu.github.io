---
layout: post
pagination:
  enabled: true
  categories: Test
  tags: Test
title: Cannot Run `Realm` Scheme After Install Xcode11 beta
date: 2019-06-28 11:53:00
comments: true
disqus_category_id: CannotRunRealmSchemeAfterInstallXcode11Beta
categories: [iOS, WWDC2019, API Design, Swift]
tags: [iOS, WWDC2019, API Design, Swift]
---

## Description
This happens because I installed both Xcode 10 & Xcode 11 beta. Also, I installed the required components after installing Xcode 11 beta.
After installing Xcode 11 beta, when we try to run application, it shows an error.
For my case, `beta` works well, `real` build successful but Xcode show an error `The Application's Info.plist Does Not Contain CFBundleVersion`.

## Reason
Reference: https://stackoverflow.com/questions/56450295/cannot-run-application-on-simulator-after-installing-xcode-11-cfbundleversion
> The issue here is that the new version of CoreSimulator.framework with Xcode 11 beta does validation on CFBundleVersion that previous versions did not do. These checks are valid, and it does represent an issue in your application, but there's also a bug in how the checks were performed in Xcode 11 Beta 1 which compounds the issue.

## Solution
For my case, the `CFBundleVersion` shows correctly.
And `killall -9 CoreSimulatorBridge` doesn't works for me.

What I'm trying to do is:
1. Quit Xcode & Simulator
2. Remove `/Library/Developer`
3. Relaunch Xcode 10, and it works well.

After relaunching it works well now. 🎉