---
layout: post
title: Introduction of Universal Links
date: 2020-01-22 15:54:00
comment_id: 35
categories: [iOS, macOS, WWDC2019]
tags: [Universal Link]
---

## Overview

> Univeral Links are URLs that represent your content both on the Web and in your app.

Single URL will represnt your content whether user installed the app OR even not downloaded it yet.

It was introduced in iOS 9, tvOS 10 and macOS 10.15. So it is available in iOS, tvOS, and macOS apps.

It is securely associated between the app and the website. Xcode entitlement indicates which domains it can represent and your web server adopts a single JSON file reprsent what parts in the domain are representable in the app. Which help confirming user will redirect to the app correctly.

*Recommanded over custom URL schemes. Custom URL are inherently insecure and can be abused by malicious developers.*

## Configure Web Server

### Install a valid HTTPS certificate

HTTP is not secure and cannot be used to validate an association between the app and the website. Custom root certificate are not supported.

### Add apple-app-site-association file

Json file. When app is installed on an Apple device, operating system downloads this file to determine what services the server will let the app use. The system also periodically downloads updates for this file.

Universal links are one of many services that may be included in this file. And this file should be located at ⬇️. Other path are deprecated.

```
https://your domain name/.well-known/apple-app-site-association
```

For now, it never been necessary step to support universal links.

**DO NOT SIGN `apple-app-site-association` file!**

Also, support for sign JSON files and JSON files at other paths will be removed in a future release.

The `apple-app-site-association` file would be like this ⬇️

![apple-app-site-association-file](/images/2020-01-22-Introduction-of-Universal-Links/apple-app-site-association-file.png)

For universal links, the key would be `applinks`, but other services are also available. We will focus on Universal Links for now.

- `apps`: if targeting iOS 13, tvOS 13 and macOS 10.15, it is no need the `apps` key, but if continuing to provide support for iOS12, tvOS12 or earlier, it is NEEDED to add this key. For universal links, it should always be an empty array.
- `details`: contains array of dictionaries, each of which represent specific apps universal links configuration.
    - `appID`: app identifier, alphanumeric, 10 character prefix provided by Apple, a period and the bundle identifier. Prefix may or maynot be equal to the team identifier.
        - If you have multiple apps with the same universal links configuration, you may not want to repeat the relevant JSON.
            - If you are targeting 2019's releases, you can reduce the size of this file by using the plural `appIDs` key.
            ```json
            {
                "appIDs": ["ABCDE12345.com.example.app", "ABCDE12345.com.example.app2"],
                "paths": ["/path/*/filename"]
            }
            ```
            - If you need to support previous releases, you should keep using the singular `appID` key for each app.
            ```json
            {
                "appID": "ABCDE12345.com.example.app",
                "paths": ["/path/*/filename"]
            }
            ```
    - `paths`: contains an array of path patterns. Pattern matching is performed the same way in terminal. `*` is used to indicate multiple wildcard characters, `?` matches just one character.
        - **Start from 2019, Apple replacing `paths` with `components`.**
        - `components`: an array of dictionaries. each or which contains zero or more URL components to pattern match against.
        ```json
        {
            "appID": "ABCDE12345.com.example.app",
            "components": [
                {
                    "/": "/path/*/filename",
                    "#": "*fragment",
                    "?": "widget=?*"
                }
            ]
        }
        ```
            - If you need to support previous releases, you can keep `paths`.
            - iOS 13, tvOS 13, and macOS 10.15 will ignore `paths` if `components` is present.
            - query items: you could specify a dictionary as its value and pattern match individual query items.
            ```json
            "?": { "widget": "?*", "grommet": "please" }
            ```
            - For a components dictionary to match a candidate URL, all the components must match. If don't specify a component, the opereating system's default behavior is to simply ignore that component.
            - `exclude`: set it to `true` to exclude subscections which the website are not able to be represented in the app yet. Same as the `not` keywoard in `path`.
            ```json
            "exclude": true
            ```

![example](/images/2020-01-22-Introduction-of-Universal-Links/example.png)

### Internationalization

URLs and pattern-matching are ASCII. A Unicode character may be represented by more than one ASCII character, keep in mind when using `?` in the patterns.

For providing country-specific patterns for every country supported, if the pattern-matching is consistent between countries, you could simplify the JSON. ex:

```json
{ "en", "fr", "mx", ... } -> "??"
{ "en_US", "fr_CA", "de_CH", ... } -> "??_??"
```

If encounter a URL with an invalid country code or locale specific identifier, just treat it like the user's current locale. Start from 2019 release, the operating system will prioritize `apple-app-site-association` downloads based on where a user is most likely to browse. Apple will download them all when an app is installed but at different priorities.

iOS and macOS prioritize downloads from:
.com, .net, .org, and the user's ccTLD(s)(country code TLDs)

## Configure App

Open `Xcode`, and navigate to `Project Settings`. Add the `Associated Domains` capability.

![associated_domain](/images/2020-01-22-Introduction-of-Universal-Links/associated_domain.png)

For universal links, the service type is applinks like it was in your `apple-app-site-association` file. The order of values in this array is ignored by the system.

Here is an example for the `Associated Domains Entitlement`.

![associated_domains_entitlement](/images/2020-01-22-Introduction-of-Universal-Links/associated_domains_entitlement.png)

- When the app is installed, the operating system will visite www.example.com looking for the `apple-app-site-association` file. If it's present and it contains information for these apps, app identifier, then the association is confirmed.
- It's also possible to indicate wildcard support for subdomains of a given domain. In this case, the operating system will visit example.com. No www at this time.
- Exact domains have higher priority during universal links look up than wildcard domains. In this case, when system opens a URL at www.example.com, it will try to match patterns from that domain before the ones it got from the parent domain. Patterns from parent domain will only be matched if no match was found at the fully qualified subdomain.
- Internationalized domain names need to be encoded using Punycode([RFC 3492](https://tools.ietf.org/rfc/rfc3492.txt)), since URLs are always ASCII.

App is declares support for certain domains now, and you could add the handling by app delegate.

![app_delegate](/images/2020-01-22-Introduction-of-Universal-Links/app_delegate.png)

- `activityType`: help distinguish universal links from other incoming user activities that the app may support. Add the checking is recommended since app might handle other types in the future.
- `webpageURL`: it will never be `nil` for a universal link.
- `URLComponents`: parse URLs
- host component: if support universal links from multiple domains, need to check it

### Differences on macOS

Universal links open in the browser by default in macOS. When it is open, Safari will give the option to open them in the app. If user select the option, the links will continue to open in the app after ward.

Unlike iOS, macOS supports launching apps present on remove volumes. Apps on remote volumes cannot use universal links. App must be on a local volume.

If user downloads the app from the App Store, system will begin downloading `apple-app-site-association` files as soon as the app is installed or updated. App Store distribution recommended.

Developer ID-signed apps must be launched first. If the app is develop ID-signed, system will not begin downloads until user has launched app at least once. Since universal link is backd by a secure association with an app identifier, only one copy of a given app will be able to handle universal links on Mac. Typically, this will be the copy of he app present in slash applications.

### Note

When you need to test changes to associated domains entitlement, if you are on the other end of an operation and want to open a universal link, `UIApplication` and `NSWorkspace` and `launch services` will all automatically open them when available.

If you want to require opening a universal link in app rather than the default browser, you can use `UIApplication` or `NSWorkspace API`. If ⬇️failed, it means universal link was not available for the supplied URL.

```swift
// UIApplication
UIApplication.share.open(url, options: [.universalLinksOnly: true]) {
    ...
}

// NSWorkspace
let configuration = NSWorkspace.OpenConfiguration()
configuration.requiresUniversalLinks = true
NSWorkspace.shared.open(url, configuration: configuration) {
    ...
}
```

## Tips

- Fail gracefully: It is possible URLs that represent outdated, invalid, or nonexistent content. If you determine that universal link can't be opened by the app, you can often open it in Safari View Controller. OR open the URL in Safari. OR, at minimum, prompting with details about the issue. **Avoid sending user a blank screen**.
- Use Smart App Banner to provide a link either to the App Store or to the content. Smart App Banner integrates seamlessly with Safari and looks great. And there's no JavaScript or custom URL schemes required to support it.

#### Reference

<https://developer.apple.com/videos/play/wwdc2019/717/>