---
layout: post
title: Learning Record of 100 Days of SwiftUI
date: 2021-08-29 21:11:00
comment_id: 189
categories: [SwiftUI, Swift]
---

This will record what I learned from [100 Days of SwiftUI](https://www.hackingwithswift.com/100/swiftui/). I will also use this to track my trial. Here is my practice repo: <https://github.com/HevaWu/100DaysOfSwiftUI>

## Day 37

[Practice Code](https://github.com/HevaWu/100DaysOfSwiftUI/compare/v0.36.0...v0.37.0)

- Set object as `Identifiable`, then in `ForEach`, it will be okay to remove `id:` things, ex: `ForEach(items) {...}`
- `SwiftUI View`: it is okay to put dummy object in `_Preview` part if current View required some variables

## Day 36

[Practice Code](https://github.com/HevaWu/100DaysOfSwiftUI/compare/v0.35.0...v0.36.0)

- `@State` property wrapper
  - useful for simple local to current view data.
  - with `struct` object, everytime binding actually create new `copy`, where SwiftUI notice its change, then update UI.
  - If change this to `class` object, it might not show properly(because with class, SwiftUI can modify its value directly, where the actual property does not change in fact, which means State didn't monitor it). So the values in class does change, but the view isn't being reloaded to reflect the change
  - when we want to share data between views, better to use other property wrappers(ex: `@ObservedObject`, `@EnvironmentObject`)
- `@ObservedObject` property wrapper can help monitoring class variable changes
  - mark var as `@ObservedObject` to tell SwiftUI to watch class changes
  - extend class object as `ObservableObject`, this is because `@ObservedObject` can only be used on types conform to it
  - set class property as `@Published` property observer
- `sheet(isPresented:)`: present another view on top of current one
  - default is card presentation style
  - swipe down can dismiss it
  - dismiss by trigger button: use `@Environment(\.presentationMode)` to attached presentation mode variable stored in app's environment. Then dismiss by calling `presentationMode.wrappedValue.dismiss()`
    - `@Environment` create properties which store values like: light or dark mode, smaller or larger fonts, timezone, etc.
    - `wrappedValue` is required. because `presentationMode` is actually a binding that can be updated automatically by system
- `onDelete(performed: { indexSet in })` in `List { ForEach }` to provide delete row function
  - `onDelete()` only exist in `ForEach`
  - `IndexSet` tell position of all items in ForEach that should be removed. It's like a set of integers, which its sorted
- `.navigationBarItems(leading: EditButton())` show Edit/Down button to navigation bar
- `UserDefaults`: store small amount of user data(better be no more than 512KB)
  - the data stored there will automatically be loaded when app launches.
  - store user settings and important data
  - `UserDefaults.standard` a built-in instance of UserDefaults

## Day 35

[Practice Code](https://github.com/HevaWu/100DaysOfSwiftUI/compare/v0.34.0...v0.35.0)

- `ForEach`
  - input range is `Range<Int>`, `NOT ClosedRange<Int>`
- `resizable()` to make `Image` View fit its space

## Day 34

[Practice Code](https://github.com/HevaWu/100DaysOfSwiftUI/compare/v0.33.0...v0.34.0)

- `offset()` modifier used to move a view relative to its natural position

## Day 33

[Practice Code](https://github.com/HevaWu/100DaysOfSwiftUI/compare/v0.32.0...v0.33.0)

- can attach `multiple animation()` modifiers but the order matters
- can disable animation by setting `.animation(nil)`
- Gesture have `onChanged()` and `onEnded()` action block
- `transition()` modifier could help apply transitions to view
  - `.scale` to scale up and down
  - `.asymmetric` to add separate transition of show the view and disappear a view
- `UnitPoint` type for controlling anchor, to specify exact X/Y for rotation or use builtin options: `.topLeading`, `.bottomTrailing`, etc
- `extension AnyTransition { static var }` to add custom transition

## Day 32

[Practice Code](https://github.com/HevaWu/100DaysOfSwiftUI/compare/v0.31.0...v0.32.0)

- `.scaleEffect` to apply scale effect
- `.animation(.default)` to apply default animation, which is "ease in, ease out" animation
  - `Animation.interpolatingSpring` for bouncing
  - `Animation.easeInOut.delay` to apply delay time on animation
  - can also set `repeatCount(,autoreverses)`, `repeatForever(autoreverses)` to repeat animation
  - repeat setting will trigger `onAppear()`
- can apply `animation()` for `binder`, this will add bind animations.
  - This will do implicitly animations.
    - this one `not` set animation on View and animate it with state change. (state change don't know it trigger animation)
    - this one set nothing on view and explicitly with a state change. (view don't know it will be animated)
- `rotation3DEffect` define 3 axis amount to determine how view rotate
- `withAnimation()` can define an animation

## Day 31

[Practice Code](https://github.com/HevaWu/100DaysOfSwiftUI/compare/v0.30.0...v0.31.0)

- Place 2+ views in `List row` will create implicit `HStack`

## Day 30

[Practice Code](https://github.com/HevaWu/100DaysOfSwiftUI/compare/v0.29.0...v0.30.0)

- `TextFiled`
  - `textFiledStyle()` to update style
  - `onCommit:` to set function when user press return on the keyboard
  - `autocapitalization()` to set capitalization
- `NavigationView`
  - `onAppear` to set which function run when view is shown

## Day 29

[Practice Code](https://github.com/HevaWu/100DaysOfSwiftUI/compare/v0.28.0...v0.29.0)

- `List` provide scrolling table of database
  - use `listStyle` to modify its view styles
  - `List` can dynamically adding rows without `ForEach`. ex: `List(0..<5) { _ in ... }`
  - use `id: \.self` to quick map each data, same as `ForEach`
- Use `UITextChecker` to help checking misspelled word
  - call `rangeOfMisspelledWord(in:range:startubgAt:wrap:language:)` to check it find any. It send back another Objective-C string range. If there is some, return range. If not, return `NSNotFound`
- `UTF-16` is character encoding, it is useful to let objective-c to understand how Swift's string stored, which is nice binding format to connect the two
  - The `UTF-16` code units of a string’s utf16 view match the elements accessed through indexed `NSString` APIs

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
