---
layout: post
title: Learning Record of 100 Days of SwiftUI
date: 2021-08-29 21:11:00
comment_id: 189
categories: [SwiftUI, Swift]
---

This will record what I learned from [100 Days of SwiftUI](https://www.hackingwithswift.com/100/swiftui/). I will also use this to track my trial. Here is my practice repo: <https://github.com/HevaWu/100DaysOfSwiftUI>

## Day 16

- `var body: some View`: `some` restrict the it must be `same` kind of view being returned.
- `struct ContentView_Previews: PreviewProvider`: `PreviewProvider` protocol is for Xcode to show preview of UI design of the code
- has limitation of `10` children. For more, use `Group`
- `NavigationView`: add navigation bar to avoid "scrolling content view to the top which overlapped with statusBar"
- `@State`: a property wrapper which allows value store separately by SwiftUI in a place that `can be modified`. It is designed for simple properties stored in one view. Apple recommends give it `private` access control
- `$name`: two way binding(bind text field to show value of property, also bind any changes in text field to update property)

#### Reference

- <https://www.hackingwithswift.com/100/swiftui/>
- My practice repo: <https://github.com/HevaWu/100DaysOfSwiftUI>
