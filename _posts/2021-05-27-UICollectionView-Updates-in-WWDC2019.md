---
layout: post
title: UICollectionView Updates in WWDC2019
date: 2021-05-27 17:33:00
comment_id: 157
categories: [WWDC2019, iOS, macOS, TVoS]
tags: [UIKit]
---

# Advances in UIDataSources

![](/images/2021-05-27-UICollectionView-Updates-in-WWDC2019/ui_state.png)

## Snapshots

- Truth of UI state
- Unique identifiers for sections and items
- No more IndexPaths

```swift
// Empty snapshot

let snapshot = NSDiffableDataSourceSnapshot<Section, UUID>()

// Current data source snapshot copy
let snapshot = dataSource.snapshot()

// Snapshot state
var numberOfItems: Int { get }
var numberOfSections: Int { get }
var sectionIdentifiers: [SectionIdentifierType] { get }
var itemIdentifiers: [ItemIdentifierType] { get }

// Configuring snapshots
func insertItems(_ identifiers: [ItemIdentifierType], beforeItem beforeIdentifier: ItemIdentifierType)

func moveItem(_ identifier: ItemIdentifierType, afterItem toIdentifier: ItemIdentifierType)

func appendItems(_ identifiers: [ItemIdentifierType], toSection sectionIdentifier: SectionIDentifierType? = nil)

func appendSections(_ identifiers: [SectionIdentifierType])
```

- Safe to call `apply()` from a background queue

## Diffable Data Source

- UICollectionViewDiffableDataSource
- UITableViewDiffableDataSource
- NSCollectionViewDiffableDataSource

=>

- NSDiffableDataSourceSnapshot

# Advances in Collection View Layout

## Compositional Layout

```swift
// Create a list by specifying 3 core components
// Item, group and section

// size = width + height dimension
let size = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(44.0))

let item = NSCollectionLayoutItem(layoutSize: size)

// three forms: horizontal, vertical, custom
let group = NSCollectionLayoutGroup.horizontal(layoutSize: size, subitems: [item])

let section = NSCollectionLayoutSection(group: group)

let layout = UICollectionViewCompositionalLayout(section: section)
```

![](/images/2021-05-27-UICollectionView-Updates-in-WWDC2019/layout.png)

![](/images/2021-05-27-UICollectionView-Updates-in-WWDC2019/NSCollectionLayoutDimension.png)

![](/images/2021-05-27-UICollectionView-Updates-in-WWDC2019/NSCollectionLayoutDimension_1.png)

![](/images/2021-05-27-UICollectionView-Updates-in-WWDC2019/NSCollectionLayoutDimension_2.png)

## Badge

```swift
let badgeAnchor = NSCollectionLayoutAnchor(edges: [.top, .trailing], fractionalOffset: CGPoint(x: 0.3, y: -0.3))

let badgeSize = NSCollectionLayoutSize(widthDimension: .absolute(20), heightDimension: .absolute(20))

let badge = NSCollectionLayoutSupplementaryItem(layoutSize: badgeSize, elementKind: "badge", containerAnchor: badgeAnchor)

let item = NSCollectionLayoutItem(layoutSize: itemSize, supplementaryItems: [badge])
```

## Boundary Header and Footer

```swift
let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: "header", alignment: .top)

let footer = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: footerSize, elementKind: "footer", alignment: .bottom)

header.pinToVisibleBounds = true
section.boundarySupplementaryItems = [header, footer]

// section background decoration views

let background = NSCollectionLayoutDecorationItem.background(elementKind: "background")
section.decorationItems = [background]

layout.register(xxxView.self, forDecorationViewOfKind: "background")
```

## Estimated Self-Sizing

```swift
let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(44.0))

let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: "header", alighment: .top)

header.pinToVisibleBounds = true
section.boundarySupplementaryItems = [header, footer]
```

## Nested NSCollectionLayoutGroup

```swift
let leadingItem = NSCollectionLayoutItem(layoutSize: leadingItemSize)
let trailingItem = NSCollectionLayoutItem(layoutSize: trailingItemSize)

let trailingGroup = NSCollectionLayoutGroup.vertical(layoutSize: trailingGroupSize, subitem: trailingItem. count: 2)

let containerGroup = NSCollectionLayoutGroup.horizontal(layoutSize: contiainerGroupSize, subitems: [leadingItem, trailingGroup])
```

## Nested CollectionViews

- continuous
- continuous group leading Boundary
- paging
- groupPaging
- groupPagingCenter

#### References

- Advances in UIDataSources: <https://developer.apple.com/wwdc19/220>
- Advances in Collection View Layout: <https://developer.apple.com/wwdc19/215>
