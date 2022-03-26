---
layout: post
title: Swift String Literals
date: 2021-06-19 16:00:00
comment_id: 167
categories: [Swift]
tags: [String]
---

> A string literal is a sequence of characters surrounded by double quotation marks (").

Here are some usage:

```swift
// basic usage
let someString = "Some string literal value"

// multiline
let multilineString = """
These are the same.
"""

// line break in multiline ( use \ )
let softWrappedQuotation = """
The White Rabbit put on his spectacles.  "Where shall I begin, \
please your Majesty?" he asked.

"Begin at the beginning," the King said gravely, "and go on \
till you come to the end; then stop."
"""

// line feed in multiline (empty line before and end )
let lineBreaks = """

This string starts with a line break.
It also ends with a line break.

"""

// whitespace at begin of one line in multiline
let linesWithIndention = """
    This line doesn't begin with whitespace.
        This line begin with 4 whitespace.
    This line doesn't begin with whitespace.
"""
```

## Special char in String Literal

> String literals can include the following special characters:
>
> - The escaped special characters \0 (null character), \\ (backslash), \t (horizontal tab), \n (line feed), \r (carriage return), \" (double quotation mark) and \' (single quotation mark)
> - An arbitrary Unicode scalar value, written as \u{n}, where n is a 1–8 digit hexadecimal number (Unicode is discussed in Unicode below)

Some example:

```swift
let wiseWords = "\"Imagination is more important than knowledge\" - Einstein"
// "Imagination is more important than knowledge" - Einstein
let dollarSign = "\u{24}"        // $,  Unicode scalar U+0024
let blackHeart = "\u{2665}"      // ♥,  Unicode scalar U+2665
let sparklingHeart = "\u{1F496}" // 💖, Unicode scalar U+1F496

// include """ in multiline string (escape at least one quotation mark)
let threeDoubleQuotationMarks = """
Escaping the first quotation mark \"""
Escaping all three quotation marks \"\"\"
"""
```

## Extended String Delimiters

> place a string literal within `extended delimiters` to include special characters in a string without invoking their effect.

Some examples:

```swift
let str = #"Line 1\nLine 2"#
// prints the line feed escape sequence (\n) rather than printing the string across two lines.

// want to break line in extended delimiters
let str = #"Line 1\#nLine 2"#
// or
let str = ###"Line1\###nLine2"###

// extended delimiters in multiline
// include the text """ in a multiline string
let threeMoreDoubleQuotationMarks = #"""
Here are three more double quotes: """
"""#

// use string interpolation inside a string that uses extended delimiters
print(#"6 times 7 is \#(6 * 7)."#)
// Prints "6 times 7 is 42."

print(#"Write an interpolated string in Swift using \(multiplier)."#)
// Prints "Write an interpolated string in Swift using \(multiplier)."
```

#### Reference

- <https://docs.swift.org/swift-book/LanguageGuide/StringsAndCharacters.html>
