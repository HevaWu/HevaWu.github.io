---
layout: post
title: Fix Golden Test Image Not Shown Properly Issue
date: 2022-04-14 18:30:00
comment_id: 210
categories: [MacOS, CI]
tags: [Flutter, GoldenTests]
---

I notice this issue when using Alchemist to run golden tests in Flutter.

Here is my test code: <https://github.com/HevaWu/TestAlchemist>

It not shown image in generated goldens, either local or CI folder.

After reading the code, I solve it by adding my own [GoldenTestAdapter](https://github.com/HevaWu/TestAlchemist/blob/main/test/my_golden_test_adapter.dart)

The main changes I did is:

```dart
// use `home` in pumpWidget
await pumpWidget(
    tester,
    MaterialApp(
    key: rootKey,
    theme: theme.stripTextPackages(),
    debugShowCheckedModeBanner: false,
    supportedLocales: const [Locale('en')],

    /// My Changes:
    home: DefaultAssetBundle(
        bundle: TestAssetBundle(),
        child: Material(
            type: MaterialType.transparency,
            child: Align(
                alignment: Alignment.topLeft,
                child: ColoredBox(
                    color: theme.colorScheme.background,
                    child: Padding(
                        key: childKey,
                        padding: const EdgeInsets.all(8),
                        child: widget,
                    ),
                ),
            ),
        ),
    ),
),
```

How I notice this is because: Flutter's doc mentioned [DefaultAssetBundle](https://api.flutter.dev/flutter/widgets/DefaultAssetBundle-class.html), and its example is using `home` there.

Once update to use that, I solve my problem: <https://github.com/HevaWu/TestAlchemist/commit/ed93fdcb094425c529f8dda8cabc17977be01cba>

# Related Reseaching

## Try 1: Use `precacheImage`

```dart
/// current workaround for flaky image asset testing.
/// https://github.com/flutter/flutter/issues/38997
Future<void> pump(WidgetTester tester, Widget w) async {
await tester.runAsync(() async {
    await tester.pumpWidget(w);
    for (var element in find.byType(Image).evaluate()) {
    final Image widget = element.widget;
    final ImageProvider image = widget.image;
    await precacheImage(image, element);
    await tester.pumpAndSettle();
    }
});
}
```

## Try 2: Add `TestAssetBundle`

Someone point out this might be issue of `loadString()` in `asset_bundle.dart`.

> If your AssetManifest.json file exceeds 10kb It will be loaded with isolate that (most likely) will cause your test to finish before assets are loaded so goldens will get empty assets.
>
> One solution — create your own asset bundle and override this method without this size check

```dart
class YourOwnTestAssetBundleextends CachingAssetBundle {
  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    final ByteData data = await load(key);
    if (data == null) throw FlutterError('Unable to load asset');
    return utf8.decode(data.buffer.asUint8List());
  }
  @override
  Future<ByteData> load(String key) async => rootBundle.load(key);
}
```

Please refer this doc for more details: https://medium.com/@sardox/flutter-test-and-randomly-missing-assets-in-goldens-ea959cdd336a



#### References

- <https://github.com/flutter/flutter/issues/38997>
- <https://medium.com/@sardox/flutter-test-and-randomly-missing-assets-in-goldens-ea959cdd336a>
- <https://api.flutter.dev/flutter/widgets/DefaultAssetBundle-class.html>
