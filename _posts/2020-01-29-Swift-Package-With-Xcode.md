---
layout: post
title: Swift Package With Xcode
date: 2020-01-29 14:57:00
comments: true
disqus_category_id: SwiftPackageWithXcode
categories: [iOS, Xcode, Swift]
tags: [SPM]
---

# Creating Swift Packages

## Creating Local Packages

- Local Swift Packages coule be thought as sub-projects in a Xcode workspace.
- It is platform independent which it could be used across all of Apple's platforms in a straightforward way.
- It is great for refactoring out reusable code.
- Not versioned
- Could be published and shared with others later

## Publishing Packages

It is needed to publish a package with semantic version(semver.org).

- Major version: breaking changes, ex: renaming existing type, removing a method or changing a method signature or major behavior changes.
- Minor version: compatible additions, ex: adding a new method or type.
- Patch Version: bugfixes.

Major version `0` is a special case which could be use during initial development. Shipping to `1` when people start using it. Once publish a package for a while, it could be use prerelease versions for clients to test APIs for keeping it stable.(ex: 2.0.0-alpha.1)

## Package Manifest API

![package_manifest](/images/2020-01-29-Swift-Package-With-Xcode/package_manifest.png)

### Package Dependencies

- source URL
- version

Here are some example of version based requirements:

```swift
// Version-based requirements
.package(url: "https://github.com/HevaWu/TestSwiftPackage", from: "1.0.0")
.package(url: "https://github.com/HevaWu/TestSwiftPackage", .upToNextMajor(from: "1.0.0"))
.package(url: "https://github.com/HevaWu/TestSwiftPackage", .upToNextMinor(from: "1.0.0"))
.package(url: "https://github.com/HevaWu/TestSwiftPackage", exact("1.0.0"))

// Branch-based requirement
.package(url: "https://github.com/HevaWu/TestSwiftPackage", .branch("master"))

// Revision-based requirement
.package(url: "https://github.com/HevaWu/TestSwiftPackage", .revision("cfe9813"))
```

**Note: branch & revision are not allowed in published package, it must be removed if preparing to publish the package.**

### Platform Independent

If it is needed to support the package for different platform, it is able to use swift conditional. It is able to define the target in the platform section.

```swift
platforms: [
    .macOS(.v10_15), .iOS(.v13),
]
```

## Editing Packages

If we have the same package for the local one and the remote one, local one will always replace the remote one. Since local package are always editable, it is able to edit the app and the package together.

## Open Source Project

- SPM
- xcodebuild

## How Swift Packages works in Xcode

Project consists of source files. The packages are also source files. Xcode take all of these source files and compiles them. It particullaly compile the package code in compatible way. It will recompile it multiple times if needed, then it links it in and combines all of that into the application.

Package libraries are static by default, so all the code is linked together.

#### Reference

https://developer.apple.com/videos/play/wwdc2019/408/
https://developer.apple.com/videos/play/wwdc2019/410
