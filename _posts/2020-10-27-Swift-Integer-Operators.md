---
layout: post
title: Swift Integer Operators
date: 2020-10-27 21:35:00
comment_id: 105
categories: [Swift]
tags: [bitwise, bit shift, overflow]
---

I'd like to memo some arithmetic and bitwise operations in this article. [Here](https://developer.apple.com/documentation/swift/int/integer_operators) lists the whole integer operations.

## Masked Arithmetic

### Overflow Operators

> If you try to insert a number into an integer constant or variable that cannot hold that value, by default Swift reports an error rather than allowing an invalid value to be created. This behavior gives extra safety when you work with numbers that are too large or too small.

```swift
/* &+ 
Returns the sum of the two given values, wrapping the result in 
case of any overflow.
*/
static func &+ (lhs: Int, rhs: Int) -> Int

// --- Sample ---

var unsignedOverflow = UInt8.max
// unsignedOverflow equals 255, which is the maximum value a 
UInt8 can hold
unsignedOverflow = unsignedOverflow &+ 1
// unsignedOverflow is now equal to 0
// The variable unsignedOverflow is initialized with the 
// maximum value a UInt8 can hold (255, or 11111111 in binary). 
// It is then incremented by 1 using the overflow addition 
// operator (&+). This pushes its binary representation just 
// over the size that a UInt8 can hold, causing it to overflow 
// beyond its bounds, as shown in the diagram below. The value 
// that remains within the bounds of the UInt8 after the 
// overflow addition is 00000000, or zero.

let y: Int8 = 100 &+ 121
// y == -35 (after overflow)

/* &-
Returns the difference of the two given values, wrapping the 
result in case of any overflow.
*/
static func &- (lhs: Int, rhs: Int) -> Int

// --- Sample ---

var unsignedOverflow = UInt8.min
// unsignedOverflow equals 0, which is the minimum value a 
UInt8 can hold
unsignedOverflow = unsignedOverflow &- 1
// unsignedOverflow is now equal to 255
// The minimum value that a UInt8 can hold is zero, or 00000000 
// in binary. If you subtract 1 from 00000000 using the 
// overflow subtraction operator (&-), the number will overflow 
// and wrap around to 11111111, or 255 in decimal.

let y: UInt8 = 10 &- 21
// y == 245 (after overflow)

var signedOverflow = Int8.min
// signedOverflow equals -128, which is the minimum value an 
Int8 can hold
signedOverflow = signedOverflow &- 1
// signedOverflow is now equal to 127
// The minimum value that an Int8 can hold is -128, or 10000000 
// in binary. Subtracting 1 from this binary number with the 
// overflow operator gives a binary value of 01111111, which 
// toggles the sign bit and gives positive 127, the maximum 
// positive value that an Int8 can hold.

/* &*
Returns the product of the two given values, wrapping the 
result in case of any overflow.
*/
static func &* (Int, Int) -> Int

// --- Sample ---

let x: Int8 = 10 &* 5
// x == 50
let y: Int8 = 10 &* 50
// y == -12 (after overflow)
// the product of 10 and 50 is greater than the maximum 
// representable Int8 value, so the result is the partial value 
// after discarding the overflowing bits.
```

## Bitwise Operators

```swift
/* ^
Returns the result of performing a bitwise XOR operation on the 
two given values.
A bitwise XOR operation, also known as an exclusive OR 
operation, results in a value that has each bit set to 1 where 
one or the other but not both of its arguments had that bit set 
to 1.
*/
static func ^ (lhs: Int, rhs: Int) -> Int

// --- Sample ---

let x: UInt8 = 5          // 0b00000101
let y: UInt8 = 14         // 0b00001110
let z = x ^ y             // 0b00001011
// z == 11
```

## Bit Shift

```swift
/* <<
Returns the result of shifting a value’s binary representation 
the specified number of digits to the left.
The << operator performs a smart shift, which defines a result 
for a shift of any value.
- Using a negative value for rhs performs a right shift using abs(rhs).
- Using a value for rhs that is greater than or equal to the bit width of lhs is an overshift, resulting in zero.
- Using any other value for rhs performs a left shift on lhs by that amount.
*/
static func << <Other>(lhs: Int, rhs: Other) -> Int where Other : BinaryInteger

// --- Sample ---

let x: UInt8 = 30                 // 0b00011110
let y = x << 2
// y == 120                       // 0b01111000
let z = x << 11
// z == 0                         // 0b00000000
// x is overshifted such that all of its bits are set to zero.

// negative value as rhs is the same as performing a right shift with abs(rhs).
let a = x << -3
// a == 3                         // 0b00000011
let b = x >> 3
// b == 3                         // 0b00000011

/* &<<
Returns the result of shifting a value’s binary representation 
the specified number of digits to the left, masking the shift 
amount to the type’s bit width.
Use the masking left shift operator (&<<) when you need to 
perform a shift and "are sure that the shift amount is in the 
range 0..<lhs.bitWidth". Before shifting, the masking left 
shift operator masks the shift to this range. The shift is 
performed using this masked value.
*/
static func &<< (lhs: Int, rhs: Int) -> Int

// --- Sample ---

let x: UInt8 = 30                 // 0b00011110
let y = x &<< 2
// y == 120                       // 0b01111000
let z = x &<< 8
// z == 30                        // 0b00011110
// use 8 as the shift amount, the method first masks the shift 
// amount to zero, and then performs the shift, resulting in no 
// change to the original value.

/* &<<=
Returns the result of shifting a value’s binary representation 
the specified number of digits to the left, masking the shift 
amount to the type’s bit width, and stores the result in the 
left-hand-side variable.
The &<<= operator performs a masking shift, where the value 
used as rhs is masked to produce a value in the range 0..<lhs.
bitWidth. The shift is performed using this masked value.
*/
static func &<<= (lhs: inout Int, rhs: Int)

// --- Sample ---

var x: UInt8 = 30                 // 0b00011110
x &<<= 2
// x == 120                       // 0b01111000

var y: UInt8 = 30                 // 0b00011110
y &<<= 19
// y == 240                       // 0b11110000
// pass 19 as rhs, the method first bitmasks rhs to 3, and then // uses that masked value as the number of bits to shift lhs.
```

#### Reference

- <https://developer.apple.com/documentation/swift/int/integer_operators>
- <https://docs.swift.org/swift-book/LanguageGuide/AdvancedOperators.html#ID37>
