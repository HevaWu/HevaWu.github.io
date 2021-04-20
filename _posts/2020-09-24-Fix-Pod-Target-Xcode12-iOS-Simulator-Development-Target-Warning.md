---
layout: post
title: Fix Xcode 12 iOS Simulator Development Target Warning
date: 2020-09-24 15:40:00
comment_id: 99
categories: [Xcode]
tag: [Xcode12]
---

After updating to use Xcode 12, we got this ⬇️ warnings for our project.

```s
The iOS Simulator deployment target 'IPHONEOS_DEPLOYMENT_TARGET' is set to 8.0, but the range of supported deployment target versions is 9.0 to 14.0.99.
```

There are 2 places where warning from:

- Cocoapods
- SPM (Swift Package)

## Cocoapods Warnings

For resolving Cocoapods issue, someone has already posted a really nice post: <https://qiita.com/temoki/items/46ad22940e819a132435>.

```ruby
post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '9.0'
    end
  end
end
```

But be careful, ⬆️ will change whole pods, if we only want to change some specific pod settings, please add the `if` for checking it, ex:

```ruby
post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
	  if target.name == 'YOUR SPECIFIC POD NAME'
		config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '9.0'
	  end
    end
  end
end
```

## Swift Package Warnings

I still not find a workaround for this part. And here is the related Apple developer forums: <https://developer.apple.com/forums/thread/656616?login=true>.

Many engineers are watching this issue, but not sure if Apple will provide an official suggestion for it. For now, if the Swift Package is created by third party, maybe we should try to wait for their update.

If the Swift Package is created by ourselves, and we are not specify the `platform:` in Swift Package manifest file(using Swift Package default platform settings). Then this `iOS Simulator deployment target` warning should not be shown.

If we specify the Swift Package with `iOS(.v8)`, then of course this warning will be shown. For fixing this warning, change the platform to `iOS(.v9)` or just simply removing it(if the package source code could still compilable) should solve this issue.

#### Reference

- <https://qiita.com/temoki/items/46ad22940e819a132435>
- <https://developer.apple.com/forums/thread/656616?login=true>
