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
