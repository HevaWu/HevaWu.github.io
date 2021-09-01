---
layout: post
title: Learning Record of 100 Days of SwiftUI
date: 2021-08-29 21:11:00
comment_id: 189
categories: [SwiftUI, Swift]
---

This will record what I learned from [100 Days of SwiftUI](https://www.hackingwithswift.com/100/swiftui/). I will also use this to track my trial. Here is my practice repo: <https://github.com/HevaWu/100DaysOfSwiftUI>

## Day 19

[Practice Code](https://github.com/HevaWu/100DaysOfSwiftUI/compare/v0.18.0...v0.19.0)

- Swift have default [Measurement](https://developer.apple.com/documentation/foundation/measurement) instance to support unit conversion
- use `.symbol` to get one Measurement Unit string

## Day 18

[Practice Code](https://github.com/HevaWu/100DaysOfSwiftUI/compare/v0.17.0...v0.18.0)

- All SwiftUI views must inherit from `View` protocol.
- views must contain at least one computed property which is `body`. It can also contain more if we want.
- `Form`s can scroll
- When `@State` property changes, Swift re-invoke `body` property. This forces all values inside the body to be re-evaluated, making sure they are updated for the changes.

## Day 17

[Practice Code](https://github.com/HevaWu/100DaysOfSwiftUI/compare/v0.16.0...v0.17.0)

- `.keyboardType()`: can specify type of keyboard, but user still can input other values by copy/paste.
- Add `NavigationView` outside to make sure `Picker` view can be pushed
- `.navigationBarTitle` NOT add directly end of NavigationView, because navigation views are capable of showing many views when program runs. Attach title to the object inside NavigationView can make code change title freely.
- `Section(header:)` could help define Section header, same for footer
- `.pickerStyle` could help switch Picker style
- `"$\(totalPerPerson, specifier: "%.2f")"`: use `specifier` ([C-style format string](https://en.wikipedia.org/wiki/Printf_format_string)) to help control floating point.

## Day 16

[Practice Code](https://github.com/HevaWu/100DaysOfSwiftUI/releases/tag/v0.16.0)

- `var body: some View`: `some` restrict the it must be `same` kind of view being returned.
- `struct ContentView_Previews: PreviewProvider`: `PreviewProvider` protocol is for Xcode to show preview of UI design of the code
- has limitation of `10` children. For more, use `Group`
- `NavigationView`: add navigation bar to avoid "scrolling content view to the top which overlapped with statusBar"
- `@State`: a property wrapper which allows value store separately by SwiftUI in a place that `can be modified`. It is designed for simple properties stored in one view. Apple recommends give it `private` access control
- `$name`: two way binding(bind text field to show value of property, also bind any changes in text field to update property)

#### Reference

- <https://www.hackingwithswift.com/100/swiftui/>
- My practice repo: <https://github.com/HevaWu/100DaysOfSwiftUI>
