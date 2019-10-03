---
layout: post
title: Design Pattern PART I - Creational Patterns
date: 2019-04-15 12:20:00
comments: true
disqus_category_id: DesignPatternPARTICreationalPatterns
categories: [Design Pattern]
tags: [Creational Pattern]
---

Define
===
> Creational Design Patterns are design patterns that deal with object creation mechanisms, trying to create objects in a manner suitabl to the situation.

Basic Form
===
1. Abstract Factory
    Creates an instance of several familis of classes
2. Builder
    Separates object construction from its representation
3. Factory Method
    Creates an instance of several derived classes
4. Object Pool
    Avoid expensive acquisition and release of resources by recycling objects that are no longer in use
5. Prototype
    A fully initialized instance to be copied and cloned
6. Singleton
    A class which only a single instance can exist

Rules
===
1. Sometimes the basic form might not fit properly.
    - *Abstract Factory* might store set of *Prototypes* from which to clone and return product objects
    - *Builder* can use of the other patterns to implement which components get build
    - *Abstract Factory*, *BUilder* and *Prototype* can use *Singleton* in their implementation
2. *Abstract Factory*, *Builder*, and *Prototype* define a factory object that's responsible for knowing and creating the class of product objects, and make it a parameter of the system.
    - *Abstract Factory* has the factory object producing objects of several classes.
    - *Builder* has the factory object building a complex product incrementally using a correspondingly complex protocol.
    - *Prototype* has the factory object (aka prototype) building a product by copying a prototype object.
3. *Abstract Factory*
    - are often implemented with Factory Methods, but they can also be implemented using *Prototype*.
    - can be used as an alternative to Facade to hide platform-specific classes.
4. *Builder*
    - focuses on constructing a complex object step by step. *Abstract Factory* emphasizes a family of product objects (either simple or complex). *Builder* returns the product as a final step, but as far as the *Abstract Factory* is concerned, the product gets returned immediately.
    - is to creation as *Strategy* is to algorithm.
    - often builds a *Composite*.
5. *Factory Methods*
    - are usually called within *Template methods*.
    - *Factory Method*: creation through inheritance.
      *Prototype*: creation through delegation.
    - Often, designs start out using *Factory Method* (less complicated, more customizable, subclasses proliferate) and evolve toward *Abstract Factory*, *Prototype*, or *Builder* (more flexible, more complex) as the designer discovers where more flexibility is needed.
6. *Prototype*
    - doesn't require subclassing, but it does require an Initialize operation. *Factory Method* requires subclassing, but doesn't require Initialize.
    - Designs that make heavy use of the *Composite* and *Decorator* patterns often can benefit from Prototype as well.

Reference
===
https://sourcemaking.com/design_patterns/creational_patterns