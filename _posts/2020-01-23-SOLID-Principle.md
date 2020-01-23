---
layout: post
title: SOLID Principle
date: 2020-01-23 14:33:00
comments: true
disqus_category_id: SOLID
categories: [Object Oriented Design]
tags: [Principle]
---

## Overview

> In object-oriented design, `SOLID` is a five design priciples intended to make software desgins more understandable, flexible and maintanable.

The principles are promoted by Robert C. Martin. The `SOLID` principles can form a core philosophy for methodologies as agile development or adaptive software development.

## Concepts

- Single responsibility principle
    > A class should only have a single responsibility, that is, only changes to one part of the software's specification should be able to affect the specification of the class.
    >
    > The single responsibility principle is a computer programming principle that states that every module, class, or function[1] should have responsibility over a single part of the functionality provided by the software, and that responsibility should be entirely encapsulated by the class, module or function. All its services should be narrowly aligned with that responsibility.
    >
    > A class should have only one reason to change.
- Open-closed principle
    > Software entities (classes, modules, functions, etc.) should be open for extension, but closed for modification.
    >
    > An entity can allow its behaviour to be extended without modifying its source code.
- Liskov substituion principle
    > Objects in a program should be replaceable with instances of their subtypes without altering the correctness of that program.
    >
    > If S is a subtype of T, then objects of type T may be replaced with objects of type S (i.e. an object of type T may be substituted with any object of a subtype S) without altering any of the desirable properties of the program (correctness, task performed, etc.
- Interface segregation principle
    > Many client-specific interfaces are better than one general-purpose interface.
    >
    > ISP splits interfaces that are very large into smaller and more specific ones so that clients will only have to know about the methods that are of interest to them.
- Dependency inversion principle
    > Depend upon abstractions, [not] concretions.
    >
    > The conventional dependency relationships established from high-level, policy-setting modules to low-level, dependency modules are reversed, thus rendering high-level modules independent of the low-level module implementation details.
    >
    > A. High-level modules should not depend on low-level modules. Both should depend on abstractions (e.g. interfaces).
    >
    > B. Abstractions should not depend on details. Details (concrete implementations) should depend on abstractions.

#### Reference

https://en.wikipedia.org/wiki/SOLID
https://en.wikipedia.org/wiki/Single_responsibility_principle
https://en.wikipedia.org/wiki/Open–closed_principle
https://en.wikipedia.org/wiki/Liskov_substitution_principle
https://en.wikipedia.org/wiki/Interface_segregation_principle