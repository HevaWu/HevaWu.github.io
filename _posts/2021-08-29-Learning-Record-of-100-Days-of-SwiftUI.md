---
layout: post
title: Learning Record of 100 Days of SwiftUI
date: 2021-08-29 21:11:00
comment_id: 189
categories: [SwiftUI, Swift]
---

This will record what I learned from [100 Days of SwiftUI](https://www.hackingwithswift.com/100/swiftui/). I will also use this to track my trial. Here is my practice repo: <https://github.com/HevaWu/100DaysOfSwiftUI

## Day 81
[Practice Code](https://github.com/HevaWu/100DaysOfSwiftUI/compare/v0.80.0...v0.81.0)

- use `contextMenu()` to show attach context menu
  - when user press hard on it, it will show some views
  - each item in context menu can have one text and one image attached
  - always be `text first then image` (no matter order we type it)

## Day 80
[Practice Code](https://github.com/HevaWu/100DaysOfSwiftUI/compare/v0.79.0...v0.80.0)

- `String(decoding: data, as: UTF8.self)` to convert Data to a string
- `objectWillChange`, a publisher
  - `ObservableObject` will automatically gain this property
  - notifies view that are observing the object that something important has changed
  - will be triggered immediately before make change
  - call like `objectWillChange.send()`
- `interpolation()` to control how pixel blending is applied
  - `.none` will turn off image interpolation entirely. (rather than blending, it will scale up small image with sharp edges)

## Day 79

[Practice Code](https://github.com/HevaWu/100DaysOfSwiftUI/compare/v0.78.0...v0.79.0)

- `@EnvironmentObject`: place an object into the environment so that any child view can automatically have access to it
  - when `push` view, environment will be shared
  - when `present` view, not automatically shared data, Apple will change in the future
  - it will automatically look for corresponding instance, if it cannot find, it will crash
    - ex: `@EnvironmentObject var user: User`, it will look for User
  - `.environmentObject` to specify corresponding environment object
- `TabView` show tabBar
  - attach `.tabItem()` to each view inside TabView. For customize way the view shown in the tabBar
  - in `tabItem`, SwiftUI always show no more than one image and no more than one text view(even add more image and text view, it doesn't matter)
  - programmatically control TabView current view(switch tab)
    - use `@State` to track current selected tab, modify this property to new value to switch, pass this as binding and tell SwiftUI which tab should be shown
    - `TabView(selection:)` to bind with selected property
    - use `tag` as tab identifier (recommend use `String` rather than int identifier for this to help better understanding each tab's work)

## Day 78

[Practice Code](https://github.com/HevaWu/100DaysOfSwiftUI/compare/v0.77.0...v0.78.0)

- use `CLLocationManager` to help fetching current user's location
  - `requestWhenInUseAuthorization`
  - `startUpdatingLocation`
  - `locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])`

## Day 77

[Practice Code](https://github.com/HevaWu/100DaysOfSwiftUI/compare/v0.76.0...v0.77.0)

- add `@propertyWrapper` before a struct, to define custom property wrapper
- `.jpegData()` to save image as jpeg format
  - `compressionQuality`: range from 0(low quality) to 1(high quality). Normally pick 0.8

## Day 76

[Practice Code](https://github.com/HevaWu/100DaysOfSwiftUI/compare/v0.75.0...v0.76.0)

- use `accessibilityAdjustableAction` to adjust increment and decrement of Stepper
  - add `accessibilityElement(children: .ignore)` and `accessibilityValue` to read Stepper value

## Day 75

[Practice Code](https://github.com/HevaWu/100DaysOfSwiftUI/compare/v0.74.0...v0.75.0)

## Day 74

[Practice Code](https://github.com/HevaWu/100DaysOfSwiftUI/compare/v0.73.0...v0.74.0)

- use `.accessibility(label:)` and `.accessibility(hint:)` to control what VoiceOver reads
- use `.accessibilityAddTraits(.isButton)` to provide extra behind scenes information to VoiceOver to describes how view works
  - similarly, have `accessibilityRemoveTraits()`
- `Image(decorative:)` tell SwiftUI it should be ignored by SwiftUI
  - it will not read out the image's filename as the automatic VoiceOver label. If we add label or a hint that will be read
  - can use `.accessibilityHidden()` to make view completely invisible to the accessibility system
- `accessibilityElement(children: .combine)` apply this to parent view can combine its children into a single accessibility element
  - `combine` will have a pause between two pieces of text
  - use `accessibilityElement(children: .ignore)` + `accessibilityLabel(Text)` is more natural way, text will read all at once

## Day 73

[Practice Code](https://github.com/HevaWu/100DaysOfSwiftUI/compare/v0.72.0...v0.73.0)

- `italic` text was first used in Venice in 1500.

## Day 72

[Practice Code](https://github.com/HevaWu/100DaysOfSwiftUI/compare/v0.71.0...v0.72.0)

- add `completeFileProtection` options when write data to fileManager, to make file accessable only while device is unlocked

## Day 71

[Practice Code](https://github.com/HevaWu/100DaysOfSwiftUI/compare/v0.70.0...v0.71.0)

- `+` to add text views together
  - this can create larger text views that mix and match different kind of formatting
- use `.italic` to show text with italic

## Day 70

[Practice Code](https://github.com/HevaWu/100DaysOfSwiftUI/compare/v0.69.0...v0.70.0)

- to add pin on the MapView in SwiftUI
  - use Binding to bind centerCoordinator
  - add annotations property to record current map annotations
- `mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?`
  - `dequeueReusableAnnotationView(withIdentifier:)` to try reuse view
  - `annotationView.canShowCallout = true` to show the call out
    - for showing it, `annotation must have a title`
  - `annotationView.rightCallOutAccessoryView` can customize call out view to show more information
  - `.detailDisclosure` Swift Button style, show button like an "i" with a circle around it
- `mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl)` to update call out view for one annotation
  - `calloutAccessoryControlTapped` get called when button is tapped

## Day 69

[Practice Code](https://github.com/HevaWu/100DaysOfSwiftUI/compare/v0.68.0...v0.69.0)

- `UIViewRepresentable` as wrap of a UIView
  - `makeUIView()` and `updateUIView()` to handle instantiating and updating of a view when a SwiftUI state changes
  - UIViewRepresentable `Context` equal to `UIViewRepresentable<Self>`
- `MKMapView` to show the map
  - `import MapKit`
  - `mapViewDidChangeVisibleRegion` delegate func check when map is zoom, rootate, moves
  - `MKPointAnnotation` to display annotations
  - `mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation)` to customize annotation mark
  - `MKPinAnnotationView` one of Apple annotation view design
    - set `canShowCallOut = true` means tap the pin shows information then send it back
- FaceID unlock
  - `import LocalAuthentication`
  - `LAContext` to query biometric status and perform authentication check
    - use `canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics` and `evaluatePolicy()` to evalute user's biometric data
  - for simulator, use `Feature -> FaceID -> Enrolled` to enable simulator faceID. use `MatchingFace` or `Non-matching face` to test fetch result

## Day 68

[Practice Code](https://github.com/HevaWu/100DaysOfSwiftUI/compare/v0.67.0...v0.68.0)

- `FileManager` to find document direcrtory of current user
  - when app deleted, this directory will automatically deleted
  - no physical limitation, but user can check it at Settings app
  - ex: `FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)`
- use `write(to:)` to write data
  - use `String(contentsOf:)` and `Data(contentsOf:)` to read data
  - `atomic` writing data
    - system write full file to temporary filename, and when its finished it does a rename to target filename
    - either whole file is there, or nothing is
    - this is safer, otherwise, if we set atomic as false, it might cause problem that: when reading data, writing might not finish yet, so only read part of data

## Day 67

[Practice Code](https://github.com/HevaWu/100DaysOfSwiftUI/compare/v0.66.0...v0.67.0)

- `@objc` attribute lets Objective-C code call a Swift method
- can place optional views directly into SwiftUI View hierarchy
  - SwiftUI will only render them if they have a value
- reuse `CIContext` is good for performance

## Day 66

[Practice Code](https://github.com/HevaWu/100DaysOfSwiftUI/compare/v0.65.0...v0.66.0)

- use `filter.inputKeys.contains` to check if a filter key should be assigned for this filter

## Day 65

[Practice Code](https://github.com/HevaWu/100DaysOfSwiftUI/compare/v0.64.0...v0.65.0)

- `context.createCGImage(output, from: output.extent)`:
  - use `output.extent` to get proper rect property
- for filter, use `setValue()` would be safer
- use `Binding<Double>` to bind filter param with user interface

## Day 64

[Practice Code](https://github.com/HevaWu/100DaysOfSwiftUI/compare/v0.63.0...v0.64.0)

- SwiftUI Coordinator
  - design to act as delegate for UIKit view controllers
  - `class Coordinator`, has to be class
  - implement `makeCoordinator()` to create and configure Coordinator instance
  - `xx.delegate = context.coordinator`, don't call makeCoordinator(), SwiftUI will automatically call and associate coordinator. When makeUIViewController() and updateUIViewController() calls, automatically pass the coordinator object
  - `class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate`:
    - `NSObject`: allows objective-c to ask object what functionality it supports at runtime
    - `UIImagePickerControllerDelegate`: NSObject let objective-c check for the functionality, this protocol is waht actually provide it
    - `UINavigationControllerDelegate`: detect when user move between screens
  - add property and environment in struct, then in Coordinator class, update the property inside delegate function
  - in where we call the view, use property to update the view UI components
- save image to photo
  - UIKit use `UIImageWriteToSavedPhotoAlbum()`
  - SwiftUI can use a class to wrapper and implement #selector function to it

## Day 63

[Practice Code](https://github.com/HevaWu/100DaysOfSwiftUI/compare/v0.62.0...v0.63.0)

- image types
  - `UIImage`, form UIKit, capable of variety of image types, including bitmaps(like PNG), vectors(like SVG), even sequences form an animation
  - `CGImagae`, from Core Graphics, 2D array of pixels
  - `CIImage`, from Core Image, store all information required to produce an image but doesn't actually turn that into pixels unless it's asked to. an "image recipe"
- CoreImage filter: `import CoreImage.CIFilterBuiltins`
  - sepial filter: `CIFilter.sepiaTone()`, intensity is between 0(original image) to 1(full sepia)
  - pixellation filter: `CIFilter.pixellate()`, sclae = 100 means pixels are 100 points across
  - crystal effect: `CIFilter.crystallize`
  - also can set input image for a filter by using `kCIInputImageKey`
  - `CIVector` is CoreImage's way of storing points and directions
  - Read output image in SwiftUI: CIImage -> CGImage -> UIImage -> Image
- wrap UIKit view controller
  - extend a struct from `UIViewControllerRepresentable`, which build on `View`
  - implement `makeUIViewController()` and `updateUIViewController()`

## Day 62

[Practice Code](https://github.com/HevaWu/100DaysOfSwiftUI/compare/v0.61.0...v0.62.0)

- @State
  - `@propertyWrapper` attribute allow make State of struct
  - have a `wrappedValue`, which is actual value SwiftUI trying to store
- `Binding<Value>` to make new binding object
  - can be used to observing @State element changes
  - init need `get: {}, set: {}`
  - both get and set are `@escaping`, Binding struct stores them for use later on
- use `actionsheet()` to show ActionSheet
  - style of buttons: `default()`, `cancel()`, `destructive()`
  - usage similar to alert

## Day 61

[Practice Code](https://github.com/HevaWu/100DaysOfSwiftUI/compare/v0.60.0...v0.61.0)

- use `PersistenceController.shared.container.performBackgroundTask` to keep updating concurrently
  - Apple CoreData Concurrency Guide: <https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/CoreData/Concurrency.html>

## Day 60

[Practice Code](https://github.com/HevaWu/100DaysOfSwiftUI/compare/v0.59.0...v0.60.0)

- `AnyView` vs `Group`
  - both can contains different type of views inside its closure
  - array type
    - `[Group]`, SwiftUI can't make this type, because it is no meaning, SwiftUI want to know what's in the group
    - `[AnyView]` is okay, because AnyView is the contents
- define `decoder.keyDecodingStrategy = .convertFromSnakeCase` can tell Swift to convert snake case to and from camel case.

## Day 59

[Practice Code](https://github.com/HevaWu/100DaysOfSwiftUI/compare/v0.58.0...v0.59.0)

- fetch requests can be created by using `@FetchRequest` or `FetchRequest` struct

## Day 58

[Practice Code](https://github.com/HevaWu/100DaysOfSwiftUI/compare/v0.57.0...v0.58.0)

- provide `NSPredicate` in `@FetchRequest` to control which results should be shown
  - use `%@` means "insert some data here"
    - "IN", "BEGINSWITH"(case sensitive), "BEGINSWITH[c]"(ignore the case), "CONTAINS[c]", "NOT", "AND"
  - `NSCompoundPredicate` to build one predicate out of several smaller ones
- Dynamically update FetchRequest
  - okay to set `var fetchRequest: FetchRequest<T>`
  - use `fetchRequest.wrappedValue` property to get fetchedResult
  - For filter in any field
    - use `%K` for specify filter key, insert value but not add extra quote mark around
    - use `%@` will add extra quote mark
    - ex:
      - `"%@ BEGINSWITH %@", lastName, S` == `"'lastName' BEGINSWITH 'S'"`
      - `"%K BEGINSWITH %@", lastName, S` == `"lastName' BEGINSWITH 'S'"`
- CoreData Relationships
  - 4 forms: 1 to 1, 1 to many, many to 1, many to many
  - convert `NSSet` to `Set<>`, use Swift native type

## Day 57

[Practice Code](https://github.com/HevaWu/100DaysOfSwiftUI/compare/v0.56.0...v0.57.0)

- `\.self` to identify whole object
  - Swift compute **hash value** of the object
  - `\.self` works for anything conform to `Hashable`
- Core Data generate object ID sequentially we create objects. These ID are unique to the object.
- `Hashable`: though calculating same hash for an object twice should return same value. If calculating it between 2 runs of the app (quit then relaunch), the hash can return different values.
- manual manage object context
  - `Codegen` select `Manual/None`
  - `Create NSManagedObject Subclass`
- `@NSManaged` read and write from a directory that CoreData uses to store the information
  - benefits: when read data, transparently fetches the data and sends it back
- CoreData is `lazy`
  - sometimes looks like data is loaded when it really hasn't been
  - these are **faults**, sense of fault line - a line between where something exists and where something is just a placeholder
- `NSManagedObjectContext.save()`
  - before call it, always check `moc.hasChanges` first, to avoid making CoreData do work that isn't required
- CoreData constraints
  - `Inspector -> Constraints` to change constraints
  - use `context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy` to tell CoreData always keep constraint attribute unique
  - when there is duplicates object, only one data get written

## Day 56

[Practice Code](https://github.com/HevaWu/100DaysOfSwiftUI/compare/v0.55.0...v0.56.0)

- SFSymbbols automatically adapts to the text around it.
  - it can be shown larger or small by using `font()` modifier
- `constant` binding cannot be changed by user
  - its's good for prototyping

## Day 55

[Practice Code](https://github.com/HevaWu/100DaysOfSwiftUI/compare/v0.54.0...v0.55.0)

- use `NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)` to create dummy test data in `_Preview` part
  - this creat a managed object context involves telling system what concurrency type here want to use
  - `mainQueueCurrencyType` indicate to use main queue
- use `NSSortDescriptor(keyPath:, sorting:)` to sort fetch request
- use moc`.delete` to delete one data record from fetch request

## Day 54

[Practice Code](https://github.com/HevaWu/100DaysOfSwiftUI/compare/v0.53.0...v0.54.0)

- use `.environment(\.managedObjectContext, moc)` to pass environment setting to another view
  - use it to write values in the environment
  - when use sheet() to present the view, need to add a managed object context property to pass it
  - when use push, current view will share environment setting with its ancestor
- use `.constant()` to set default `@Binding` property's value in `_Preview`
- `.onTapGesture {}` to add tap action function

## Day 53

[Practice Code](https://github.com/HevaWu/100DaysOfSwiftUI/compare/v0.52.0...v0.53.0)

- `@Binding` property wrapper to connect an `@State` property of one view to some underlying model data
  - create mutable value in the view
- `@Environment(\.horizontalSizeClass)` tell screen sizes: `compact` or `regular`
- `AnyView` type erased wrapper
  - conform to `View` protocol as Text, Color, VStack, etc.
  - doesn't expose what it contains (Swift see the returning only AnyView, which considered the same type)
  - DON'T use it anytime, only use when requires
    - if SwiftUI knows exactly view types, it can add and remove small parts trivially as needed
    - if use AnyView, the above will be denied
- `@FetchRequest(entity:sortDescriptors)` property wrapper to get core data fetch request, with type of `FetchedResults<>`
- `@Environment(\.managedObjectContext)` property wrapper to get current managed object context

## Day 52

[Practice Code](https://github.com/HevaWu/100DaysOfSwiftUI/compare/v0.51.0...v0.52.0)

- `@Published` property wrapper places properties inside a `Published` struct behind the scenes.
- `MIME` types were invented fro email attachments, and is short for Multipurpose INternet Mail Extensions

## Day 51

[Practice Code](https://github.com/HevaWu/100DaysOfSwiftUI/compare/v0.50.0...v0.51.0)

## Day 50

[Practice Code](https://github.com/HevaWu/100DaysOfSwiftUI/compare/v0.49.0...v0.50.0)

- add `.animation()` after one published property to see animation when this property changes

## Day 49

[Practice Code](https://github.com/HevaWu/100DaysOfSwiftUI/compare/v0.47.0...v0.49.0)

- add `required init(from decoder:)` and `encode(to encoder:)` function to allow setting `Codable` object property as `@Published`
  - need to implement Codable Conformance itself
- use `disabled()` to control under which condition disable the element

## Day 47

[Practice Code](https://github.com/HevaWu/100DaysOfSwiftUI/compare/v0.46.0...v0.47.0)

- `presentationMode.wrappedValue.dismiss()` work for both `present -> dismiss` and `push -> pop`
- `_count = State(initialValue: activity.count)` to set initial value of `State`

## Day 46

[Practice Code](https://github.com/HevaWu/100DaysOfSwiftUI/compare/v0.45.0...v0.46.0)

- `saturation() / blur()`: able to be applied by any view in real-time
- `stroke()` draw a line around a path that is half-way inside the line and half-way outside
- `stokeBorder()` draw stroke to be entirely within the shape
- `AnimatablePair<>` only animate values that are animatable, which excludes integers.

## Day 45

[Practice Code](https://github.com/HevaWu/100DaysOfSwiftUI/compare/v0.44.0...v0.45.0)

- `blendMode()` to specify blend mode
  - `.normal` default value
  - `.multiply`: multiply each source pixel color with destination pixel color. Like a tint effect
  - `.screen`: inverts the colors then perform multiply, then inverts them again, resulting with a brighter image
- `colorMultiply()` directly blend Color modes
- `saturation()` adjust how much color used in side a view. value is in range 0(no color, gray scale) to 1(full color)
- `animatableData` property: use to animate one shape, to help see smooth animation changing. Always be one value.
- `AnimatablePair<,>`: contains pair of animatable values, animate more variable
  - ex: SwiftUI's EdgeInsets `AnimatablePair<CGFloat, AnimatablePair<CGFloat, AnimatablePair<CGFloat, CGFloat>>>`

## Day 44

[Practice Code](https://github.com/HevaWu/100DaysOfSwiftUI/compare/v0.43.0...v0.44.0)

- `.fill(, style: FillStyle(eoFill: true))` to apply `even-odd` rule to fill the shape
- `ImagePaint` type to wrap image that we can control how it should be rendered
  - `sourceRect` for specify rect within image, range of 0(start) to 1(end)
  - useful add for view backgrounds and shape strokes
- any `bellow 60fps render has problem(slow)`, many iOS render at 120fps
- `Color(hue:saturation:brightness:)` make color from hue
  - `hue` is value from 0 to 1 controlling kind of color we see. res is both 0 and 1, other hues in between
- `drawingGroup()` modifier tell SwiftUI should render the contents of the view into an off-screen image before putting it back onto the screen as a single rendered output.
  - powered by Metal, working directly with GPU
  - NOTE: add this might slow down SwiftUI for simple drawing. Add it when there is really a performance problem there.

## Day 43

[Practice Code](https://github.com/HevaWu/100DaysOfSwiftUI/compare/v0.42.0...v0.43.0)

- `Path`: SwiftUI use this to draw custom shapes
  - `moveTo`, `addLine` to start drawing some line
  - draw any where
  - design to do specific thing
- `Shape` is View
  - draw inside rectangle (no rely on coordinates)
  - built using path
  - can draw space and accept parameters to customize further
- `StrokeStyle` control how line should be connected to line after it (`lineJoin`), and how line should be drawn when it ends without a connection after it (`lineCap`)
- Trickle in drawing Arc:
  - SwiftUI not `treat 0 degrees` as straight upward, instead it directly `to the right`
  - Shape `measure the coordinates from bottom-left corner` rather than top-left corner (the clockwise not correct as our setting)
- `strokeBorder` modifier: make border visible
  - use `stoke` directly might get border out of edge of the screen (which means the outside part of the border ends up beyond screen edges)
- `InsettableShape`: a shape can be inset by a certain amount to produce another shape.
  - require `inset(by:)`, this function given the inset amount(half the line width of stoke), and return a new kind of insettable shape.
    - since don't know the actual size of the shape, it's okay to hold a `insetAmount` property to record the inset amount there. Then call it where required to be set
  - extend custom `Shape` from `InsettableShape` can make them able to call `strokeBorder` modifier

## Day 42

[Practice Code](https://github.com/HevaWu/100DaysOfSwiftUI/compare/v0.41.0...v0.42.0)

- `NavigationLink` requires a `NavigationView` to work
- `sheet` NOT require `NavigationView`

## Day 41

[Practice Code](https://github.com/HevaWu/100DaysOfSwiftUI/compare/v0.40.0...v0.41.0)

- `Spacer(minLength:)`: to define minimum size of Space.
  - helpful in scroll view since total height is flexible
  - helpful define space min length in HStack and VStack
- `NavigationLink.buttonStyle()`: use to change linked button style
- `layoutPriority` to control view shrinks/expands.
  - All views have layout priority of `0` by default. Increase 1 means that view have higher priority to take available space.

## Day 40

[Practice Code](https://github.com/HevaWu/100DaysOfSwiftUI/compare/v0.39.0...v0.40.0)

- DateFormatter, `mm` means `zero padded minute`, `MM` means `zero padded month`
- `JSONDecoder.dateDecodingStrategy` to tell how it should decode dates. It need to be careful at timeZone part.

## Day 39

[Practice Code](https://github.com/HevaWu/100DaysOfSwiftUI/compare/v0.38.0...v0.39.0)

- `aspectRatio()` could set contentMode (fit or fill)
- `GeometryReader`: a view can be used to handle `GeometryProxy`, which able to query environment, ex: big of container, position of view, safe area insets, etc
  - use like `GeometryReader { geo in ... }`
  - use `geo.size.width` to fill the width of screen
- `ScrollView`: use to make UIScrollView like view
  - when add the view to scroll view, it get create immediately, ex: for 100 items, scrollView will generate all 100 items at the first. While `List` only create items when it is needed
- `NavigationLink` to push the view in the view stack.
  - the destination view can be any view
  - `List + NavigationLink` will show `gray indicator at the right side` in default

## Day 38

[Practice Code](https://github.com/HevaWu/100DaysOfSwiftUI/compare/v0.37.0...v0.38.0)

- `UserDefaults integer(forKey:)` will return `0` if key doesn't exist
- JSON stand for JavaScript Object Notion

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
