---
layout: post
title: WWDC2021 What's New in UIKit
date: 2021-06-10 12:16:00
comment_id: 166
categories: [WWDC2021]
tag: [UIKit, iPadOS15, iOS15]
---

# Productivity

## iPad multitasking

```swift
// Building an "Open in New Window" action
let newSceneAction = UIWindowScene.ActivationAction({ _ in
    // Create the user activity that represents new scene content
    let userActivity = NSUserActivity(activityType: "com.myapp.detailscene")

    // Return activation configuration
    return UIWindowScene.ActivationConfiguration(userActivity: userActivity)
})
```

## Keyboard navigation & shortcuts

iPadOS15

- enable band selection for UICollectionViews that support multi-selection
- Add Pointer accessories
- Keyboard shortcuts
  - Use `UIMenuBuilder`
  ```swift
  class AppDelegate: UIResponder, UIApplicationDelegate {
      override fund buildMenu(with builder: UIMenuBuilder) {
          // Use the builder to modify the main menu
      }
  }
  ```
  - Assign categories
  - Audit uses of `UIResponder.keyCommands`

# UI Refinements

- UITabBar: enhance support for SF Symbols

*NOTE: need to audit where setting bar's `isTranslucent` property to false and check UIViewControllers that have non-standard `edgesForExtendedLayout`*

## UIBarAppearance

```swift
// Custom scrollEdgeAppearance
let appearance = UITabBarAppearance()
appearance.backgroundEffect = nil
appearance.backgroundColor = .blue
tabBar.scrollEdgeAppearance = appearance

// Specify the content scrollView
let scrollView = ...
viewController.setContentScrollView(scrollView, for: .bottem)
```

## List headers

`UIListContentConfiguration API`

![](/images/2021-06-10-WWDC2021-Whats-New-in-UIKit/list.png)

## UIListSeparatorConfiguration

- Advanced customization of separator appearance
  - Visibility
  - Color
  - Insets
- Control over top and bottom separators for each item

## Sheet presentations

- Half height sheets
- Optionally non-mondal

## UIDatePicker

- Use Keyboard to input

# API enhancements

## UIButton API

- Style
  - plain
  - gray
  - tinted
  - filled
  - multiple lines (new)
- Menu
  - pull-down
  - pop-up

```swift
// create button with UIButton.Configuration
var config = UIButton.Configuration.tinted()

config.title = "Add to Cart"
config.image = UIImage(systemName: "cart.badge.plus")
config.imagePlacement = .trailing
config.buttonSize = .large
config.cornerStyle = .capsule

self.addToCartButton = UIButton(configuration: config)
```

- Submenus
  - new ui for `UIMenu` submenus
  - preserves menu hierarchy
  - no api adoption required
- SF Symbol enhancements
  - monochrome
  - hierarchical
  - palette
  - multicolor
![](/images/2021-06-10-WWDC2021-Whats-New-in-UIKit/SF.png)
```swift
// use a hierarchical color symbol
let configuration = UIImage.SymbolConfiguration(hierarchicalColor: UIColor.systemOrange)

let image = UIImage(systemName: "sun.max.circle.fill", withConfiguration: configuration)
```
- SF Symbol variants
![](/images/2021-06-10-WWDC2021-Whats-New-in-UIKit/variants.png)
- Content size category limits
  - restrict dynamic type sizes in view hierarchies
  - set minimum and maximum size
```swift
extension UIView {
    var minimumContentSizeCategory: UIContentSizeCategory
    var maximumContentSizeCategory: UIContentSizeCategory
}
```
- Dynamic tint color: `UIColor.tintColor`, can using with new `UIButton.Configuration` and coloful SF Symbols APIs
- Color picker enhancements
  - Continuous change
- TextKit2
  - new text layout API
  - used behind scenes in UITextField
- UIScene state restoration
  - NSUserActivity represents interface state
  - State restoration enhancements
    - text interaction state properties
    - callback for restoring state after storyboard load
    - ability to extend state restoration
- Cell configuration closures
  - UICollectionView and UITableView
  - React to changes in cell state
```swift
let cell: UICollectionViewCell = ...
cell.configurationUpdateHandler = { cell, state in
    var content = UIListContentConfiguration.cell().updated(for: state)
    if state.isDisabled {
        content.textProperties.color = .systemGray
    }
    cell.contentConfiguration = content
}
```
- Diffable data source improvements
  - apply snapshots without animation
  - new api to reconfigure items

# Performance

## Cell prefetching improvements

- behind-the-scenes prefetching changes
- no adoption required
- up to 2x more time to prepare cells

```swift
if let image = UIImage(contentOfFile: pathToImage) {
    async {
        let preparedImage = await image.byPreparingForDisplay()
        imageView.image = preparedImage
    }
}

if let bigImage = UIImage(contentsOfFile: pathToBigImage) {
    async {
        let smallImage = await bigImage.byPreparingThumbnail(ofSize: smallSize)
        imageView.image = smallImage
    }
}
```

# Security and privacy

## Location Button

- One-time access to location
- Flexible configuration API

## Standard paste items

UIResponder selectors and UIAction identifiers for:

- paste
- paste and go
- paste and search
- paste and match style

## Private Click Measurement

From iOS 14.5

- Privacy-preserving measurement of ad clicks and taps
- Cover ads with UIEventAttributionViews
- Supply UIEventAttribution when opening a URL

#### Reference

- <https://developer.apple.com/wwdc21/10059>
