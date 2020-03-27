---
layout: post
title: The Problem When Upgrade to use Xcode 11 GM
date: 2019-09-17 13:56:00
comments: true
disqus_category_id: TheProblemWhenUpgradeToUseXcode11GM
categories: [Xcode, Swift]
tags: [Xcode11, Upgrade]
---

When I tried to update to use Xcode 11 GM, there are some problems I met. And I want to share the problems and solutions.

**Note**:

For each problem, I only post the solutions work to me. But I cannot say it will also working for your case. If it is not working, please try to search other solution TOT

## Problem 1: Module compiled with Swift 5.0.1 cannot be imported by the Swift 5.1 compiler

For some libraries, it shows this error, and it looks like they are remind you to use `Swift5.1`. But we are know that Swift5.1 is even not released yet. So why this error happen?

Actually, after downloading Xcode 11, before you build your project, you should

- Clean Build Folder
- Run your script again (<- ex: Cocoapods, Carthage, etc)

Then, run again!

This error is disappearing!!! :tada:

## Problem 2: Some pod libraries not updated

Actually, this is not the Xcode 11 problem, but if you use some third-party libraries, you might need to also update the pod for them.
(If they have already update their project path)

So, this is kind of the solution to upgrade target Pod. In fact, since we are fork the 3rd party libraries, and add our customized tag on it. Everytime, we need to manually add the customize tag & try to check it. But, for sometime, current tag might still have problem, and we need to update its content. As we all know, when you update the content, actually you need to update the Pod again. And the Pod cannot detect the `content changing`. You have to manually update it. Here is the step:

- Clean Pod Cache: `pod cache clean`
- Remove your project Pod related files: `rm -rf Podfile.lock Pods`
- Re-install the Pod again: `pod install`

Then, try again!

This problem is solved!!! :tada:

## Problem 3: Command CompileSwift with a nonzero exit code

For my case, since we are using `sub-project`, there are some places we should be careful to set. For solve this:

- Go to the error project -> Build Settings -> Swift Complier - Code Generation -> Compilation Mode (Remove Debug part `Incremental` things, you could also set it to `Whole Module`)

Then, try again!

This problem is solved!!! :tada:

## Problem 4: Command PhaseScriptExecution failed with a nonzero exit code

Actually the problem I met is:

```shell
“${PODS_ROOT}/SwiftLint/swiftlint” causes “Command PhaseScriptExecution failed with a nonzero exit code”
```

One of the solution is:

- Open `Build Phase` -> Remove SwiftLint Script

But for sometimes, we might still want to use SwiftLint, and we need to add it back. Actually, it is the SwiftLint new version issue.

<https://github.com/realm/SwiftLint/issues/2793>

For me,

- change to use SwiftLint 0.34.0 will solve this

## Sum up

So these are all of the problems and solutions I met when upgrade to use Xcode 11 GM. Hope this could help someone. :smile:
