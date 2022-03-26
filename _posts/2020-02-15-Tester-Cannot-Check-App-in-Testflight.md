---
layout: post
title: Internal Tester Cannot Check App in TestFlight
date: 2020-02-15 11:57:00
comment_id: 50
categories: [TestFlight]
---

Last Monday, we prepare to upload our app to Testflight and ask our QA to help testing it. Then we receive a report that they cannot see the new version of our app in their Testflight.

After researching, we found there are lots of people met the same problem, and [here](https://forums.developer.apple.com/thread/128878) is where they report.

## Solution

- Update the `Info.plist` by <https://developer.apple.com/documentation/security/complying_with_encryption_export_regulations>
	- By setting the `ITSAppUsesNonExemptEncryption` key, it works!!! 🎉
- Rebuild

Still no idea why this happens, maybe Apple change some export compliance automation related things ...

#### Reference

<https://forums.developer.apple.com/thread/128878>