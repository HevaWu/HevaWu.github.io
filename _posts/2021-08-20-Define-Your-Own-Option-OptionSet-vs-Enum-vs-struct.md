---
layout: post
title: Define Your Own Option - OptionSet vs Enum vs Struct
date: 2021-08-20 11:29:00
comment_id: 188
categories: [Swift]
tags: [OptionSet, Enum, Struct]
---

Recently our project is trying to do modularization. For some parts, we might would like to make it more generic. ex: logging system's category part.

I would like to post what I tested at here(I will take logging category as an example in this blog). Mainly, I tried `OptionSet`, `Enum`, and `struct`.

```swift
// calling it as ⬇️
func log(_ category: %OurStructure%) {
    print(category.description)
}
```

For what the final structure should satisfy:

1. CustomStringConvertible object. We need to call `category.description` to retrieve correct description string.
2. Support multi-category, and always keep them in order. ex: `.categoryA, .categoryB` and `.categoryB, .categoryA` should output same order
3. Generic. It might be used in different module, so we need to provide way to let each module define their own category list.
4. No conflicts. Though we put them in different module, we also need to make sure moduleA category list will not cause any conflicts with other modules. Even 2 module might have same category name.

My picking: under my testing, `struct` will be the most proper way to satisfy all requirements. But I would like to list what I tested and reason why I didn't pick others method at here. You can also find my test code at here: <https://gist.github.com/HevaWu/40bad4ca94beb7a2a60e8c1f98c6470a>

## OptionSet

⚠️ has limitation.

When I trying to do it, my first idea is implement it by using `OptionSet`. Because OptionSet could handle multi-objects things well formed. However, I stuck at the `3 & 4`. Here is my test code:

```swift
struct LCategory: OptionSet, CustomStringConvertible {
    let rawValue: Int

    static let categoryA = LCategory(rawValue: 1 << 0)
    static let categoryB = LCategory(rawValue: 1 << 1)
    static let categoryC = LCategory(rawValue: 1 << 2)
    static let categoryD = LCategory(rawValue: 1 << 3)
    static let categoryE = LCategory(rawValue: 1 << 4)

    static var getDescriptionMap: [Int: String] = [
        LCategory.categoryA.rawValue: "categoryA",
        LCategory.categoryB.rawValue: "categoryB",
        LCategory.categoryC.rawValue: "categoryC",
        LCategory.categoryD.rawValue: "categoryD",
        LCategory.categoryE.rawValue: "categoryE",
    ]

    var description: String {
        var valList = [String]()
        for k in getOptionList() {
            if let val = Self.descriptionMap[k] {
                valList.append(val)
            } else {
                assertionFailure("LCategory descriptionMap not contains key \(k)")
            }
        }
        var str = String("[")
        str.append(contentsOf: valList.joined(separator: "]["))
        str.append("]")
        return str
    }

    func getOptionList() -> [Int] {
        var list = [Int]()
        let largest = rawValue.bitWidth - rawValue.leadingZeroBitCount
        for i in 0..<largest {
            if rawValue & (1 << i) != 0 {
                list.append(1 << i)
            }
        }
        return list
    }
}

// call it like

func log(_ category: LCategory) {
    print(category.description)
}

log(.categoryA)
log([.categoryB, .categoryA])
log([.categoryA, .categoryB])

/* output
[categoryA]
[categoryA][categoryB]
[categoryA][categoryB]
*/

// it can also extend by adding options in other places/modules like

extension LCategory {
    static let categoryZ = LCategory(rawValue: 1 << 25)
}
LCategory.descriptionMap[LCategory.categoryZ.rawValue] = "categoryZ"

log([.categoryZ, .categoryA, .categoryB])

// output
// [categoryA][categoryB][categoryZ]
```

It can work well when

- we have fixed/limited(< 64) categories
- it requires to record each module's categories, otherwise some module's category rawValue might have conflicts with others(ex: 2 category have same rawValue as 1<<4)

I tried to think if we can make this part as a `protocol LCategoryType: OptionSet`, and to design it more generic way. However, `OptionSet` contains `associatedtype`, and it limit the way to let us generalize it. 😢

```swift
// error is:
Protocol 'LCategoryType' can only be used as a generic constraint because it has Self or associated type requirements
```

Here is my test code:

```swift
protocol LCategoryType: OptionSet, CustomStringConvertible {
    var rawValue: Int { get set }
    static var descriptionMap: [Int: String] { get set }
}

extension LCategoryType {
    var description: String {
        var valList = [String]()
        for k in getOptionList() {
            if let val = Self.descriptionMap[k] {
                valList.append(val)
            } else {
                assertionFailure("LCategory descriptionMap not contains key \(k)")
            }
        }
        var str = String("[")
        str.append(contentsOf: valList.joined(separator: "]["))
        str.append("]")
        return str
    }

    func getOptionList() -> [Int] {
        var list = [Int]()
        let largest = rawValue.bitWidth - rawValue.leadingZeroBitCount
        for i in 0..<largest {
            if rawValue & (1 << i) != 0 {
                list.append(1 << i)
            }
        }
        return list
    }
}

struct LCategoryTest: LCategoryType {
    var rawValue: Int

    static let categoryA = LCategoryTest(rawValue: 1 << 0)
    static let categoryB = LCategoryTest(rawValue: 1 << 1)

    static var descriptionMap: [Int : String] = [
        LCategoryTest.categoryA.rawValue: "categoryA",
        LCategoryTest.categoryB.rawValue: "categoryB"
    ]
}

func log(_ category: LCategoryType) { // error in this line
    print(category.description)
}
```

Since this is because `OptionSet` contains the `associatedType` define, so I cannot find more proper way to generic it. (which means `protocol + OptionSet` not working)

One solution if we want to use protocol maybe, we make `protocol LCategoryType: CustomStringConvertible`, and `LCategoryModuleA: OptionSet`, however, that would be meaningless, and we have to copy & paste same code(`getOptionList()`) everytime

## Enum

⚠️ has limitation.

`Enum` is also a frequent way to define. But we all know we have to put all case together. This means it will not satisfy my requirement No.3

```swift
enum LCategory: String {
    case categoryA
    case categoryB
    case categoryC
}

extension LCategory {
    case categoryD // error: Enum 'case' is not allowed outside of an enum
}
```

## Struct

✅ My final pick. It is more flexible and easier to handle.

To make it generic, we define a `LCategoryType` for later extending in other modules. Here is my test code:

```swift
struct LCategory: CustomStringConvertible {
    private let typeList: [LCategoryType]

    init(_ category: LCategoryType) {
        typeList = [category]
    }

    init(_ cateogories: [LCategoryType]) {
        typeList = cateogories
    }

    var description: String {
        let sortedList = typeList.sorted().map { $0.rawValue }
        var str = String()
        str.append("[")
        str.append(sortedList.joined(separator: "]["))
        str.append("]")
        return str
    }
}

struct LCategoryType {
    let rawValue: String

    static let categoryA = LCategoryType(rawValue: "categoryA")
    static let categoryB = LCategoryType(rawValue: "categoryB")
    static let categoryC = LCategoryType(rawValue: "categoryC")
    static let categoryD = LCategoryType(rawValue: "categoryD")
}

extension LCategoryType: Comparable {
    static func < (lhs: LCategoryType, rhs: LCategoryType) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
}

extension LCategoryType {
    static let categoryF = LCategoryType(rawValue: "categoryF")
}

func log(category: LCategory) {
    print(category.description)
}

log(category: .init([.categoryF, .categoryA, .categoryB]))
log(category: .init(.categoryA))

/* output
[categoryA][categoryB][categoryF]
[categoryA]
*/
```

# Sum

- OptionSet
  - good:
    - Swift default suggested Option way. Can help quick mapping included options.
    - Good for Short options filter. Because it has limitation on `Int` type.
  - limitation:
    - `Int`: If you want to make a string optionSet, you might need to do more research.
    - It cannot be generalize, because it contains associatedType, and we cannot downcast it well.
- Enum
  - good:
    - switch case easily
    - good for short case handling/processing
  - limitation:
    - cannot handle to put multi-case directly, we might need to define another structure to extra handle multi-case things
    - cannot add more case in other places
- Struct
  - good:
    - flexible, you can define anything you want directly
    - generic, since it is flexible, actually you could directly design your struct
  - limitation:
    - cannot use Swift existing structure's merits, ex: OptionSet has union/contains checking, if we want to do that check, we have to add other logic in our struct.

#### Related Link:

- My Test Gist: https://gist.github.com/HevaWu/40bad4ca94beb7a2a60e8c1f98c6470a
