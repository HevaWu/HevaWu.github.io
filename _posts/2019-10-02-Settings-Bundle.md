---
layout: post
title: Settings Bundle
date: 2019-10-02 18:15:00
comments: true
disqus_category_id: SettingsBundle
categories: [iOS, Settings, Bundle]
tags: [Licenses]
---

## Introduction

As we know, in iOS, Foundation framework provides the low-level mechanism for storing the prefernce data. Apps have 2 options for presenting preferences:

- Display preferences inside the app
- Use a Settings bundle to manage prefences from the Settings App

The Settings bundle is the generally preferred machanism for displaying preferences

Here, I want to try to add Settings Bundle to handle these preferences.

## Settings App Interface

> The Settings app implements a hierarchical set of pages for navigating app preferences. The `main` page of the Settings app lists the system and third-party apps whose preferences can be customized. Selecting a third-party app takes the user to the preferences for that app.

Every app with Settings bundle should have at least 1 page of preferences, which is the `main` page. If you want to show other numbers of prefernces, you could create the child pages. But you should keep the preferences as simple and easy to navigate

First, let's quick look the prefernce control types.

![Merge_sort_algorithm_diagram](/images/2019-10-02-Settings-Bundle/preference_control_types.png)

## Settings Bundle

`Settings.bundle` contains one or more Settings page files that describe the individual pages of preferences. It could also include other support files needed to display the preferences, such as images or localized strings.

Here is the contents of the `Settings.bundle` directory

![Merge_sort_algorithm_diagram](/images/2019-10-02-Settings-Bundle/contents.png)

### Settings Page File Format

Each Settings page files is in iPhone Settings property-list file format. We could simply use the built-in editor facilities of Xcode. And it is also easy to edit the file by using the Property List Editor app. Xcode converts any XML-based property files in the project to binary format when building the app.

The root-level keys of a prefences Settings page file would be:

![Merge_sort_algorithm_diagram](/images/2019-10-02-Settings-Bundle/rootLevelKey.png)

## Create Licenses Settings

Go back to our topic, for adding a `Licenses` column in you app's Settings App:

### Step1: Create the Settings Bundle

If you didn't have this Settings Bundle, please create one. If you already have one, the skip this.

It is easy to create one by:

- File -> New -> New File
- Under iOS, choose Resources, then select the Settings Bundle template
- Name the file `Settings.bundle`

The new file structure would be:

```
Settings.bundle/
    Root.plist
    en.lproj/
        Root.strings
```

### Step2: Add Licenses Property List

If you plan to generate a complicated licenses file, it would be better to put all of the licenses related info in one property list.

- File -> New -> New File
- Under iOS, choose Resources, then select the Property List
- Name the file `Licenses.plist` (you could pick any name here)

As we checked before, you could design your licenses file now. For adding licenses as a single page. It would be better to set it as `PSGroupSpecifier` type.

And for me, I just want to keep it as simple as possible. So I only add a `FooterText` for adding the licenses file.

### Step3: Link Main & Licenses

In the `Root.plist`, we add licenses as a child page which specifying it as `PSChildPaneSpecifier` type. And set its title as `Licenses`(which will be shown as the table view cell title), and set the file as `Licenses`(which will map to our `Licenses.plist` file, reminder: please keep the file name same as each other).

Here is the final version:

**Root.plist**

```xml
<?xml version="1.0" encoding="UTF-8"?>
 <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
 <plist version="1.0">
 <dict>
 	<key>StringsTable</key>
 	<string>Root</string>
 	<key>PreferenceSpecifiers</key>
 	<array>
 		<dict>
 			<key>Type</key>
 			<string>PSChildPaneSpecifier</string>
 			<key>Title</key>
 			<string>Licenses</string>
 			<key>File</key>
 			<string>Licenses</string>
 		</dict>
 	</array>
 </dict>
 </plist>
```

**Licenses.plist**

```xml
<?xml version="1.0" encoding="UTF-8"?>
 <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
 <plist version="1.0">
 <dict>
 	<key>StringsTable</key>
 	<string>Licenses</string>
 	<key>PreferenceSpecifiers</key>
 	<array>
 		<dict>
 			<key>Type</key>
 			<string>PSGroupSpecifier</string>
 			<key>FooterText</key>
 			<string>
             Put your licenses at here.
            </string>
 		</dict>
 	</array>
 </dict>
 </plist>

```

### Step4: Run it!

You will be able to check the result at the Settings App. :tada:

#### Reference

<https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/UserDefaults/Preferences/Preferences.html#//apple_ref/doc/uid/10000059i-CH6-SW5>