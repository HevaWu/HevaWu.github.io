---
layout: post
title: WWDC2021 What's New in Foundation
date: 2021-06-09 17:31:00
comment_id: 164
categories: [WWDC2021, Swift]
tags: [Foundation]
---

# AttributedString

- Characters
- Ranges
- Dictionary

Feature:

- Value type
- compatible with string
- localizable
- safety and security

```swift
func attributedStringBasics(important: Bool) {
    var thanks = AttributedString("Thank you!")
    thanks.font = .body.bold()

    var website = AttributedString("Please visit our website.")
    website.font = .body.italic()
    website.link = URL(string: "http://www.example.com")

    var container = AttributeContainer()
    if important {
        container.foregroundColor = .red
        container.underlineColor = .primary
    } else {
        container.foregroundColor = .primary
    }

    thanks.mergeAttributes(container)
    website.mergeAttributes(container)

    print(thanks)
    print(website)
}
```

## AttributedString views

```swift
// characters

func attributedStringCharacters() {
    var message = AttributedString(localized: "Thank you! _Please visit our [website](http://www.example.com)._")
    let characterView = message.characters
    for i in characterView.indices where characterView[i].isPunctuation {
        message[i..<characterView.index(after: i)].foregroundColor = .orange
    }

    print(message)
}

// runs

func attributedStringRuns() {
    let message = AttributedString(localized: "Thank you! _Please visit our [website](http://www.example.com)._")
    let runCount = message.runs.count
    // runCount is 4
    print(runCount)

    let firstRun = message.runs.first!
    let firstString = String(message.characters[firstRun.range])
    // firstString is "Thank you!"
    print(firstString)
}

func attributedStringRuns2() {
    let message = AttributedString(localized: "Thank you! _Please visit our [website](http://www.example.com)._")

    let linkRunCount = message.runs[\.link].count
    // linkRunCount is 3
    print(linkRunCount)

    var insecureLinks: [URL] = []
    for (value, range) in message.runs[\.link] {
        if let v = value, v.scheme != "https" {
            insecureLinks.append(v)
        }
    }
    // insecureLinks is [http://www.example.com]
    print(insecureLinks)
}

// mutation

func attributedStringRuns2() {
    let message = AttributedString(localized: "Thank you! _Please visit our [website](http://www.example.com)._")

    let linkRunCount = message.runs[\.link].count
    // linkRunCount is 3
    print(linkRunCount)

    var insecureLinks: [URL] = []
    for (value, range) in message.runs[\.link] {
        if let v = value, v.scheme != "https" {
            insecureLinks.append(v)
        }
    }
    // insecureLinks is [http://www.example.com]
    print(insecureLinks)
}
```

## Localization

- Build Settings -> Localizations -> turn on `Use Compiler to Extract Swift Strings`

```swift
// localization

func prompt(for document: String) -> String {
    String(localized: "Would you like to save the document “\(document)”?")
}

func attributedPrompt(for document: String) -> AttributedString {
    AttributedString(localized: "Would you like to save the document “\(document)”?")
}
```

## Archive AttributedString

- NSAttributedString
- Codable
- Custom attributes

```swift
struct FoodItem: Codable {
    // Placeholder type to demonstrate concept
    var name: String
}

struct Receipt: Codable {
    var items: [FoodItem]
    var thankYouMessage: AttributedString
}

func codableBasics() {
    let message = AttributedString(localized: "Thank you! _Please visit our [website](http://www.example.com)._")
    let receipt = Receipt(items: [FoodItem(name: "Juice")], thankYouMessage: message)

    let encoded = try! JSONEncoder().encode(receipt)
    let decodedReceipt = try! JSONDecoder().decode(Receipt.self, from: encoded)

    print("\(decodedReceipt.thankYouMessage)")
}
```

## Attribute Keys

- declares type of value
- customizes encoding behavior

```swift
This text contains ^[an attribute](rainbow: 'extreme').

This text contains ^[two attributes](rainbow: 'extreme', otherValue: 42).

This text contains ^[an attribute with 2 properties](someStuff: {key: true, key2: false}).
```

```swift
// AttributeScopes
extension AttributeScopes {
    struct CaffeAppAttributes : AttributeScope {
        let rainbow: RainbowAttribute

        let swiftUI: SwiftUIAttributes
    }

    var caffeApp: CaffeAppAttributes.Type { CaffeAppAttributes.self }
}

func customAttributesFromMarkdown() {
    let header = AttributedString(localized: "^[Fast & Delicious](rainbow: 'extreme') Food", including: \.caffeApp)

    print(header)
}
```

# Formatters

## Date Formatting

```swift
func formattingDates() {
    // Note: This will use your current date & time plus current locale. Example output is for en_US locale.
    let date = Date.now

    let formatted = date.formatted()
    // example: "6/7/2021, 9:42 AM"
    print(formatted)

    let onlyDate = date.formatted(date: .numeric, time: .omitted)
    // example: "6/7/2021"
    print(onlyDate)

    let onlyTime = date.formatted(date: .omitted, time: .shortened)
    // example: "9:42 AM"
    print(onlyTime)
}

func formattingDatesWithStyles() {
    // Note: This will use your current date & time plus current locale. Example output is for en_US locale.
    let date = Date.now

    let formatted = date.formatted(.dateTime)
    // example: "6/7/2021, 9:42 AM"
    print(formatted)
}

func formattingDatesMoreExamples() {
    // Note: This will use your current date & time plus current locale. Example output is for en_US locale.
    let date = Date.now

    let formatted = date.formatted(.dateTime.year().day().month())
    // example: "Jun 7, 2021"
    print(formatted)

    let formattedWide = date.formatted(.dateTime.year().day().month(.wide))
    // example: "June 7, 2021"
    print(formattedWide)

    let formattedWeekday = date.formatted(.dateTime.weekday(.wide))
    // example: "Monday"
    print(formattedWeekday)

    let logFormat = date.formatted(.iso8601)
    // example: "20210607T164200Z"
    print(logFormat)

    let fileNameFormat = date.formatted(.iso8601.year().month().day().dateSeparator(.dash))
    // example: "2021-06-07"
    print(fileNameFormat)
}

func formattingIntervals() {
    // Note: This will use your current date & time plus current locale. Example output is for en_US locale.
    let now = Date.now
    // Note on time calculations: This represents the absolute point in time 5000 seconds from now. For calculations that are in terms of hours, days, etc., please use Calendar API.
    let later = now + TimeInterval(5000)

    let range = (now..<later).formatted()
    // example: "6/7/21, 9:42 – 11:05 AM"
    print(range)

    let noDate = (now..<later).formatted(date: .omitted, time: .complete)
    // example: "9:42:00 AM PDT – 11:05:20 AM PDT"
    print(noDate)

    let timeDuration = (now..<later).formatted(.timeDuration)
    // example: "1:23:20"
    print(timeDuration)

    let components = (now..<later).formatted(.components(style: .wide))
    // example: "1 hour, 23 minutes, 20 seconds"
    print(components)

    let relative = later.formatted(.relative(presentation: .named, unitsStyle: .wide))
    // example: "in 1 hour"
    print(relative)
}
```

## Parsing dates

```swift
func parsingDates() {
    let date = Date.now

    let format = Date.FormatStyle().year().day().month()
    let formatted = date.formatted(format)
    // example: "Jun 7, 2021"
    print(formatted)

    if let date = try? Date(formatted, strategy: format) {
        // example: 2021-06-07 07:00:00 +0000
        print(date)
    }
}

func parsingDatesStrategies() {
    let strategy = Date.ParseStrategy(
        format: "\(year: .defaultDigits)-\(month: .twoDigits)-\(day: .twoDigits)",
        timeZone: TimeZone.current)

    if let date = try? Date("2021-06-07", strategy: strategy) {
        // date is 2021-06-07 07:00:00 +0000
        print(date)
    }
}
```

## Number Formatting

```swift
func formattingNumbers() {
    // Note: This will use your current locale. Example output is for en_US locale.
    let value = 12345

    let formatted = value.formatted()
    // formatted is "12,345"
    print(formatted)
}

func formattingNumbersWithStyles() {
    // Note: This will use your current locale. Example output is for en_US locale.
    let percent = 25
    let percentFormatted = percent.formatted(.percent)
    // percentFormatted is "25%"
    print(percentFormatted)

    let scientific = 42e9
    let scientificFormatted = scientific.formatted(.number.notation(.scientific))
    // scientificFormatted is "4.2E10"
    print(scientificFormatted)

    let price = 29
    let priceFormatted = price.formatted(.currency(code: "usd"))
    // priceFormatted is "$29.00"
    print(priceFormatted)
}

func formattingLists() {
    // Note: This will use your current locale. Example output is for en_US locale.
    let list = [25, 50, 75].formatted(.list(memberStyle: .percent, type: .or))
    // list is "25%, 50%, or 75%"
    print(list)
}
```

# Automatic Grammar Agreement

Support for English and Spanish for now.

```swift
func addToOrderEnglish() {
    // Note: This will use your current locale. Example output is for en_US locale.
    let quantity = 2
    let size = "large"
    let food = "salad"

    let message = AttributedString(localized: "Add ^[\(quantity) \(size) \(food)](inflect: true) to your order")
    print(message)
}
```

#### Reference

- <https://developer.apple.com/wwdc21/10109>
