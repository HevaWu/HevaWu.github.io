---
layout: post
title: Swift Debug Assert
date: 2019-09-20 14:36:00
comments: true
disqus_category_id: SwiftDebugAssert
categories: [Swift, Debug]
tags: [Assert]
---

I just notice Swift has this function, which could stop the project when condition is failed.

> assert(_:_:file:line:)

Let's check its documentation.

> Performs a traditional C-style assert with an optional message.

OK. From this description, we might still confused what its saying.

In the bottom discussion part, Apple explained for us:

> Use this function for internal sanity checks that are active during testing but do not impact performance of shipping code. To check for invalid usage in Release builds, see precondition(_:_:file:line:).

So actually it will only showed under `Debug` build, which not have influence on our `Real` build. If we also want to show it on `Real` build, we could use `precondition(_:_:file:line:)`

Also under this discussion, Apple listed all bild types:

> - In playgrounds and -Onone builds (the default for Xcode’s Debug configuration): If condition evaluates to false, stop program execution in a debuggable state after printing message.
> - In -O builds (the default for Xcode’s Release configuration), condition is not evaluated, and there are no effects.
> - In -Ounchecked builds, condition is not evaluated, but the optimizer may assume that it always evaluates to true. Failure to satisfy that assumption is a serious programming error.

And we could see `assert(_:_:file:line)` condition part is said it will only evaluated in playgroud and *-Onone* builds.

And *-Onone* builds is:
default for Xcode's Debug configuation

So we could use it safely in our code :smile:

#### Reference
https://developer.apple.com/documentation/swift/1541112-assert