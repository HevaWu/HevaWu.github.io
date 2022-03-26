---
layout: post
title: SwiftUI Image Cause System Run out of Memory Issue
date: 2021-11-24 22:36:00
comment_id: 199
categories: [Swift]
tags: [SwiftUI, Memory]
---

PC env:

```
macOS Monterey 12.0.1
Memory 16GB
Storage 512GB
Xcode 13.1
Simulator: iPhone 12 Pro Max OS15.0
```

When I try some SwiftUI practice, I was run into a `Your system has run out of application memory.` issue. And it freeze my pc.

![](/images/2021-11-24-SwiftUI-Image-Cause-System-Run-out-of-Memory-Issue/force_quit.png#simulator)

I was first think if there is any problem on my Xcode env, so I tried delete -> reinstall Xcode, restart PC, clean storage etc. But all of them not work(Once I launch Xcode and try to build my code, PC starts freezing).

After checking the CPU and memory, I notice once I start building, the CPU and memory keep increasing, the high peak even take `60GB` `SouceKitService` and `45GB` `swift-frontend` in the memory!!!!!!!!! That is really a big problem, even I manually shut it down, it still increase and increase.

![](/images/2021-11-24-SwiftUI-Image-Cause-System-Run-out-of-Memory-Issue/cpu.png#simulator)

![](/images/2021-11-24-SwiftUI-Image-Cause-System-Run-out-of-Memory-Issue/memory.png#simulator)

Then I searched some person mentioned, they [got this issue at the `Image` code](https://www.reddit.com/r/SwiftUI/comments/qj4qtd/sourcekitservice_runaway_ram_usage/). OK! That remind me, my pc issue does happen after I add some code on `SwiftUI Image` part!! So, I back to my code, comment out my changes, then, all cpu and memory take properly now!

It might really hard to notice this is a code leak there. But it gives me one hint that, I should think again when it starts got issue.

## Problem Code part

```swift
GeometryReader { geo in
    List(usedWords, id: \.self) { word in
        GeometryReader { wordGeo in
            HStack {
                Image(systemName: "\(word.count).circle")
                /// ⚠️⚠️⚠️THIS .foregroundColor() is the PROBLEM PART⚠️⚠️⚠️
                    .foregroundColor(
                        Color(
                            red: wordGeo.frame(in: .global).minY % geo.size.height,
                            green: 1 - (wordGeo.frame(in: .global).minY % geo.size.height),
                            blue: 0.5 * (wordGeo.frame(in: .global).minY % geo.size.height))
                    )
                Text(word)
            }
            .offset(x: max(0, wordGeo.frame(in: .global).minY + wordGeo.size.width - geo.frame(in: .global).maxY))
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(Text("\(word), \(word.count) letters"))
        }
    }
}
```

## Fixing

I fixed the issue by using `Double` and double check my logic to be sure only set 0-1 point values to it. Here is my fixing code, change `.foregroundColor` part as:

```swift
.foregroundColor(
    Color(
        red: Double(Int(wordGeo.frame(in: .global).minY) % Int(geo.size.height)) / Double(geo.size.height),
        green: Double(1 - Double(Int(wordGeo.frame(in: .global).minY) % Int(geo.size.height)) / Double(geo.size.height)),
        blue: Double(0.5 * Double(Int(wordGeo.frame(in: .global).minY) % Int(geo.size.height)) / Double(geo.size.height))
    )
)
```

#### Reference

- <https://www.reddit.com/r/SwiftUI/comments/qj4qtd/sourcekitservice_runaway_ram_usage/>
- My practice code: <https://github.com/HevaWu/100DaysOfSwiftUI/compare/v0.93.0...v0.94.0>
