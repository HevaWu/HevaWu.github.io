---
layout: post
title: Swift Package Manager -- PART I
date: 2019-10-18 15:29:00
comments: true
disqus_category_id: SwiftPackageManagerPARTI
categories: [iOS, SPM, Xcode, Swift]
tags: [SPM, Xcode]
---

# PART I: Introduction & Before

## What is `Swift Package Manager`

> The Swift Package Manager is a tool for managing the distribution of Swift code. It’s integrated with the Swift build system to automate the process of downloading, compiling, and linking dependencies.
>
> The Package Manager is included in Swift 3.0 and above.

So, we might wonder, we could use SPM(Swift Package Manager) to handle the linked frameworks(ex: Realm), and app extensional framework (ex: your app only framework)

## Conceptual Overview

### Modules

> Swift organizes code into modules. Each module specifies a namespace and enforces access controls on which parts of that code can be used outside of the module.
>
> A program may have all of its code in a single module, or it may import other modules as dependencies.

So, as it is point out, aside from the handful of system-provided modules, such as Darwin on macOS or Glibc on Linux, most dependencies require code to be downloaded and built in order to be used.

And for the separate module for code that solves a particular problem, that code can be reused in other situations. We could use modules lets build on top of other develoers' code rather than reimplementing the same funcitonality again.

### Packages

> A *package* consists of Swift source files and a manifest file.
>
> The *manifest* file, called Package.swift, defines the package’s name and its contents using the PackageDescription module.

One package could have 1 or more targets. Each target specifies a product and may declare 1 or more dependencies.

### Products

> A target may build either a library or an executable as its product.
>
> A *library* contains a module that can be imported by other Swift code.
>
> An executable is a program that can be run by the operating system.

### Dependencies

> A target’s dependencies are modules that are required by code in the package. A dependency consists of a relative or absolute URL to the source of the package and a set of requirements for the version of the package that can be used.

The Role of the package manager is to reduce coordination costs by automating the process of downloading and building all of the dependencies for a project.

So this is a recursize process:

- A dependency can have its own dependencies, each of which can also have dependencies, forming a dependency graph

The package manager downloads and builds everything that is needed to satisfy the entire dependency graph.

## Before

Let's go through its description first. From the official website:

> Swift package manager provides a convention-based system for building libraries and executables, and sharing code across different packages.

Make sure you have made swift available in yout path. Once available, you could invode the package manager by `swift package`, `swift run`, `swift build`, and `swift test`.

#### Reference

https://swift.org/getting-started/#using-the-package-manager
https://swift.org/package-manager/