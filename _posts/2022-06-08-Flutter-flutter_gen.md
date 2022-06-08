---
layout: post
title: Flutter - flutter_gen
date: 2022-06-08 21:21:00
comment_id: 218
categories: [Packages]
tags: [Flutter]
---

To get rid of string-based API, [`flutter_gen`](https://github.com/FlutterGen/flutter_gen) is one good choice there. It will auto generate assets, fonts, colors for us.

### Installation

- By Homebrew:

```s
$ brew install FlutterGen/tap/fluttergen
```

### Setup

```s
$ dart pub global activate flutter_gen
```

### Use it

```s
# as part of build_runner
dev_dependencies:
  build_runner:
  flutter_gen_runner:

# get package
$ flutter pub get

# in pubspec.yaml
flutter:
  assets:
    - assets/images/profile.jpg

# generate files
$ flutter packages pub run build_runner build

# run when update `pubspec.yaml`
$ fluttergen -h
$ fluttergen -c example/pubspec.yaml
```

### More configuration

Here is the official guide for more configurations part:

- <https://github.com/FlutterGen/flutter_gen#configuration-file>

#### References

- <https://github.com/FlutterGen/flutter_gen>
