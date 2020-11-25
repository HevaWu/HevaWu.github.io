---
layout: post
title: What's New in Universal Links
date: 2020-11-25 11:03:00
comment_id: 112
categories: [WWDC2020, iOS, watchOS]
tags: [Universal Link, CDN, Alternate Mode]
---

# Universal links

- URLs that represent content both on the Web and the app
- Universal links open in the app instead of the default browser
- Secure association between app and website

# News

## Support for watchOS

- Same functionality as iOS, tvOS and macOS
- API different between UIKit and WatchKit
- Add Associated Domains entitlement to WatchKit extension

```swift
/* UIKit */
// Handling universal links
// UIApplicationDelegate
func application(_ applicaation: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping([UIUserActivityRestoring]?) -> Void) -> Bool
// UISceneDelegate
func scene(_ scene: UIScene, continue userActivity: NSUserActivity) -> Void

// open universal links in other application
let url = ...
UIApplication.shared.open(url, options: [:]) { success in ... }

/* WatchKit */
// handling universal links
// WKExtensionDelegate
func handle(_ userActivity: NSUserActivity) -> Void

// open universal links in other application
let url = ...
WKExtension.shared().openSystemURL(url)
```

## Support for SwiftUI

```swift
// handling universal links
.onOpenURL { url in ... }

// open universal links in other applications
let url = ...
openURL(url)
```

## Enhance pattern matching

- `*`: matches *zero or more* characters greedily
- `?`: matches *any one* character
- `?*`: matches *at least one* character

**News:**

- case-insensitive patterns: available from macOS Catalina 10.15.5 and iOS 13.5

```json
// set caseSensitive to false to disable case sensitive matching
"components": [{"/": "/sourdough/?*", "caseSensitive": false}]"
```

- unicode patterns: available from macOS Big Sur and iOS 14

```json
// add percentEncoded to allow input Chinese characters
"components": [{"/": "/哈哈/?*", "percentEncoded": false}]
```

**Example**:

```swift
"defaults": { "percentEncoded": false, "caseSensitive": false },
"details": [
	{
		"appIds": [...],
		"components": [
			{"/": "/哈哈/?*"},
			{"/": "/SoUrDoUgH/?*"}
		]
	}
]
```

**Note: pattern matching has exponential complexity!**

## Substitution variables

- Named lists of possible substrings to match against
- Names can contain any character except `$`, `(` or `)`
- Names are always case-sensitive in patterns
- Values can contain `?` and `*` (but not other substitution variables)
- Values are case-sensitive by default

Available from macOS Catalina 10.15.5 and iOS 13.5

**Predefined substitution variables**

| Variable name | Example values |
| :--- | :--- |
| `$(alpha)` | ["A", "a", "B", "b", ... , "Z", "z"] |
| `$(upper)`, `$(lower)` | ["A", "B", ... , "Z"], ["a", "b", ... , "z"] |
| `$(alnum)` | ["A", "a", "B", "b", ... , "Z", "z", "0", ... , "9"] |
| `$(digit)`, `$(xdigit)` | ["0", ... , "9"], ["0", ... , "9", "A", "a", ... , "F", "f"] |
| `$(region)` | Locale.isoRegionCodes = ["CA", "UK", "US", ... ] |
| `$(lang)` | Locale.isoLanguageCodes = ["ar", "en", "zh", ...] |

**Examples:**

```json
{
	"applinks": {
		"substitutionVariables": {
			"food": ["burrito", "sushi"],
			"Canadian food": ["poutine"]
		},
		"details": [{
			"appIDs": ["ABCDE12345.com.example.restaurant"],
			"components": [
				{"/": "/$(lang)_CA/$(Canadian food)/"},
				{"/": "/$(lang)_CA/$(food)/", "exclude": true},
				{"/": "/$(lang)_$(region)/$(food)/"},
			]
		}]
	}
}
```

# Apple CDN

Normal way:

1. download app & install app
2. system check its entitlements and check if it needs data from one or more apple-app-site-association files
3. device open web server where file is hosted in order to download it(If multiple files need to be downloaded from multiple web servers, device needs to download them a few at a time)
4. apple-app-site-association file make its way from web server to the device, is parsed by the Associated Domains daemon, and the app's universal links become active

If device wifi cut off or server crashes or server is unreachable when download the apple-app-site-association file.
==> This makes device in an inconsistent state, where the app is installed but its universal links and other Associated Domains data are not available.

This state can persist for hours or days, until the system next attempts to update the data for the app.

Now:

For step 3, instead of connecting to the associated web server, it `connects to a content delivery network, or CDN`, that manages Associated Domains data.

CDN can cache large amounts of data, which might already have the data from this web server stored. If it not, it can connect to the server on behalf of this device. CDN `can connect to all the servers for all apps on this device simultaneously`.

## Benefits of using a CDN

- Apple-operated Content Delivery Network dedicated to Associated Domains and apple-app-site-association files
- Single HTTP/2 connection for all associated domains on a device
- Reduce load on app's server
- Routes devices to a known-good, known-fast connection

## Alternate modes for internal domains

`Apple's CDN lives on the public Internet`. If app's web server cannot be reached from the public Internet, ex: pre-deployment testing or one intended only for use by employees connected to the internal network, Apple provided alternate modes for it.

Alternate modes allow developer to bypass the CDN and directly connect to the domain developers' control.

Two modes:

- `developer` mode: building and testing the app before deploy it to TestFlight or end users
- `manage` mode: use when app is installed using MDM profile

Using `developer` mode, we can use any valid SSL certificate on the web server, even it is not trusted by the operating system's built-in certificate store.

![](/images/2020-11-25-What's-New-in-Universal-Links/alternate_mode.png)

For enabling developer mode:

- iOS, watchOS, tvOS: Settings -> Developer Settings -> enable "Associated Domains Development"
- macOS: open Terminal -> input `swcutil developer-mode -e true`

Developer mode only takes effect for apps that are signed with a `development profile`. Apps signed for distribution on the App Store or TestFlight or mac apps that have been signed and notarized cannot be used with this alternate mode.

![](/images/2020-11-25-What's-New-in-Universal-Links/entitlement.png)

#### Reference

- <https://developer.apple.com/videos/play/wwdc2020/10098/>
