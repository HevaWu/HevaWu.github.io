---
layout: post
title: Objective-C - Code Follows Established Conventions
date: 2020-11-17 21:21:00
comment_id: 111
categories: [Objective-C]
tags: [KVC, KVO]
---

# Conventions

## Some Names Must Be Unique Across the App

- Keep class name unique -> convention: use prefixes on all classes

> Your own classes should use three letter prefixes. These might relate to a combination of your company name and your app name, or even a specific component within your app. As an example, if your company were called Whispering Oak, and you were developing a game called Zebra Surprise, you might choose WZS or WOZ as your class prefix.

- Method name should be expressive and unique within the class
  - The first portion of the method name should indicate the primary intent or result of calling the method. 
  - If a method includes an error pointer parameter to be set if an error occurred, this should be the last parameter to the method. 
  - If a method takes a block, the block parameter should be the last parameter in order to make any method invocations as readable as possible when specifying a block inline
  - clear but concise
  - avoid abbreviating words in method names unless you are sure that the abbreviation is well known across multiple languages and cultures. Here is [list of common abbreviations](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/CodingGuidelines/Articles/APIAbbreviations.html#//apple_ref/doc/uid/20001285)
  - use prefix for method names in categories on framework classes. This is avoid for [method name clashes](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/ProgrammingWithObjectiveC/CustomizingExistingClasses/CustomizingExistingClasses.html#//apple_ref/doc/uid/TP40011210-CH6-SW4)

- Local variable must be unique within the same scope

## Some Method Names Must Follow Conventions

### Accessor method names

> When you use the @property syntax to declare properties on an object, as described in Encapsulating Data, the compiler automatically synthesizes the relevant getter and setter methods (unless you indicate otherwise).
>
> A getter method should use the same name as the property.
> The exception to this rule is for Boolean properties, for which the getter method should start with is. For a property called paused, for example, the getter method should be called isPaused.
>
> The setter method for a property should use the form setPropertyName:. For a property called firstName, the setter method should be called setFirstName:; for a Boolean property called paused, the setter method should be called setPaused:.

It'd better follow these conventions, otherwise KVC might not work well.

### Object creation method names

> Class factory methods should always start with the name of the class (without the prefix) that they create, with the exception of subclasses of classes with existing factory methods. 
>
> In the case of the NSArray class, for example, the factory methods start with array. The NSMutableArray class doesn’t define any of its own class-specific factory methods, so the factory methods for a mutable array still begin with array.

Compiler will judge which rule it should follow based on the name of the creation method. For more information, please check it at [here](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/MemoryMgmt/Articles/MemoryMgmt.html#//apple_ref/doc/uid/10000011i).

# Key-Value Coding(KVC)

> Key-value coding is a mechanism for indirectly accessing an object’s attributes and relationships using string identifiers.

## Object Properties

> Central to key-value coding (or KVC) is the general notion of properties. A property refers to a unit of state that an object encapsulates. 
>
> A property can be one of two general types: an `attribute` (for example, name, title, subtotal, or textColor) or a `relationship` to other objects. 
>
> Relationships can be either to-one or to-many. The value for a to-many relationship is typically an array or set, depending on whether the relationship is ordered or unordered.

KVC locates object's property through a key -> string identifier.
`Key` usually corresponds to `name of an accessor method` or `instance variable defined by the object`.

The key conventions:

> It must be ASCII encoded, begin with a lowercase letter, and have no whitespace.

`Key path` is a string of dot-separated keys that is used to specify object properties sequence to traverse.

## Making a Class KVC Compliant

> The `NSKeyValueCoding` informal protocol makes KVC possible. 
>
> Two of its methods
> - [valueForKey:](https://developer.apple.com/library/archive/documentation/LegacyTechnologies/WebObjects/WebObjects_3.5/Reference/Frameworks/ObjC/EOF/EOControl/Classes/NSObjectAdditions/Description.html#//apple_ref/occ/instm/NSObject/valueForKey:)
> - [setValue:forKey:](https://developer.apple.com/documentation/objectivec/nsobject/1415969-setvalue)
>
> `NSObject` provides a default implementation of these methods, and if a class is compliant with key-value coding, it can rely on this implementation.

For making a to-one relationship property, the class must implement at least one of bellow:

- The class has a declared property with the name `key`.
- It implements accessor methods named key and, if the property is mutable, `setKey:`. (If the property is a Boolean attribute, the getter accessor method has the form `isKey`.)
- It declares an instance variable of the form `key` or `_key`.

For more details, please check [here](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/KeyValueCoding/index.html#//apple_ref/doc/uid/10000107i).

# Key-Value Observing(KVO)

> Key-value observing is a mechanism that enables an object to be notified directly when a property of another object changes.
>
> It is a mode of communication between objects in applications designed in conformance with the Model-View-Controller design pattern.
>
> With KVO, one object can observe any properties of another object, including simple attributes, to-one relationships, and to-many relationships. An object can find out what the current and prior values of a property are. Observers of to-many relationships are informed not only about the type of change made, but are told which objects are involved in the change.

Differences between KVO and `NSNotification`: 

- `NSNotification` and `NSNotificationCenter`: observe all objects that have registered as observers
- KVO: observe objects when changes in property values occur.

## Implementing KVO

> The root class, NSObject, provides a base implementation of key-value observing that you should rarely need to override. Thus all Cocoa objects are inherently capable of key-value observing.

For receiving KVO notifications:

- ensure observed class is `key-value observing compliant` for the property that you want to observe. KVO compliance requires the class of the observed object to also be KVC compliant and to either allow automatic observer notifications for the property or implement manual key-value observing for the property.
- Add an observer of the object whose value can change. You do this by calling [addObserver:forKeyPath:options:context:](https://developer.apple.com/documentation/objectivec/nsobject/1412787-addobserver). The observer is just another object in your application.
- In the observer object, implement the method [observeValueForKeyPath:ofObject:change:context:](https://developer.apple.com/documentation/objectivec/nsobject/1416553-observevalueforkeypath). This method is called when the value of the observed object’s property changes.

#### Reference

- <https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/ProgrammingWithObjectiveC/Conventions/Conventions.html#//apple_ref/doc/uid/TP40011210-CH10-SW1>
- <https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/KeyValueCoding/index.html#//apple_ref/doc/uid/10000107i>
