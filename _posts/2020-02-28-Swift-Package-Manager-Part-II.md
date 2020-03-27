---
layout: post
title: Swift Package Manager -- PART II
date: 2020-02-28 15:53:00
comments: true
disqus_category_id: SwiftPackageManagerPARTII
categories: [iOS, Xcode, Swift]
tags: [SPM]
---

In [Part I](https://hevawu.github.io/ios/xcode/swift/2019/10/18/Swift-Package-Manager-Part-I.html), we share some concepts, and for Part II, let's try to create a package first!

## Create One Package First

### Create Library Package

Library Package contains code which other packages can use and depend on. For creating a Library Package, run:

```vim
$ mkdir TestPackage
$ cd TestPackage
$ swift package init # or swift package init --type library
$ swift build
$ swift test
```

### Create Executed Package

SwiftPM could also create native binaries which can be executed from command line. For creating a Executed Package, run:

```vim
$ mkdir TestExecutable
$ cd TestExecutable
$ swift package init --type executable
$ swift build
$ swift run
Hello, world!
```

## Define Dependencies

To depend on a package, we could define the `dependencies` and `version` in the mainfest of that package -> `Package.swift` file. ex:

```swift
// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TestPackage",
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "TestPackage",
            targets: ["TestPackage"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/apple/example-package-playingcard.git", from: "3.0.4"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "TestPackage",
            dependencies: ["PlayingCard"]),
        .testTarget(
            name: "TestPackageTests",
            dependencies: ["TestPackage"]),
    ]
)
```

Then, it should be able to `import PlayingCard` in `TestPackage` target.

## Publish a Package

```vim
$ git init
$ git add .
$ git remote add origin [github-URL]
$ git commit -m "Initial Commit"
$ git tag 1.0.0
$ git push origin master --tags
```

So, for now other packages can depend on version 1.0.0 of this package using the github url.

> Packages are Git repositories, tagged with semantic versions, containing a Package.swift file at their root. Initializing the package created a Package.swift file, but to make it a usable package we need to initialize a Git repository with at least one version tag:

## Link System Libraries

It is also possible to link against system libraries using the package manager. For doing this, there needs to be a special package for each system library that contains a modulemap for that library. Such a wrapper package does not contain any code of its own.

I will try this part when we needed it. It looks like SPM is also keep updating this part(ex: `system packages` are deprecated and be replaced by `system library targets`). So maybe I will try it later.

## Package Legacy

For a Swift Package, we might want to keep working it with both as a package or not. ex: the package which contains the project also builds with Xcode.

In these cases, we could add `SWIFT_PACKAGE` definition to conditionally compile code for Swift Packages.

```swift
#if SWIFT_PACKAGE
import Foundation
#endif
```

## Version Specific

> The package manager is designed to support packages which work with a variety of Swift project versions, including both the language and the package manager version.

### Tag Selection

Tags which defines package available versions for client to use and can `optionally` be suffixed with a marker in form of `@swift-3`.

When the package manager is determining the available tags for a repository, if a version-specific marker matches current tool version, it will `only` consider the versions which have version-specific marker.

> For example, suppose the package Foo has the tags [1.0.0, 1.2.0@swift-3, 1.3.0]. If version 3.0 of the package manager is evaluating the available versions for this repository, it will only ever consider version 1.2.0. However, version 4.0 would consider only 1.0.0 and 1.3.0.

**Q: When will we use it?**

> 1. A package wishes to maintain support for Swift 3.0 in older versions, but newer versions of the package require Swift 4.0 for the manifest to be readable. Since Swift 3.0 will not know to ignore those versions, it would fail when performing dependency resolution on the package if no action is taken. In this case, the author can re-tag the last versions which supported Swift 3.0 appropriately.
>
> 2. A package wishes to maintain dual support for Swift 3.0 and Swift 4.0 at the same version numbers, but this requires substantial differences in the code. In this case, the author can maintain parallel tag sets for both versions.

**Q: Does it be recommended?**

> It is not expected that the packages would ever use this feature unless absolutely necessary to support existing clients. Specifically, packages should not adopt this syntax for tagging versions supporting the latest GM Swift version.

SPM supports for any of the following marked tags:

- MAJOR.MINOR.PATCH (e.g., 1.2.0@swift-3.1.2)
- MAJOR.MINOR (e.g., 1.2.0@swift-3.1)
- MAJOR (e.g., 1.2.0@swift-3)

### Manifest Selection

SPM will find version-specific marked manifest version when loading the particular version of a package, with the form of `Package@swift-3.swift`.

But this is not a recommend way:

> It is not expected the packages would ever use this feature unless absolutely necessary to support existing clients. Specifically, packages should not adopt this syntax for tagging versions supporting the latest GM Swift version.

This providing is just for if current Swift version not match any version-specific manifest, package panager will pick the manifest with the most compaatible tools version. ex:

```
Package.swift (tools version 3.0)
Package@swift-4.swift (tools version 4.0)
Package@swift-4.2.swift (tools version 4.2)
```

## Edit Package

When it is required to make a change to one of the dependencies, package manager moves the dependency into a location under the `Package/` directory where it can be edited.

### Change to Editable State

There are 2 way to put the package in editable state:

```shell
# Solution 1:
# Create a branch called bugFix from currently resolved version and put the dependendy `Foo` in the `Packages/` directory
$ swift package edit Foo --branch bugFix

# Solution 2:
# package manager leave dependency at the dtached HEAD on the specific revision, and put the dependency `Foo` in the `Packages/` directory
#
# Note: if resolved revision is not provided, package manager will checkout the currently resolved version on the detached HEAD
$ swift package edit Foo --revision 969c6a9
```

### Editing

Navigate to the `Packages/Foo`(your directory) to make changes, build and push the changes or open a pull request to the upstream repository.

### End Editing

```shell
$ swift package unedit Foo
```

This command will remove the edited dependency from `Packages/` and pu the original resolved version back. This will failed when there are uncomitted changes or changes which are not pushed to the remote repository. If you want to discard the changes, you can use `--force` option.

```shell
$ swift package unedit Foo --force
```

## Resolve Versions (Package.resolved File)

Package Manager records the result of dependency resolution in a `Package.resolved` file in the top-level of the package. When this file is already present in the top-level, it is used when performing dependency resolution.

Running `swift package update` updates all dependencies to the latest eligible versions and updates the `Package.resolved` file accordingly.

`swift package resolve` command resolves the dependencies. For packages which have previously resolved versions recorded in `Package.resolved` file, this command will resolve to those versions as long as they are eligible. If the resolved version's file changes, the next resolve command will update packages to match that file.

## Set Swift Tools Version

Swift tools version is specified by a special comment at the first line of the `Package.swift` manifest. ex:

```
// swift-tools-version:3.1
// swift-tools-version:3.0.2
// swift-tools-version:4.0
```

The version number specifier followss the syntax defined by semantic versioning 2.0, with an amendment that the patch version component is optional and considered to be 0 if not specified.

It also have some commands:

```shell
# Report tools version of the package
$ swift package tools-version

# Set package's tools version to the version of the tools currently in use
$ swift package tools-version --set-current

# Set the tools version to a given value
$ swift package tools-version --set <value>
```

## Test

```shell
$ swift test

# for more info, try
$ swift test --help
```

## Run

```shell
$ swift run [executable [arguments]]
```

We could use this command to run an executable product of Swift package. The executable's name is optional when running without arguments and when there is only one executable product.

## Set Build Configuration

### Debug(defualt)

Run it by

```shell
$ swift build
# OR
$ swift build -c debug
```

The build artifacts are located in a directory called `debug` under the build folder.

A swift target is built with the following flags in debug mode:

- `-Onone`: Compile without any optimization.
- `-g`: Generate debug information.
- `-enable-testing`: Enable the Swift compiler's testability feature.

A C language target is built with the following flags in debug mode:

- `-O0`: Compile without any optimization.
- `-g`: Generate debug information.

### Release

Run it by

```shell
$ swift build -c release
```

The build artifacts are located in directory named `release` under the build folder.

A swift target is built with following flags in release mode:

- `-O`: Compile with optimizations.
- `-whole-module-optimization`: Optimize input files (per module) together instead of individually.

A C language target is built with following flags in release mode:

- `-O2`: Compile with optimizations.

## Depend on Apple Modules

> Swift Package Manager includes a build system that can build for macOS and Linux. Xcode 11 integrates with libSwiftPM to provide support for iOS, watchOS, and tvOS platforms.

## Use Shell

### Bash

```shell
# install the Bash completions to `~/.swift-package-complete.bash`
# and load them using `~/.bash_profile`
swift package completion-tool generate-bash-script > ~/.swift-package-complete.bash
echo -e "source ~/.swift-package-complete.bash\n" >> ~/.bash_profile
source ~/.swift-package-complete.bash
```

Then add ⬇️to `~/.bash_profile`

```
# Source Swift completion
if [ -n "`which swift`" ]; then
    eval "`swift package completion-tool generate-bash-script`"
fi
```

### ZSH

install ZSH completions to `~/.zsh/_swift`. It is okay to choose a different folder, but the filename should be `_swift`. This also add `~/.zsh` to `$fpath` using your `~/.zshrc` file.

```shell
mkdir ~/.zsh
swift package completion-tool generate-zsh-script > ~/.zsh/_swift
echo -e "fpath=(~/.zsh \$fpath)\n" >> ~/.zshrc
compinit
```

#### Test Project

<https://github.com/HevaWu/TestSwiftPackageManager>

#### Reference

<https://swift.org/getting-started/#using-the-package-manager>

<https://swift.org/package-manager/>
