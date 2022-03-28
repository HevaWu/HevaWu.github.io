---
layout: post
title: Flutter Study Memo
date: 2022-03-26 23:25:00
comment_id: 207
categories: [Dart]
tags: [Flutter]
---

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
