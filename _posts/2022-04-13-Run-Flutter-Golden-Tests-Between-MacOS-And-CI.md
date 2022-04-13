---
layout: post
title: Run Flutter Golden Tests Between MacOS and CI
date: 2022-04-13 14:40:00
comment_id: 209
categories: [MacOS, CI]
tags: [Flutter, GoldenTests]
---

If your local machine under MacOS, and CI run on Linux, then you might got similar issue as mine. Recenly, I face an issue which is:

- MacOS generated golden files failed on CI(in my case, is Linux). It shows error like `Pixel test failed, xxx% diff detected.`

It seems there is some font rendering difference between MacOS and other system.

The solution I picked is: use `Alchemist` to generate different goldens folder for CI and local machine.

## Solutions

### 1. Always keep local and CI under same environment

This means always generate goldens under Linux or always under MacOS.

- pros:
  - stable
  - if Flutter update related golden tests function in future, we could follow it directly
- cons:
  - need to be careful to run `--update-goldens` in another system. ex: always use MacOS, someday use Linux to update goldens will cause mis-updates
    - add `skip: !Platform.isMacOS` could be one solution, but should remember add if for all of golden tests functions
  - don't know when Flutter could provide a stable golden test across platform

### 2. Use `Alchemist` with `CI` env specification

- pros:
  - separate CI env and local env golden files into different folders
  - code is clean, able to put related widget goldens in single functions
- cons:
  - not sure the maintainable, if Flutter do changes on golden tests method, this package might be affected

Usage example:

```dart
// the _test file
goldenTest(
    'Golden Test',
    fileName: 'golden',
    builder: () => GoldenTestGroup(children: [
        GoldenTestScenario(
            name: 'xxx',
            child: const TestWidget(),
        ),
        GoldenTestScenario(...),
    ]),
)

// dart_test.yaml
tags:
  {golden}

// flutter_test_config.dart
import 'dart:async';
import 'package:alchemist/alchemist.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  // ignore: do_not_use_environment
  const isRunningInCi = bool.fromEnvironment('CI', defaultValue: false);

  return AlchemistConfig.runWithConfig(
    config: AlchemistConfig(
      platformGoldensConfig: const PlatformGoldensConfig(
        enabled: !isRunningInCi,
      ),
    ),
    run: testMain,
  );
}
```

- From local, call `flutter test --update-goldens` to generate/update golden files
- From CI, call `flutter test --dart-define=CI=true` to specify it is under CI env

```sh
# run all tests
flutter test

# only run golden tests
flutter test --tags golden

# run all tests except golden tests
flutter test --exclude-tags golden
```

**`reduced-test-set` and `goldenTest`**

`reduced-test-set` is recommended by Flutter at: <https://github.com/flutter/flutter/wiki/Writing-a-golden-file-test-for-package:flutter#reduced-test-set-tag>

> On some CI platforms in pre-submit, hermetic tests suites are not executed in order to conserve resources and expedite testing of other changes. To ensure that a golden file image is available for every platform, test files with golden tests are tagged with reduced-test-set. This marks them for execution in these conservative test environments. Currently, framework tests on Mac and Windows platforms execute these reduced test sets.

We might worry if using `goldenTest` will have conflict with it or not. In my opinion, `reduced-test-set` is working with `goldenTest()`. It is because `goldenTests` actually use `Flutter.testWidget` by default. Here is code ref:
<https://github.com/Betterment/alchemist/blob/main/lib/src/golden_test_adapter.dart#L52-L54>

To my mind, since `reduced-test-set` is not really take effect on Linux CI, because it only support for Windows and MacOS platform for now. But it should be no harm to keep both of them. Since if we plan to switch back to Flutter.testWidget, this flag will work directly.

## Other Solutions I tried

For resolving the issue, I will put what I checked and tested at here:

### 1. ❌ Disable MacOS "Use Font Smoothing"

```s
defaults -currentHost write -g AppleFontSmoothing -int 0
```

It seems this solve problems for some people, but it not working in my case.

### 2. ❌ Use `golden_toolkit` and try `Roboto` font in golden tests

[golden_toolkit](https://pub.dev/packages/golden_toolkit) provide powerful features on golden tests, ex: change font, view by multiple device.

Under my testing, `Roboto` font and `Ahem` font still not working same on MacOS and CI(Linux).

#### References

- <https://github.com/flutter/flutter/wiki/Writing-a-golden-file-test-for-package:flutter>
- <https://github.com/flutter/flutter/issues/56383>
