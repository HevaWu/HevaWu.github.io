---
layout: post
title: Swift Integers & Floating-Point Numbers
date: 2020-02-06 22:46:00
comments: true
disqus_category_id: SwiftIntegers&FloatingPointNumbers
categories: [Swift]
tags: [Integers]
---

# Integers

> Swift provides signed and unsigned integers in 8, 16, 32, and 64 bit forms. These integers follow a naming convention similar to C, in that an 8-bit unsigned integer is of type UInt8, and a 32-bit signed integer is of type Int32. Like all types in Swift, these integer types have capitalized names.

## Integer Bounds

It is okay to get the `minimum` & `maximum` values of each integer type with its `min` & `max` properties.

```swift
let minValue = UInt8.min // 0 with UInt8 type
let maxValue = UInt8.max // 255 with UInt8 type
```

## Int

In most cases, we don't need to pick the specific size of integer. Just use `Int` would be enough.

> - On a 32-bit platform, Int is the same size as Int32.
>
> - On a 64-bit platform, Int is the same size as Int64.

Unless we need to specify the size of integer, normally, use `Int` would be enough and could help increasing code consistency and interoperability. ex: 32bit platform `Int` could also store any value between `-2,147,483,648 ~ 2,147,483,647`, and is large enough for many integer ranges.

## UInt

Swift also provide unsigned integer type `UInt`, same as `Int`:

> - On a 32-bit platform, Int is the same size as Int32.
>
> - On a 64-bit platform, Int is the same size as Int64.

**Note**

> Use UInt only when you specifically need an unsigned integer type with the same size as the platform’s native word size. If this isn’t the case, Int is preferred, even when the values to be stored are known to be nonnegative. A consistent use of Int for integer values aids code interoperability, avoids the need to convert between different number types, and matches integer type inference, as described in [Type Safety and Type Inference](https://docs.swift.org/swift-book/LanguageGuide/TheBasics.html#ID322).

# Floating-Point Numbers

The numbers with a fractional component. Floating-point types can represent much wider range of values than integer types. and can store numbers much larger or smaller than `Int`. Swift provide 2 signed floating-point number types:

> - `Double` represents a 64-bit floating-point number.
>
> - `Float` represents a 32-bit floating-point number.

**Note**

> Double has a precision of at least `15` decimal digits, whereas the precision of Float can be as little as `6` decimal digits. The appropriate floating-point type to use depends on the nature and range of values you need to work with in your code. `In situations where either type would be appropriate`, `Double is preferred`.

#### References

<https://docs.swift.org/swift-book/LanguageGuide/TheBasics.html>