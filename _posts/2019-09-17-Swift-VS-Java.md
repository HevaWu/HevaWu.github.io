---
layout: post
title: Swift VS Java
date: 2019-09-17 13:56:00
comments: true
disqus_category_id: SwiftVSJava
categories: [Java, Swift, C++]
tags: [Java, Swift, C++]
---

Java might be easy to learn first. Since Java code follows very standardized coding styles. It is fewer questions about how to implement somthing as the programming styles and patterns are well established and consistent.

## Different Part

- Optional: Swift use `?` to mark if variable is optional or not. Java not obviously showing it.
- Computed Properties: For Java, create getter and setter for member variables in a class and separate methods to return any computation over them. For Swift, same is accomplish with computed properties, however convertional way still exists.
- Structures are passed by value: For Java, no concept of structures. For C++, structure and classes are same except structure's member varaiable are public by default. For Swift, structures are passed by value not reference. This difference requires a separate annotation for structures to differentiate it.
- No abstract class: For Swift, does not have concept of abstract classes. An abstract class is a class which provide partial implementation. It does not have to implement all methods declared. Abstract classes are powerful concept to put common code in one place for multiple derived classes from same base class.
- Global functions: For Swift, have global functions (i.e. without class scope) which is not possible in Java but possible in C++.

## Swift Pros & Cons

Swift often referred to as "Objective-C, without the C", Swift language is in many aspects superrior to its predecessor. According to the official release:
> “Swift combines the performance and efficiency of compiled languages with the simplicity and interactivity of popular scripting languages.”

- Open Source
- Safe
- Fast: Swift was built with performance in mind. Not only does its simple
- In demand: Swift is ranked 14th among the most popular programming languages of 2018.

### Pros

- Rapid development process: it is easier to read and write, and very concise. Automatic Reference Counting(ARC) does all the work tracking and managing the app's memory usage, so developers don't need to spend time and effort doing that manually.
- Easier to scale the product and the team: the syntax of Swift is considered near to natual English.
- Improved safety and performance: there are many ways to optimize Swift code for even better performance. Its strong typing system and error handling prevents code crashes and errors in production.
- Decreased memory footprint: it might need to use a lot of third party code, reusable and often open souce frameworks or libraries compiledinto the app's code. These libraries can be static and dynamic. Swift first introduced dynamic libraries to iOS when it launched. `static` libraries are locked in to code at the time you compiled them, become the part of your executable file, thus increasing its size and load time. `Dynamic` libraries exist outside of the code and are uploaded only when needed. Static libraries need to have copies in all files of your program while dynamic ones only need one. Though it might take more time to reach for dynamic code from the outside when its already included, you have a choice to keep using static libraries when you want to isolate apps that are not supposed to be shared. Since version 5.0, standard Swift libraries are integrated into every macOS, iOS, tvOS, and watchOS release. With this advancement, stable application binary interface(ABI) was also released. That allows Apple to provide support of Swift across its platforms.
- Interoperability with Objective-C: You either add new features in Swift to the existing Objective-C codebase, or use Objective-C elements in your new Swift project. Swift is perfectly compatible with Objective-C and can be used interchangeably within the same project.
- Automatic memory management: Swift uses Automatic Memory Counting(ARC). Swift's ARC determines which instances are no longer in use and gets rid of them on your behalf. It allows you to increase the app's performance without lagging the memory or CPU.
- Full stack potential and cross-device support: using Swift on both backend and frontend of the app allows for extensive code sharing and reuse, speeding up the development process and reducing development efforts.
- Vibrant open source community and learnability

### Cons

- The language is still quite young: Swift was introduce to the world in 2014, which seems to be long ago, but the language itself is really only 5 years old, compared to Objective-C live since the 1980s. Swift is limited to native libraries, tools, and doomed to be unstable after every release.
- Limited talent pool: While Swift community is growing fast, it is still significantly smaller as compared to any other open source language. Acoording to the latest [StackOverflow Developer Survey](https://insights.stackoverflow.com/survey/2019), only 6.6 percent of the respondents use Swift.
- Poor interoperability with third-party tools and IDEs: Developers often report issues with syntax highlighting, autocomplete, refactoring tools and compilers.
- Lack of support for earlier iOS versions: we could only use Swift in the apps that target iOS7 and later.

#### Reference
https://www.altexsoft.com/blog/engineering/the-good-and-the-bad-of-swift-programming-language/