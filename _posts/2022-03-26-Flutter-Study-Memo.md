---
layout: post
title: Flutter Study Memo
date: 2022-03-26 23:25:00
comment_id: 207
categories: [Dart]
tags: [Flutter]
---

## [First App](https://docs.flutter.dev/get-started/codelab)

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
