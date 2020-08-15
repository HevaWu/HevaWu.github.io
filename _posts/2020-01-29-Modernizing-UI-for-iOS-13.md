---
layout: post
title: Modernizing UI for iOS 13
date: 2020-01-29 13:50:00
comment_id: 37
categories: [UI, iOS, WWDC2019]
tags: [iOS13, NavigationBar]
---

It has already passed half of year after WWDC2019, and I just have time to write a memo for it. 😰 For the next time, I might watch some interested ASAP. ><

After releasing iOS13, there are lots of changes. And Apple has a session called [Modernizing Your UI for iOS 13](https://developer.apple.com/videos/play/wwdc2019/224/) which talked about it in WWDC 2019.

This will be the memo for that session.

## Required by April 2020

Apple noticed that we might need to support some feature which might required in April 2020. And here is the list:

- Adopt Launch Storyboards, Not Only Launch Images
- Support Any Size
- Support Split Screen Multitasking <- iPad requirement

## New Bar Appearance

Start from iOS13, Apple provide a new navigation bar appearance API for customizing the navigation bar part. Here is an example for showing how to implement it:

![nav_appearance](/images/2020-01-29-Modernizing-UI-for-iOS-13/nav_appearance.png)

By simply using `UINavigationBarAppearance()`, we could apply `foregroundColor` to the title label for iOS 13 devices.

- `UINavigationBar.standardAppearance`
    - The navigation bar, when its size without a large title is in the standard size. If you don't specify any other appearance configuration, this one will be the defaults for the other two.
- `UINavigationBar.compactAppearance`
    - If use a smaller iPhone in Landscape, it will be used in compactAppearance.
- `UINavigationBar.scrollEdgeAppearance`
    - Navigation bar dropped its background to transparent when user pull down a the top of a scroll view. When navigation bar is associated with a scroll view.
- `UINavigationBar.buttonAppearance`
    - customize bar button item
- `UINavigationBar.doneButtonAppearance`
    - customize bar button item

It is also okay to customize the tool bar(`UIToolbarAppearance`) and tab bar(`UITabBarAppearance`).

![tabbar_appearance](/images/2020-01-29-Modernizing-UI-for-iOS-13/tabbar_appearance.png)

## New Present Style -- `Sheets`

![sheets](/images/2020-01-29-Modernizing-UI-for-iOS-13/sheets.png#simulator)
![ipad_sheets](/images/2020-01-29-Modernizing-UI-for-iOS-13/ipad_sheets.png#simulator)

`Sheets` is just a new design for existing `pageSheet` and `formSheet`.

### How to use it

For using this feature, `UIModalPresentationStyle` default value change to `automatic`. No code required if you want to use it.

If we want to force show the view controller as full screen, we could change the code as:

```swift
VC.modalPresentationStyle = .fullScreen
```

### Pull to Dismiss

For supporting pull to dismiss, in general, Sheet have already done it, and we don't need to do any change.

But, sometimes, when user might edit some thing in the presented page, we will not sure what user want to do when they pull down. So we should provide some options when user pull down the presented one. For implementing it, there are 2 API:

- `isModalInPresentation`: a property on UIViewController, set it to `true` on the presented View Controller will put the Sheet in a modal state where it cannot be dismissed. Prevent the interactive dismissal of the view controlle while it is onscreen.
- `presentationControllerDidAttemptToDismiss`: UIAdaptivePresentationControllerDelegate method. Inside this part, it could present action sheet. Only called when `.isModalInPresentation = true` and user pull to intent to dimiss.

![pull_to_dismiss_actionsheet](/images/2020-01-29-Modernizing-UI-for-iOS-13/pull_to_dismiss_actionsheet.png)
![presentation_delegate](/images/2020-01-29-Modernizing-UI-for-iOS-13/presentation_delegate.png)

### Appearance Callbacks

- Full Screen
![appearance_callbacks](/images/2020-01-29-Modernizing-UI-for-iOS-13/appearance_callbacks.png)

- Page and form sheet
![appearance_callbacks_sheet](/images/2020-01-29-Modernizing-UI-for-iOS-13/appearance_callbacks_sheet.png)

Apple inserted some private views in the view hirarchy between UIWindow & this window's rootViewController.view. But this have no influence on the app.

## Search

- Apple allow the hide the elements of Search Bar if it is managed by UISearchController, ex: Scope Bar or Cancel Button.
- The `SearchTextField` will be pulic property on UISearchBar, which means it will be easily to customize.

### Customize SearchController

For not show the cancel button or scope bar automatically:

- set `automaticallyShowsCancelButton` to `false`
- set `automaticallyShowsScopeBar` to `false`

For customize the search text field:

- directly update `searchBar.textField` property

![customize_searchviewcontroller](/images/2020-01-29-Modernizing-UI-for-iOS-13/customize_searchviewcontroller.png)

### Search Result Controller

![search_result_controller](/images/2020-01-29-Modernizing-UI-for-iOS-13/search_result_controller.png)

Not every application behave this. In iOS13, it will be availbe for editing it.

![show_search_results_controller](/images/2020-01-29-Modernizing-UI-for-iOS-13/show_search_results_controller.png)

### Search Tokens

For each suggested search result, it will be a token, which is available for the UISearchTextField instance via the new UISearchTokenAPI. These tokens support Copy & Paste, Drag & Drop.

For creating tokens:

![create_token](/images/2020-01-29-Modernizing-UI-for-iOS-13/create_token.png)

## Gestures

### Selection Gestures in custom text view

For default UITextView, the gestures is already applied on it. For Custom text view, if we want to add gesture on it, we need to manually add all of system text selection gestures. For iOS13, Apple provide a new type UIInteraction: `UITextInteraction`.

![uitextinteraction](/images/2020-01-29-Modernizing-UI-for-iOS-13/uitextinteraction.png)

### Multiple selection gestures in tables and collections

For iOS13, user could do the multiple selection by: placing two fingers down anywhere on a table or collection view and pan across to start selecting right away.

For adopting it:

```swift
/// return true to allow multiple selection, could use indexPath for checking if this indexPath is able to be treat as begin point
optional func tableView(_ tableView: UITableView, shouldBeginMultipleSelectionInteractionAtIndexPath indexPath: IndexPath) -> Bool

optional func tableView(_ tableView: UITableView, didBeginMultipleSelectionInteractionAtIndexPath indexPath: IndexPath)
```

### Editing Gestures

Apple add a standard set of Gestures to do some common editing tasks easier:

- three fingers: swipe back to undo, then swipe other way to redo
- pinch three fingers in will copy, pinch them out will paste

For application which already used `UndoManager`, this feature already exist. But it might have conflicts with other three finger gesture things. In case of this, it is able to be disable this feature by:

```swift
public protocal UIResponder {
    public var editingInteractionConfiguration: UIEditingInteractionConfiguration
}

public enum UIEditingInteractionConfiguration {
    case `defualt`  // System behavior, default
    case non        // Disable
}
```

## Menu

In iOS13, Apple allows user to present fluid interactive menus with rich previews in the apps. ex: if user long-type a photo, it will show the editing action sheet, without leave their finger, if user move their finger, they will be able to achieve drag & drop.

### UIContextMenuInteraction

`UIContextMenuInteraction` is a UIInteraction that allow user present menus with rich previews and complex hierarchies. These hierarchies can have nested sub-menus and in-line sections.

### UIMenu and UIAction

If we set the structure as ⬇️

```
UIMenu
-----------------------------
UIAction("Share")
 ---------------------------
| UIMenu("Edit")            |
|  -----------------------  |
| | UIAction("Copy")      | |
| | UIAction("Duplicate") | |
 ---------------------------
UIAction("Delete")
```

When we present it, it will be like ⬇️

![uimenu](/images/2020-01-29-Modernizing-UI-for-iOS-13/uimenu.png#simulator)
![uimenu_edit](/images/2020-01-29-Modernizing-UI-for-iOS-13/uimenu_edit.png#simulator)

For adopting it:

```swift
// Create an interaction
let interaction = UIContextMenuInteraction(delegate: self)
menuSourceView.addInteraction(interaction)

// Confrim to the interaction's delegate protocol

/// Called when the interaction about to begin
/// - Return a UIContextMenuConfiguration to start
/// - Return nil to prevent interaction
func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration?

/// Create action provider
let actionProvider = (suggestedActions: [UIMenuElement]) -> UIMenu? {
    let editMenu = UIMenu(title: "Edit...", children: [
        UIAction(title: "Copy") {...},
        UIAction(title: "Duplicate") {...}
    ])

    return UIMenu(children: [
        UIAction(title: "Share") {...},
        editMenu,
        UIAction(title: "Delete", style: .destructive) {...}
    ])
}
return UIContextMenuConfiguration(identifier: "unique-ID" as NSCopying, previewProvider: nil, actionProvider: actionProvider)
```

It is also able to customize the interaction by using `UITargetPreview`.

Since `UIContextMenuInteraction` sounds like Peek and Pod in some ways, so Apple deprecated the `UIViewControllerPreviewing` and replace it by `UIContextMenuInteraction`.

#### Reference

<https://developer.apple.com/videos/play/wwdc2019/224/>