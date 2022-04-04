---
layout: post
title: Flutter Study Memo
date: 2022-03-26 23:25:00
comment_id: 207
categories: [Dart]
tags: [Flutter]
---

## Effect

Test project:

- [Download Button](https://github.com/HevaWu/TestFlutter/tree/main/create_download_button)

Notes:

- `AlwaysStoppedAnimation` animation always stop at one time
- `ChangeNotifier` A class that can be extended or mixed in that provides a change notification API using VoidCallback for notifications.
  - `notifyLiseners()` notify changes


## Design

Test Project:

- [Drawer](https://github.com/HevaWu/TestFlutter/tree/main/add_a_drawer_to_a_screen)
- [SnackBar](https://github.com/HevaWu/TestFlutter/tree/main/display_a_snackbar)
- [Export Fonts](https://github.com/HevaWu/TestFlutter/tree/main/export_fonts_from_a_package)
- [Orientation](https://github.com/HevaWu/TestFlutter/tree/main/update_ui_based_on_orientation)
- [Themes](https://github.com/HevaWu/TestFlutter/tree/main/use_themes_to_share_colors_and_fonts_styles)
- [Tabs](https://github.com/HevaWu/TestFlutter/tree/main/work_with_tabs)

Notes:

- `Drawer`: better use it from material library, which adheres to Material Design Spec
  - need a `AppBar` to show it
  - use `Navigator.pop(context)` to close drawer. When user open a drawer(menu), Flutter add drawer to navigation stack.
- `Scaffold` from material library, ensure widget won't overlap
- `SnackBar`, can add action by `action: SnackBarAction`
- `ScaffoldMessenger.of` could use to show SnackBar
- `OrientationBuilder`: build different layout on landscape or portrait
- use `MediaQuery.of(context).orientation` could get orientation of the screen
- Flutter supports `.ttf` and `.otf` font formats
- set font as default: directly set app's `theme`(use fontFamily)
- set font for specific widget: use `TextStyle(fontFamily)`
- app wide themes: define app's `textTheme`
- create unique theme using `ThemeData`
- `Theme.copyWith()` extend parent theme
- `TabController` build a tabbar controller
  - `TabBar(tabs:[])` create each tabBarItem
  - `body: TabBarView(children:)` create each tabBar content view

## Animation

Test project:

- [Animate Page Route](https://github.com/HevaWu/TestFlutter/tree/main/animate_a_page_route_transition)
- [Animate Widget Physics](https://github.com/HevaWu/TestFlutter/tree/main/animate_a_widget_using_a_physics_simulation)
- [Animate Container](https://github.com/HevaWu/TestFlutter/tree/main/animate_the_properties_of_a_container)
- [Fade in and out](https://github.com/HevaWu/TestFlutter/tree/main/fade_a_widget_in_and_out)

Notes:

- `PageRouteBuilder` provide `Animation` object
  - Animation can be used with `Tween` and `Curve` object to customize the transition animation
  - `child` param in transitionBuilder is widget returned from pageBuilder.
  - `pageBuilder` only called the first time the route is built. Framework can avoid extra work because `child` stays the same throughout the transition.
- `FractionalTranslation`, apply translation transformation before painting its child
- `AnimatedWidget` rebuild themselves when the value of the animation changes(ex: `SlideTransition`)
- `chain()` to combine tweens
- `tween.animate(CurvedAnimation)` could generate animation with easing curve
- extend from `SingleTicketProviderStateMixin` allows state object to be a `TicketProvider` for `AnimationController`
- `Alignment`, visual coordinates, increase x move left to right.
- `GestureDetector`, handle `onPanDown/onPanUpdate/onPanEnd`.
- `AnimationController` listen `Animation` value to monitor animation and update position
- `DragEndDetails` provide velocity of the pointer when it stopped contacing the screen
- `AnimationController.animateWith(SpringSimulation)` set the velocity of animation
- `AnimatedContainer`, when rebuilt with new properties, it automatically animates between old and new values (implicit animations)
- `AnimatedOpacity` to perform opacity animations

## [Test](https://docs.flutter.dev/testing)

- `unit test`: tests a single function, method, or class.
- `widget test`(`component test`): tests a single widget.
- `integration test`: tests a complete app or a large part of an app.
- Style
  - use `flutter_test` package
  - `WidgetTester`: build and interact with widget in test environment
  - `testWidget()`: auto-create a new WidgetTester for each test case, nad is used in place of normal `test()` functions
    - WidgetTester's `pumpWidget` builds and renders provided widget
      - `tester.pump(Duration duration)`: schedule a frame and trigger rebuild of widget.
      - `tester.pumpAndSettle()` repeatedly call `pump()` with given duration until there are no longer any frames scheduled, waits for all animations to complete
      - `tester.scrollUntilVisible()` repeatedly scroll through lists of items until finds
      - `tester.enterText()`, `tester.tap()`, `tester.drag()`
  - `Finder` allow searching for widgets in test environment
  - `Matcher` constant verify whether a Finder locates a widget or multiple widgets in the tets environment
    - `findsOneWidget`, `findsWidgets`, `findsNWidgets`, `matchesGoldenFile`

## [Dart Language](https://dart.dev/overview)

### Dart: [The language](https://dart.dev/guides/language/language-tour)

- type safe
- static type checking, variable's value always match variable's static type
- use `dynamic` type to combine with runtime checks
- **sound null safety**: value can't be null unless mention they can be
- [abstract](https://dart.dev/guides/language/language-tour#abstract-classes): abstract class - class can't be instantiated. Useful for defining interfaces.
  - if want abstract class to appear to be instantiable, use [factory constructor](https://dart.dev/guides/language/language-tour#factory-constructors)
- [factory](https://dart.dev/guides/language/language-tour#factory-constructors): implement a constructor that doesn't always create new instance of its class.
  - ex: factory constructor might return an instance from cache, or might return an instance of subtype
  - initializing a final variable using logic that can't be handled in initializer list
  - Factory constructors have no access to `this`.

### Dart: [The Libraries](https://dart.dev/guides/libraries)

- **dart:core**: built-in types, core functionality
- **dart:collection**: collection types, ex: queues, linked lists, hashmaps, binary trees
- **dart:convert**: encoder and decoder, include JSON and UTF-8
- **dart:math**: mathematical constants and functions, random number generations
- **dart:io** file, socket, HTTP, I/O support for non-web applications
- **dart:async**: asynchronous program, with classes `Future` and `Stream`
- **dart:typed_data**: handle fixed-sized data(ex, unsigned 8-byte integers) and SIMD numeric types
- **dart:ffi**: foreign function interfaces for interoperability with other code that presents C-style interfaces
- **dart:isolate**: concurrent programming, independent workers that are similar to threads but don't share memory, communicating only through messages
- **dart:html**: HTML elements and other resources for web-based applications to interact with browser and Document Object Model(DOM)

### Dart: [The Platforms](https://dart.dev/overview#platform)

- **Native platform**: app target mobile and desktop devices, Dart includes both Dart VM(with JIT(just-in-time) compilation and AOT(ahead-of-time) compiler) for producing machine code
  - during development, Dart VM offer JIT(enabling hot reload), live metrics collection, rich debugging support
  - during production, Dart AOT compiler enabled compilation to native ARM or x64 machine code. AOT compiled app launches with consistent, short startup time. AOT run efficient that enforces the sound Dart type system and manages memory using fast object allocation and a [generational garbage collector](https://medium.com/flutter-io/flutter-dont-fear-the-garbage-collector-d69b3ff1ca30)
- **Web platform**: app target web, Dart includes both `dartdevc`(development time compiler) and `dart2js`(a production time compiler). Both compiler translate Dart into JavaScript
- Dart runtime
  - managing memory: Dart uses a manged memory model, where unused memory is reclaimed by a garbage collector(GC)
  - enforcing Dart type system,: most type check in Dart are static(compile-time), some type checks are dynamic(runtime)
  - managing isolates: Dart runtime controls the main isolate(where code normally runs) and any other isolates that app creates

## [First App](https://docs.flutter.dev/get-started/codelab)

Practice Code: <https://github.com/HevaWu/TestFlutter/tree/main/my_app>

- [Material](https://material.io/design) is visual design language that is standard on mobile and web. Flutter offers rich set of Material widgets.
- good to set `uses-material-design: true` entry in the `flutter` section under `pubspec.yaml` file. This will use more features of Material, exL set of predefined icons
- `StatelessWidget`, make app itself a widget. Almost all of things in Flutter is widget, include `alignment, padding, layout`
- `Scaffold` provides default `AppBar` and `body` holds widget tree for home screen
- one widget had to provide a `build()` to describe how to display
- `flutter pub add {package_name}` to add package to project
- perform `flutter pub get` will also auto-generates `pubspec.lock`
- `Stateless` widget is immutable, properties cannot change
- `Stateful` widget maintain state that might change during the lifetime of the widget.
  - require `StatefulWidget` class to create instance, and `State` class
  - `StatefulWidget` immutable, can be thrown away and regenerated
  - `State` class persists over the lifetime of widget
  - `stful` in IDE, use StatefulWidget template
  - prefix an identifier with `_` [enforces privacy](https://dart.dev/guides/language/language-tour#libraries-and-visibility) in Dart language, recommended
- `ListView` allow to build a list of object
  - when ListTile has been tapped, it will call `setState()` to notify framework that state has changed
- `Navigator` manage stack containing the app's routes.
  - push route onto Navigator's stack updates display to that route
  - pop route from Navigator's stack return the display to previous route
  - `MaterialPageRoute` to help build route of navigation
- configure `ThemeData` to change app's theme

#### References

- <https://docs.flutter.dev/>
- <https://dart.dev/overview>
