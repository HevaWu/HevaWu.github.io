---
layout: post
title: Swift String To Int Radix
date: 2020-03-14 22:37:00
comments: true
disqus_category_id: SwiftStringToIntRadix
categories: [Swift]
tags: [Radix]
---

Swift also provide the String Radix convert functions. This post just for sharing how to use them ~

## Int

By using `Int.init(_:radix:)`, we could covert a String to Int by specific radix.

> **text**:
>The ASCII representation of a number in the radix passed as radix.
>
> **radix**: 
>The radix, or base, to use for converting text to an integer value. radix must be in the range 2...36. The default is 10.

ex:

```swift
let x = Int("123")
// x == 123

let y = Int("-123", radix: 8)
// y == -83
let y = Int("+123", radix: 8)
// y == +83

let z = Int("07b", radix: 16)
// z == 123
```

## String

By using `String.init(_:radix:uppercase:)`, we could convert a Int to String by specific radix.

> **value**
> The value to convert to a string.
>
> **radix**
> The base to use for the string representation. radix must be at least 2 and at most 36. The default is 10.
>
> **uppercase**
> Pass true to use uppercase letters to represent numerals greater than 9, or false to use lowercase letters. The default is false.

ex:

```swift
let v = 999_999
print(String(v, radix: 2))
// Prints "11110100001000111111"

print(String(v, radix: 16))
// Prints "f423f"
print(String(v, radix: 16, uppercase: true))
// Prints "F423F"
```

#### Reference

<https://developer.apple.com/documentation/swift/string/2997127-init>

<https://developer.apple.com/documentation/swift/int/2924481-init>