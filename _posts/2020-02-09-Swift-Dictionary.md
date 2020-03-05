---
layout: post
title: Swift Dictionary
date: 2020-02-09 12:23:00
comments: true
disqus_category_id: SwiftDictionary
categories: [Swift]
tags: [Collection Type]
---

`Dictionary` stores associations between keys of the same type and values of the same type in a collection with `no defined ordering`. Each value is associated with a unique key, which acts as a identifier for that value within the dictionay.

> Swift’s Dictionary type is bridged to Foundation’s NSDictionary class.

## Syntax

Swift dictionary could be writted full as `Dictionary<Key, Value>` where `Key` is the type of the value that can be used as a dictionary key, and `Value` is the type of value that the dictionary stores for those keys.

It also could be written in shorthand form as `[Key: Value]`. The shorthand form is preferred.

## Create

```swift
/// use initializer syntax
var namesOfIntegers = [Int: String]()
// namesOfIntegers is an empty [Int: String] dictionary

/// use empty dictionary literal
namesOfIntegers[16] = "sixteen"
// namesOfIntegers now contains 1 key-value pair
namesOfIntegers = [:]
// namesOfIntegers is once again an empty dictionary of type [Int: String]

/// use dictionary literal to init
var airports: [String: String] = ["YYZ": "Toronto Pearson", "DUB": "Dublin"]
```

## Default

```swift
var responseMessages = [200: "OK",
                        403: "Access forbidden",
                        404: "File not found",
                        500: "Internal server error"]

let httpResponseCodes = [200, 403, 301]
for code in httpResponseCodes {
    let message = responseMessages[code, default: "Unknown response"]
    print("Response \(code): \(message)")
}
// Prints "Response 200: OK"
// Prints "Response 403: Access Forbidden"
// Prints "Response 301: Unknown response"

let message = "Hello, Elle!"
var letterCounts: [Character: Int] = [:]
for letter in message {
    letterCounts[letter, defaultValue: 0] += 1
}
// letterCounts == ["H": 1, "e": 2, "l": 4, "o": 1, ...]
```

## More function

```swift
/// count
print("The airports dictionary contains \(airports.count) items.")
// Prints "The airports dictionary contains 2 items."

/// is empty
if airports.isEmpty {
    print("The airports dictionary is empty.")
} else {
    print("The airports dictionary is not empty.")
}
// Prints "The airports dictionary is not empty."

/// update
if let oldValue = airports.updateValue("Dublin Airport", forKey: "DUB") {
    print("The old value for DUB was \(oldValue).")
}
// Prints "The old value for DUB was Dublin."

/// retrieve
if let airportName = airports["DUB"] {
    print("The name of the airport is \(airportName).")
} else {
    print("That airport is not in the airports dictionary.")
}
// Prints "The name of the airport is Dublin Airport."

/// remove
airports["APL"] = "Apple International"
// "Apple International" is not the real airport for APL, so delete it
airports["APL"] = nil
// APL has now been removed from the dictionary
// OR
if let removedValue = airports.removeValue(forKey: "DUB") {
    print("The removed airport's name is \(removedValue).")
} else {
    print("The airports dictionary does not contain a value for DUB.")
}
// Prints "The removed airport's name is Dublin Airport."
```

## Iterate Ove a Dictionary

```swift
for (airportCode, airportName) in airports {
    print("\(airportCode): \(airportName)")
}
// LHR: London Heathrow
// YYZ: Toronto Pearson

for airportCode in airports.keys {
    print("Airport code: \(airportCode)")
}
// Airport code: LHR
// Airport code: YYZ

for airportName in airports.values {
    print("Airport name: \(airportName)")
}
// Airport name: London Heathrow
// Airport name: Toronto Pearson

let airportCodes = [String](airports.keys)
// airportCodes is ["LHR", "YYZ"]

let airportNames = [String](airports.values)
// airportNames is ["London Heathrow", "Toronto Pearson"]
```

#### References

https://docs.swift.org/swift-book/LanguageGuide/CollectionTypes.html

https://developer.apple.com/documentation/swift/dictionary/2894528-subscript