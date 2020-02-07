---
layout: post
title: Swift Numeric Literals & Numeric Type Conversion
date: 2020-02-07 22:17:00
comments: true
disqus_category_id: SwiftNumericLiterals&NumericTypeConversion
categories: [Swift]
tags: [Numeric, Literal]
---

## Numeric Literals

Integer literals can be written as:

> - A decimal number, with no prefix
>
> - A binary number, with a 0b prefix
>
> - An octal number, with a 0o prefix
>
> - A hexadecimal number, with a 0x prefix

Decimal floats can also have an optional exponent, indicated by an uppercase or lowercase `e`. Hexadecimal floats must have an exponent indicated by an uppercase or lowercase `p`. ex:

```swift
1.25e2 means 1.25 x 10^2, or 125.0.
1.25e-2 means 1.25 x 10^-2, or 0.0125.

0xFp2 means 15 x 2^2, or 60.0.
0xFp-2 means 15 x 2^-2, or 3.75.
```

### Extra format

Integers and floats can be padded with extra zeros and can contain underscores to help with readability. ex:

```swift
let paddedDouble = 000123.456
let oneMillion = 1_000_000
let justOverOneMillion = 1_000_000.000_000_1
```

## Numeric Type Conversion

> - Use the Int type for all general-purpose integer constants and variables in your code, even if they’re known to be nonnegative. Using the default integer type in everyday situations means that integer constants and variables are immediately interoperable in your code and will match the inferred type for integer literal values.
>
> - Use other integer types only when they’re specifically needed for the task at hand, because of explicitly sized data from an external source, or for performance, memory usage, or other necessary optimization. Using explicitly sized types in these situations helps to catch any accidental value overflows and implicitly documents the nature of the data being used.

### Integer Conversion

The range of numbers that can be stored in an integer constant or variable is different for each numeric type:

- `Int8` constant or variable can store numbers between `-128` and `127`
- `UInt8` constant or variable can store numbers between `0` and `255`

Each numeric type can stoe a different range of values, so you must opt in to numeric type conversion by case.

`SomeType(ofInitialValue)` is the default way to call the initializer of a Swift type and pass in an initial value. Extending existing types to privide initializers that accept new types is covered in [Extensions](https://docs.swift.org/swift-book/LanguageGuide/Extensions.html).

### Integer and Floating-Point Conversion

Conversion between integer and floating-point numeric types must be made explicit. ex:

```swift
let three = 3
let pointOneFourOneFiveNine = 0.14159
let pi = Double(three) + pointOneFourOneFiveNine
// pi equals 3.14159, and is inferred to be of type Double
```

Floating-point to integer conversion must also be made explicit. ex:

```swift
let integerPi = Int(pi)
// integerPi equals 3, and is inferred to be of type Int
```

Floating-pint values are always truncated when used to initialize a new integer value. ex: 4.75 becomes 4, and -3.9 becomes -3.

#### Reference

https://docs.swift.org/swift-book/LanguageGuide/TheBasics.html