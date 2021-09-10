---
layout: post
title: Learning Record of 100 Days of SwiftUI
date: 2021-08-29 21:11:00
comment_id: 189
categories: [SwiftUI, Swift]
---

This will record what I learned from [100 Days of SwiftUI](https://www.hackingwithswift.com/100/swiftui/). I will also use this to track my trial. Here is my practice repo: <https://github.com/HevaWu/100DaysOfSwiftUI>

## Day 28

[Practice Code](https://github.com/HevaWu/100DaysOfSwiftUI/compare/v0.27.0...v0.28.0)

- `trailing` shown on the right in `left-to-right` languages, it will be automatically flipped for `right-to-left`

## Day 27

[Practice Code](https://github.com/HevaWu/100DaysOfSwiftUI/compare/v0.26.0...v0.27.0)

- Use `.navigationBarItems(trailing:)` to add right bar button item at navigationBar
- Use `static var` variable if we want to set one `@State` variable's default value
- Use `WheelDatePickerStyle()` to present DatePicker as wheel style

## Day 26

[Practice Code](https://github.com/HevaWu/100DaysOfSwiftUI/compare/v0.25.0...v0.26.0)

- Use of `Stepper`: -+ button tapped to control increment and decrement
- Use `DatePicker` to bind date property
  - `displayComponents` to define which want to display
  - `Form + DatePicker` clean format
  - `in:` to define Date range

## Day 25

[Practice Code](https://github.com/HevaWu/100DaysOfSwiftUI/compare/v0.24.0...v0.25.0)

- `VStack`, `Group`, `ForEach` are all views in SwiftUI
- `primitive views`, building blocks of SwiftUI, which conform to View but return some fixed content rather than rendering some other kind of view instead. ex: `Text`, `Image`, `Color`, `Spacer` and more
- `ForEach`: loop over item by id -> `ForEach(arr, id: \.self) { ... }`
- Use `Identifiable` protocol to identify views
- Use `: Binding<>()` to add custom bindings

## Day 24

[Practice Code](https://github.com/HevaWu/100DaysOfSwiftUI/compare/v0.23.0...v0.24.0)

- SwiftUI use `struct` for Views. use class might not compile

## Day 23

[Practice Code](https://github.com/HevaWu/100DaysOfSwiftUI/compare/v0.22.0...v0.23.0)

- SwiftUI use `struct` for Views. functional design.
- `UIHostingController`: bridge between UIKit and SwiftUI.
- modifier order is important.
  - `type(of:)` prints exact type of particular value.
  - `ModifiedContent`: once we apply one modifier, stack up `ModifiedContent<ModifiedContent<...>>`
- use `some View`: `opaque` return types
  - one specific type that conforms to `View` protocol
  - always return same type of View
  - compiler know what view type is back, even we don't known
  - `VStack` makes SwiftUI creates `TupleView<T>` which wrote to handle at most 10 types views. That's why SwiftUI cannot handle more than 10 views
- `ternary operator`: can be used as condition checking
- `environment modifier`: can apply to all container views
  - ex: `font` is `environment` modifier which can be overridden, `blur` is `regular` modifier which cannot replace child view's setting
- okay to create view as property. But cannot create one property refers to other stored properties, ex: a `TextFiled` bound to local property which will cause problem
- okay to resemble view in SwiftUI. It's also okay to define custom container.
- use `ViewModifier` to define custom modifier. And call it by `.modifier`

## Day 22

[Practice Code](https://github.com/HevaWu/100DaysOfSwiftUI/compare/v0.21.0...v0.22.0)

- Decorative images are not read by the screen reader.
- Semantic colors are named according to the use. ex: `Color.primary` might be light or dark depending on device theme
- `Color` are `views` in SwiftUI

## Day 21

[Practice Code](https://github.com/HevaWu/100DaysOfSwiftUI/compare/v0.20.0...v0.21.0)

- `Image.renderingMode(.original)` render original image
- `font`, `fontWeight` modifier of Text view
- `clipShape` modifier to use built in shape, ex: rectangle, rounded rectangle, circle, capsule
- `overlay()` modifier to drawing above previous
- `shadow()` modifier to apply shadow effect
## Day 20

[Practice Code](https://github.com/HevaWu/100DaysOfSwiftUI/compare/v0.19.0...v0.20.0)

- `HStack`, `VStack`, `ZStack` for horizontal, vertical, zepth stack. Has limitation of maximum of 10 children. If we want to add more, use `Group`
- `Color`, can use `frame()` modifier to change specific sizes
- Use `edgesIgnoringSafeArea(.all)` modifier ignore the safeArea insets
- `LinearGradient`, `RadialGradient`, `AngularGradient(Conic gradient)`
- `Button(action:label:)` can help add customize Button design
- `Image`
  - `Image("pencil")`: load image already added in project
  - `Image(decorative: "pencil")`: load image added in project, but not read it out for screen reader user
  - `Image(systemName: "pencil")`: load image embedded in iOS, use Apple's SF Symbols
- Use `Alert` to add one alert. Also can use `Button(){}.alert()` to define when should we show alert. It will be run when `isPresented` condition is true.

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
