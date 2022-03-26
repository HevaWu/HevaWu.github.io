---
layout: post
title: UICollectionView Updates in WWDC2020
date: 2021-05-27 14:54:00
comment_id: 156
categories: [WWDC2020, iOS]
tags: [UIKit]
---

![](/images/2021-05-27-UICollectionView-Updates-in-WWDC2020/modern_collection_views.png)

# Advances in UICollectionView

## Section Snapshots

- Single sections data
- Composable data sources
- Hierarchical data

```swift
// NSDiffableDataSourceSectionSnapshot

public struct NSDiffableDataSourceSectionSnapshot<ItemIdentifierType> where ItemIdentifierType : Hashable {

    public init()

    public init(_ snapshot: NSDiffableDataSourceSectionSnapshot<ItemIdentifierType>)

    public mutating func append(_ items: [ItemIdentifierType], to parent: ItemIdentifierType? = nil)

    public mutating func insert(_ items: [ItemIdentifierType], before item: ItemIdentifierType)

    public mutating func insert(_ items: [ItemIdentifierType], after item: ItemIdentifierType)

    public mutating func delete(_ items: [ItemIdentifierType])

    public mutating func deleteAll()

    public mutating func expand(_ items: [ItemIdentifierType])

    public mutating func collapse(_ items: [ItemIdentifierType])

    public mutating func replace(childrenOf parent: ItemIdentifierType, using snapshot: NSDiffableDataSourceSectionSnapshot<ItemIdentifierType>)

    public mutating func insert(_ snapshot: NSDiffableDataSourceSectionSnapshot<ItemIdentifierType>, before item: (ItemIdentifierType))

    public mutating func insert(_ snapshot: NSDiffableDataSourceSectionSnapshot<ItemIdentifierType>, after item: (ItemIdentifierType))

    public func isExpanded(_ item: ItemIdentifierType) -> Bool

    public func isVisible(_ item: ItemIdentifierType) -> Bool

    public func contains(_ item: ItemIdentifierType) -> Bool

    public func level(of item: ItemIdentifierType) -> Int

    public func index(of item: ItemIdentifierType) -> Int?

    public func parent(of child: ItemIdentifierType) -> ItemIdentifierType?

    public func snapshot(of parent: ItemIdentifierType, includingParent: Bool = false) -> NSDiffableDataSourceSectionSnapshot<ItemIdentifierType>

    public var items: [ItemIdentifierType] { get }

    public var rootItems: [ItemIdentifierType] { get }

    public var visibleItems: [ItemIdentifierType] { get }
}

// UICollectionViewDiffableDataSource additions for iOS 14

extension UICollectionViewDiffableDataSource<Item, Section> {

    func apply(_ snapshot: NSDiffableDataSourceSectionSnapshot<Item>,
               to section: Section,
               animatingDifferences: Bool = true,
               completion: (() -> Void)? = nil)

    func snapshot(for section: Section) ->
                  NSDiffableDataSourceSectionSnapshot<Item>
}
```

Example:

```swift
// Example of using snapshots and section snapshots together

func update(animated: Bool=true) {

   // Add our sections in a specific order
   let sections: [Section] = [.recent, .top, .suggested]
   var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
   snapshot.appendSections(sections)
   dataSource.apply(snapshot, animatingDifferences: animated)

   // update each section's data via section snapshots in the existing position
   for section in sections {
      let sectionItems = items(for: section)
      var sectionSnapshot = NSDiffableDataSourceSectionSnapshot<Item>()
      sectionSnapshot.append(sectionItems)
      dataSource.apply(sectionSnapshot, to: section, animatingDifferences:animated)
   }
}

// Create hierarchical data for our Outline

var sectionSnapshot = ...

sectionSnapshot.append(["Smileys", "Nature",
                        "Food", "Activities",
                        "Travel", "Objects", "Symbols"])

sectionSnapshot.append(["🥃", "🍎", "🍑"], to: "Food")
```

## Expanding and collapsing items

```swift
struct NSDiffableDataSourceSectionSnapshot<Item: Hashable> {
   func expand(_ items: [Item])
   func collapse(_ items: [Item])
   func isExpanded(_ item: Item) -> Bool
}

// Section Snapshot Handlers: handling user interactions for expand / collapse state changes

extension UICollectionViewDiffableDataSource {

  struct SectionSnapshotHandlers<Item> {
    var shouldExpandItem: ((Item) -> Bool)?
    var willExpandItem: ((Item) -> Void)?

    var shouldCollapseItem: ((Item) -> Bool)?
    var willCollapseItem: ((Item) -> Void)?

    var snapshotForExpandingParent: ((Item, NSDiffableDataSourceSectionSnapshot<Item>) -> NSDiffableDataSourceSectionSnapshot<Item>)?
  }

  var sectionSnapshotHandlers: SectionSnapshotHandlers<Item>

}
```

## Reorder

- Automatic snapshot updates
- Transactions

```swift
// Diffable Data Source Reordering Handlers

extension UICollectionViewDiffableDataSource {

  struct ReorderingHandlers {
    var canReorderItem: ((Item) -> Bool)?
    var willReorder: ((NSDiffableDataSourceTransaction<Section, Item>) -> Void)?
    var didReorder: ((NSDiffableDataSourceTransaction<Section, Item>) -> Void)?
  }

  var reorderingHandlers: ReorderingHandlers
}

// NSDiffableDataSourceTransaction

struct NSDiffableDataSourceTransaction<Section, Item> {
   var initialSnapshot: NSDiffableDataSourceSnapshot<Section, Item> { get }
   var finalSnapshot: NSDiffableDataSourceSnapshot<Section, Item> { get }
   var difference: CollectionDifference<Item> { get }
   var sectionTransactions: [NSDiffableDataSourceSectionTransaction<Section, Item>] { get }
}

struct NSDiffableDataSourceSectionTransaction<Section, Item> {
   var sectionIdentifier: Section { get }
   var initialSnapshot: NSDiffableDataSourceSectionSnapshot<Item> { get }
   var finalSnapshot: NSDiffableDataSourceSectionSnapshot<Item> { get }
   var difference: CollectionDifference<Item> { get }
}
```

Example:

```swift
dataSource.reorderingHandlers.didReorder = { [weak self] transaction in
   guard let self = self else { return }

   if let updateBackingStore = self.backingStore.applying(transaction.difference) {
      self.backingStore = updatedBackingStore
   }
}
```

## Cell Configuration

```swift
var content = cell.defaultContentConfiguration()

content.image = UIImage(systemName: "star")
content.text = "Hello WWDC!"

cell.contentConfiguration = content
```

### Background Configuration

- Background color
- Visual effect
- Stroke
- Insets and corner radius
- Custom View

### List Content Configuration

- Image
- Text
- Secondary text
- Layout metrics and behaviors

### Configuration State

![](/images/2021-05-27-UICollectionView-Updates-in-WWDC2020/configurationState.png)

![](/images/2021-05-27-UICollectionView-Updates-in-WWDC2020/viewConfigurationState.png)

![](/images/2021-05-27-UICollectionView-Updates-in-WWDC2020/cellConfigurationState.png)

![](/images/2021-05-27-UICollectionView-Updates-in-WWDC2020/updateConfigurations.png)

```swift
let updatedConfiguration = configuration.updated(for: state)
```

### Automatic Configuration Updates

Enabled by default.

```swift
var automaticallyUpdateContentConfiguration: Bool { get set }
var automaticallyUpdatesBackgroundConfiguration: Bool { get set }
```

Override point to configure cell for new state

```swift
func updateConfiguration(using state: UICellConfigurationState)
```

- Use to update configurations and any other cell properties
- Called before cell first displays, and after any state changes
- Request an update with `setNeedsUpdateConfigurations()`

Example:

```swift
override func updateConfiguration(using state: UICellConfigurationState) {
    var content = self.defaultContentConfiguration().updated(for: state)

    content.image = self.item.icon
    content.text = self.item.title

    if state.isHighlighted || state.isSelected {
        content.imageProperties.tintColor = .white
        content.textProperties.color = .white
    }

    self.contentConfiguration = content
}
```

### Color Transformers

![](/images/2021-05-27-UICollectionView-Updates-in-WWDC2020/colorTransformers.png)

### Default Configurations

- Cells apply a default background configuration automatically
- Get a default content configuration using `defaultContentConfiguration()`
- Request the configuration for any style

```swift
var background = UIBackgroundConfiguration.listSidebarCell()
var content = UIListContentConfiguration.sidebarCell()
```

Set `image reserved layout size` will make sure image icon show properly.

### Adopting Configurations

Background configurations mutually exclusive with existing properties including:

- backgroundColor
- backgroundView

Content configuration replace `UITableViewCell` properties:

- imageView
- textLabel
- detailTextLabel

### Using configurations with custom views

Create a list content view and add it alongside custom views:

```swift
var content = UIListContentConfiguration.cell()

// Set up the content configuration as desired...

let contentView = UIListContentView(configuration: content)
```

- Get default styling from configurations to apply to custom views
- Build a custom content configuration and view

## Cell Registration

```swift
// new iOS 14 cell registration

let reg = UICollectionView.CellRegistration<MyCell, ViewModel> { cell, indexPath, model in
   // configure cell content
}

let dataSource = UICollectionViewDiffableDataSource<S,I>(collectionView: collectionView) {
                     collectionView, indexPath, item -> UICollectionViewCell in
   return collectionView.dequeueConfiguredReusableCell(using: reg, for: indexPath, item: item)
}

// cell content configurations

var contentConfiguration = UIListContentConfiguration.cell()
contentConfiguration.image = UIImage(systemName:"hammer")
contentConfiguration.text = "Ready. Set. Code"
cell.contentConfiguration = contentConfiguration

var contentConfiguration = UIListContentConfiguration.subtitleCell()
contentConfiguration.image = UIImage(systemName:"hammer")
contentConfiguration.text = "Ready. Set. Code."
contentConfiguration.secondaryText = "#WWDC20"
cell.contentConfiguration = contentConfiguration
```

# List In UICollectionView

- UITableView-like appearance
- Based on Compositional Layout
- Highly customizable
- Optimized self sizing

![](/images/2021-05-27-UICollectionView-Updates-in-WWDC2020/components_of_a_list.png)

## List Configuration

```swift
// Simple setup

let configuration = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
let layout = UICollectionViewCompositionalLayout.list(using: configuration)

// Per section setup

let configuration = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
let section = NSCollectionLayoutSection.list(using: configuration, layoutEnvironment: layoutEnvironment)

// Per section setup

let layout = UICollectionViewCompositionalLayout() {
    [weak self] sectionIndex, layoutEnvironment in
    guard let self = self else { return nil }

    // @todo: add custom layout sections for various sections

    let configuration = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
    let section = NSCollectionLayoutSection.list(using: configuration, layoutEnvironment: layoutEnvironment)
    return section
}
```

## List Headers and Footers

```swift
// Headers and footers

var configuration = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
configuration.headerMode = .supplementary
let layout = UICollectionViewCompositionalLayout.list(using: configuration)

dataSource.supplementaryViewProvider = { (collectionView, elementKind, indexPath) in
    if elementKind == UICollectionView.elementKindSectionHeader {
        return collectionView.dequeueConfiguredReusableSupplementary(using: header, for: indexPath)
    }
    else {
        return nil
    }
}

// Optional Header

let layout = UICollectionViewCompositionalLayout() {
    [weak self] sectionIndex, layoutEnvironment in
    guard let self = self else { return nil }

    // check if this section should show a header, e.g. by implementing a shouldShowHeader(for:) method.
    let sectionHasHeader = self.shouldShowHeader(for: sectionIndex)

    let configuration = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
    configuration.headerMode = sectionHasHeader ? .supplementary : .none
    let section = NSCollectionLayoutSection.list(using: configuration, layoutEnvironment: layoutEnvironment)
    return section
}

// Header Mode - first item in section

var configuration = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
configuration.headerMode = .firstItemInSection
let layout = UICollectionViewCompositionalLayout.list(using: configuration)
```

## List Cell

- separators
- indentation
- swipe actions
- accessories
- default content configurations

![](/images/2021-05-27-UICollectionView-Updates-in-WWDC2020/separator.png)

![](/images/2021-05-27-UICollectionView-Updates-in-WWDC2020/separatorLayoutGuide.png)

```swift
// swipe actions

let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, Model> { (cell, indexPath, item) in
    // @todo configure the cell's content

    let markFavorite = UIContextualAction(style: .normal, title: "Mark as Favorite") {
        [weak self] (_, _, completion) in
        guard let self = self else { return }
        // trigger the action with a reference to the model
        // never use itemIndex at here, delete might cause indexPath wrong
        self.markItemAsFavorite(with: item.identifier)
        completion(true)
    }
    cell.leadingSwipeActionsConfiguration = UISwipeActionsConfiguration(actions: [markFavorite])
}

// accessories

let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, String> { (cell, indexPath, item) in
    // @todo configure the cell's content

    cell.accessories = [
        .disclosureIndicator(displayed: .whenNotEditing),
        .delete()
    ]
}
```

#### References

- Advances in UICollectionView: <https://developer.apple.com/wwdc20/10097>
- Advances in diffable data sources: <https://developer.apple.com/wwdc20/10045>
- Modern Cell Configuration: <https://developer.apple.com/wwdc20/10027>
- Lists In UICollectionView: <https://developer.apple.com/wwdc20/10026>
