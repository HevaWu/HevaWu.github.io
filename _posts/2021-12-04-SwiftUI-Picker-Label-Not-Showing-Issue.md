---
layout: post
title: SwiftUI Picker Label Not Showing Issue
date: 2021-12-04 23:13:00
comment_id: 200
categories: [Swift]
tags: [SwiftUI, Picker]
---

When I try to code with Picker, I just realize Picker Label is not showing now.

![](/images/2021-12-04-SwiftUI-Picker-Label-Not-Showing-Issue/as-is.png)

It only show me the menu, but without showing any Label of it.

My Env:

```sh
Xcode: 13.1
Simulator: iPhone 12 Pro Max - iOS 15.0
```

This should be an known issue on Apple, here is someone's report: <https://developer.apple.com/forums/thread/688518>

## Temporary Solution

So far, my handling is use `HStack` to show my label ⬇️

```swift
HStack {
    Text("Sort By")
        .foregroundColor(.blue)

    Picker(
        selection: $selectedSortType,
        content: {
            ForEach(sortType, id: \.self) { type in
                Text(type.rawValue)
            }
        },
        label: {
            Text("Sort By")
        }
    )
}
```

![](/images/2021-12-04-SwiftUI-Picker-Label-Not-Showing-Issue/fix.png)

Hope they will fix this soon 😢

#### Reference

- <https://developer.apple.com/forums/thread/688518>
