---
layout: post
title: Be Careful Using `Named Color` at Xcode Xib File
date: 2019-07-03 15:30:00
comments: true
disqus_category_id: BeCarefulUsingNamedColorAtXcodeXibFile
categories: [iOS, Xcode, XIB, Named Color]
tags: [iOS, Xcode, XIB, Named Color]
---

At WWDC 2019, Apple introduced the nice dark mode color settings.
By adding the dark mode color settings, Apple suggest to define `Named Color` at `Assets.xsassets`.
However, during implementation, there is an issue, and we should pay attetion on it.

I will first introduce how to add & use the `Named Color`,
then introduce the problems.

At first, I have a `TabBarController` based project.
I could switch my view controllers (FirstViewController, SecondViewController) by using the tab bar.

## Add New Color Set
- Open `Assets.xcassets`
- Click `+` and choosing `New Color Set`, then you could naming it(I add a `TabBarItemLabelColor`)

<img src="/images/2019-07-03-Be-Careful-Using-Named-Color-at-Xcode-Xib-File/color_set.png" width="100%">
- Under `Attributes Inspector`, set the `Color` params

## Use New Color Set
- At `xib` file, we could directly select the color under `Attributes Inspector`

<img src="/images/2019-07-03-Be-Careful-Using-Named-Color-at-Xcode-Xib-File/xib.png" width="100%">
- At coding part, we could directly call `UIColor(named: "TabBarItemLabelColor")` to use it

## Problems (Be Careful :bomb: )
OK. Now back to our main point.

### If you are using `Named Color` at the `xib` file, please be carefule to change it at the coding part
Since we add a new color set at the `Assets.xcassets`,
so of course we could directly call it at the `xib` file.

**But** If you will `rewrite` this variable in the later coding part.
Then you should be careful.

At the first, I thought we could rewrite the color at the code part where we want.
(Same as before). However, I found my color is not updated (showing correctly)
at the first time. :disappointed:

Then I try to find the reason.

For what I am testing is :
- Add an `label color` observer at the `viewDidLoad` part (where I prepare to rewrite the color). I tried to use this observer to help checking how the color changes.
```swift
override func viewDidLoad() {
    super.viewDidLoad()

    firstLabel.textColor = .red
    print(firstLabel.textColor)

    // observer for checking if the color is changed
    observer = firstLabel.observe(\.textColor) { (label, change) in
       print(label.textColor, #line)
    }
}
```

And I got this output
```swift
    Optional(UIExtendedSRGBColorSpace 1 0 0 1)
    Optional(kCGColorSpaceModelRGB 0 0 0 0.5 ) 38
```

The first line is `print` line, so we **do** rewrite the color
The second line shows the label's color changed later.

I have no idea when the label's color changed.
But I tried to put the `label.color = .red` rewrite color code at
`variabe's didSet{}` & `viewDidLayoutSubview()` & `viewWillAppear()` part.
All of them cannot rewrite the color succesfully.
Except `viewDidAppear()`
You could checking them in this file
https://github.com/HevaWu/TestColorAssets/blob/master/TestColorAssets/TestColorAssets/FirstViewController.swift

I don't know the detail implementation about the `Named Color`

For what I am thinking is:
Maybe reading the `color` from `Assets.xsassets` takes some time & calculation.

At the `xib` file part, if we checking its code

<img src="/images/2019-07-03-Be-Careful-Using-Named-Color-at-Xcode-Xib-File/text_color.png" width="100%">

So Xcode read the color by its `name`
And in the `resources` part

<img src="/images/2019-07-03-Be-Careful-Using-Named-Color-at-Xcode-Xib-File/resources.png" width="100%">
Xcode will try to find the `named Color` by reading its resources

This `finding` might take some times.

Because if we set the `dark mode` colors, Xcode will first reading the device
environment, then try to update/fit the colors.
But during this time `viewDidLoad()` has already finished.

So even we rewrite the label's color in it,
it still be replaced by `xib` file `Named Color`

## Conclusion
- If you are not using `Named Color` at the `xib` file part <- everything goes well
- If you are using `Named Color` at the `xib` file
    - You will not change this color in the code part <- everythin goes well
    - You will/might change this color later (be carefule)
        - You shouldn't change the color at `didSet{}`, `viewDidLoad()`, `viewDidLayoutSubviews()`, `viewWillAppear()`
        - You could change the color at `viewDidAppear()` (If you find other places we could rewrite it, please tell me :+1: )

## At the end
Thank you for the reading. Please feel free to tell me if I wrote anything wrong. :relaxed:

#### Link
https://github.com/HevaWu/TestColorAssets
