---
layout: post
title: Flutter - go_router
date: 2022-06-08 21:32:00
comment_id: 219
categories: [Packages]
tags: [Flutter]
---

`go_router` is a tool to implement `RouterDelegate` and `RouteInformationParser` classes. Here is the GoRouter API public design doc:

- <https://docs.google.com/document/d/1_mRXinbL_rb0mUt6DAFZ8kj0kh33ZjEMJuUq4PJgwj8/edit?resourcekey=0-sYbRzE9opneOFZ5F8J3gGw>
- <https://docs.google.com/document/d/1T2LmzMj5HpD7hEexXL4Xz6vqoJD81bEGaa9NsV24faw/edit?resourcekey=0-PuQbtDVl7ZabpJ2B9AHWUg>

Since it is suggested and maintained by Flutter dev, it is a good tool to use, without manually keep maintain any by developer side.

It's follow Navigation2.0 design style mentioned by [Flutter in 2020](https://medium.com/flutter/learning-flutters-new-navigation-and-routing-system-7c9068155ade).

It is quite a convenience tool, which follow the declarative routes. Let me memo some for what I tried at here.

## Installation

```s
# add package into project
$ flutter pub add go_router
```

## Code implementation

TL;DR

- make `AppRouter` class
- define all routes in `RoutePath` class, by using [freezed](https://pub.dev/packages/freezed) to seal the path

### 1. AppRouter Class

We need to define all routes at one place at the first

```dart
class AppRouter {
    final LoginState loginState;
    AppRouter(this.loginState);

    GoRouter get router => _goRouter;

    late final _goRouter = GoRouter(
        refreshListenable: loginState,
        debugLogDiagnostics: kDebugMode ? true : false,
        urlPathStrategy: UrlPathStrategy.path,

        routes: [
            GoRoute(
                path: '/', // root path
                redirect: (_) => RoutePath.myHomePage().path,
            ),

            GoRoute(
                path: RoutePath.login().path,
                builder: (context, state) => const LoginPage(),
            ),

            GoRoute(
                path: RoutePath.myHomePage().path,
                builder: (context, state) => const MyHomePage(),
            )

            // define more paths at here
        ],

        errorPageBuilder: (context, state) => MaterialPage<void>(
            key: state.pageKey,
            child: ErrorPage(
                message: state.error.toString(),
            ),
        ),

        // redirect to login if user not logged it
        redirect: (state) {
            final loggedIn = loginState.login;
            final loggingIn = state.subloc == RoutePath.myHomePage().path;

            if (!loggedIn) return loggingIn ? null : RoutePath.myHomePage().path;

            // if user is logged in but still on login page, send to home page(root will redirect to homepage)
            if (loggingIn) return '/';
            // no need to redirect at all
            return null;
        }
    );
}
```

### 2. RoutePath class

We will use [freezed](https://pub.dev/packages/freezed) to generate data-classes. It is useful to help define constructor and properties, also handling de/serialization well.

First, we need to prepare and add `freezed` package in our project :

```s
$ flutter pub add freezed_annotation
$ flutter pub add --dev build_runner
$ flutter pub add --dev freezed
```

Then, create bellow class file

```dart
@freezed
class RoutePath with _$RoutePath {
    const RoutePath._();

    // general initializer
    const factory RoutePath.general({
        required String path,
        @Default([]) List<String> paramKeys,
    }) = _General;

    factory RoutePath.myHomePage() => const RoutePath.general(path: '/my_homepage');
    factory RoutePath.login() => const RoutePath.general(path: '/login');

    @override
    String toString() {
        return path;
    }
}
```

By using `RoutePath.general`, it could cover almost all path definition contains `params`. ex: if we have a `/detail/:detailId` path, we can make

```dart
// call this as context.go(RoutePath.goDetail('123'))
factory RoutePath.goDetail(String detailId) => RoutePath.general(path: '/detail/$detailId');

// call this at GoRoute config
// ex:
// GoRoute(
//     path: RoutePath.generalDetail().path,
//     builder: (context, state) {
//         List<String> _params = RoutePath.generalDetail().maybeWhen(
//             general: (String path, List<String> paramKeys) => paramKeys,
//             orElse: () => [],
//         );
//         String _detailIdParam = _params.first;
//         return DetailPage(id: state.params[_detailIdParam]);
//     },
// ),
factory RoutePath.generalDetail() => RoutePath.general(path: '/detail/:detailId', params: ['detailId']);
```

After we have this class and dart file, we could try to make the `freezed` data classes. Otherwise, dart file will show many warning errors there.

Run code generator by:

```s
$ flutter pub run build_runner build
```

it will generate, and we need to add current file as start with `Freezed` :

```dart
import 'package:freezed_annotation/freezed_annotation.dart';
part 'xxx.freezed.dart';
```

That's all! Once we make all of page done, the navigation will work well for us!

#### Reference

- <https://gorouter.dev/>
- <https://pub.dev/packages/freezed>
