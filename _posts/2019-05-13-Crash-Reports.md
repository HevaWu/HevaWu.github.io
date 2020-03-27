---
layout: post
title: Crash Reports
date: 2019-05-13 16:04:00
comments: true
disqus_category_id: DesignPatternPARTICreationalPatterns
categories: [iOS, Xcode]
tags: [Crash Reports, Debug]
---

As an app developer, not only deploy the product, we also need to be able to analyze the crash log. And find a way to fix the crashes.

When an application crashed, a `crash report` is created and stored on the device. This article is simple introduce the crash reports contents and the analytic method.

# Symbolicating Crash Reports

Crash reports with backtraces need to be `symbolicated` before being anlyzed. Symbolication replacec memory addresses with human-readable function names and line numbers.

## Symbolicating Process

1. Compiler translates the source code, it also generates debug symbols (which map each machine instruction in the comipled binary back to the line of source code from which it originated) -- Depending on the `Debug Information Format` build settings. These debug symbols are stored inside the binary or in a companion Debug Symbol(`dSYM`) file. By default, debug builds of an application store the debug symbols inside the compiled binary while release builds of an application store the debug symbols in a companion dSYM file to reduce the binary size. The Debug Symbol file and application binary are tied together on a per-build-basis by the build UUID. A new UUID is generated for each build of your application and uniquely identifies that build. Even if a functionally-identical executable is rebuilt from the same source code, with the same compiler settings, it will have a different build UUID. Debug Symbol files from subsequent builds, even from the same source files, will not interoperate with binaries from other builds.
2. During archive, Xcode will gather the application binary along with the .dSYM file and store them at a location inside your home folder. You can find all of your archived applications in the Xcode Organizer under the "Archived" section.
    - NOTE: To symbolicate crash reports from testers, app review, and customers, you must retain th archive for each build of the application that you distribute.
3. Distributing: if you are distributing your app via the App Store, or conducting a beta test using Test Flight, you will be given the option of including the `dSYM` file when uploading your archive to iTunes Connect. In the submission dialog, check “Include app symbols for your application…”. Uploading your `dSYM` file is necessary to receive crash reports collected from TestFlight users and customers who have opted to share diagnostic data.
4. When your application crashes, an unsymbolicated crash report is created and stored on the device.
5. Users can retrieve crash reports directly from their device by following the steps in Debugging Deployed iOS Apps. If you have distributed your application via AdHoc or Enterprise distribution, this is the only way to acquire crash reports from your users.
6. Crash reports retrieved from a device are unsymbolicated and will need to be symbolicated using Xcode. Xcode uses the dSYM file associated with your application binary to replace each address in the backtrace with its originating location in your source code. The result is a symbolicated crash report.
7. If the user has opted to share diagnostic data with Apple, or if the user has installed a beta version of your application through TestFlight, the crash report is uploaded to the App Store.
8. The App Store symbolicates the crash report and groups it with similar crash reports. This aggregate of similar crash reports is called a Crash Point.
9. The symbolicated crash reports are made available to you in Xcode's Crashes organizer.

## Getting dSYM files

### Downloading the dSYM files from Xcode

1. In the Archives organizer, select the archive that you originally submitted to the App Store.
2. Click the Download dSYMs button.

### Downloading the dSYM files from the iTunes Connect website

1. Open the App Details page.
2. Click Activity.
3. From the list of All Builds, select a version.
4. Click the Download dSYM link.

### Translating symbol names back to original names

When you upload your app with bitcode to the App Store, you may choose not to
send your application's symbols by unchecking the "Upload your app's symbols to
receive symbolicated reports from Apple" box in the submission dialog.
If you choose not to send your app's symbol information to Apple, Xcode will
replace the symbols in your app's .dSYM files with obfuscated symbols such as
"__hidden#109_" before sending your app to iTunes Connect. Xcode creates a
mapping between the original symbols and the "hidden" symbols and stores this
mapping in a .bcsymbolmap file inside the application archive. Each .dSYM file
will have a corresponding .bcsymbolmap file.

Before symbolicating crash reports, you will need to de-obfuscate the symbols in
the `.dSYM` files downloaded from iTunes Connect.
If you use the Download dSYMs button in Xcode, this de-obfuscation will be
performed automatically for you.
However, if you use the iTunes Connect website to download the `.dSYM` files, open Terminal and use the following command to de-obfuscate your symbols
(replacing the example paths with your own archive and the dSYMs folder downloaded from iTunes Connect):

```shell
xcrun dsymutil -symbol-map ~/Library/Developer/Xcode/Archives/2017-11-23/MyGreatApp\ 11-23-17\,\ 12.00\ PM.xcarchive/BCSymbolMaps ~/Downloads/dSYMs/3B15C133-88AA-35B0-B8BA-84AF76826CE0.dSYM
```

## Symbolicating iOS Crash Reports with Xcode

Xcode will automatically attempt to symbolicate all crash reports.
All you need to do for symbolication is to add the crash report to the Xcode Organizer.

- Note: Xcode will not accept crash reports without a `.crash` extension. If you have received a crash report without an extension, or with a `.txt` extension, rename it to have a `.crash` extension before following the steps listed below.

Follow the steps:

1. Connect an iOS device to your Mac
2. Choose "Devices" from the "Window" menu
3. Under the "DEVICES" section in the left column, choose a device
4. Click the "View Device Logs" button under the "Device Information" section on the right hand panel
5. Drag your crash report onto the left column of the presented panel
6. Xcode will automatically symbolicate the crash report and display the results

## Symbolicating Crash Reports With atos

`atos` command can be used to symbolicate individual addresses in the backtrace
of an unsymbolicatd, or partially symbolicatd, crash report.

Steps:

1. Find a line in the backtrace which you want to symbolicate. Note the name of the binary image in the second column, and the address in the third column.
2. Look for a binary image with that name in the list of binary images at the bottom of the crash report. Note the architecture and load address of the binary image.

```shell
atos -arch <Binary Architecture> -o <Path to dSYM file>/Contents/Resources/DWARF/<binary image name> -l <load address> <address to symbolicate>
```

## Symbolication Troubleshooting

If Xcode is failing to fully symbolicate a crash report, it's likely because your
Mac is missing the dSYM file for the application binary, the dSYM files for one
or more frameworks the application links against, or the device symbols for the
OS the application was running on when it crashed.

Steps:

1. Find a line in the backtrace which Xcode failed to symbolicate. Note the name of the binary image in the second column.
2. Look for a binary image with that name in the list of binary images at the bottom of the crash report. This list contains the UUIDs for each of the binary images that were loaded into the process at the time of the crash.

```shell
$ grep --after-context=1000 "Binary Images:" <Path to Crash Report> | grep <Binary Name>
```

3. Convert the UUID of the binary image to a 32 character string seperated in groups of 8-4-4-4-12 (XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX). Note that all letters must be uppercased.
4. Search for the UUID using the mdfind command line tool using the query "com_apple_xcode_dsym_uuids == <UUID>" (include the quotation marks).

```shell
$ mdfind "com_apple_xcode_dsym_uuids == <UUID>"
```

5. If Spotlight finds a dSYM file for the UUID, mdfind will print the path to the dSYM file and possibly its containing archive. If a dSYM file for the UUID was not found, mdfind will exit without printing anything.

If you think that you have the correct dSYM for the binary image, you can use the dwarfdump command to print the matching UUIDs. You can also use the dwarfdump command to print the UUIDs of a binary.

```shell
xcrun dwarfdump --uuid <Path to dSYM file>
```

# Analyzing Crash Reports

## Getting Crash Logs

[Debugging Deployed iOS Apps](https://developer.apple.com/library/archive/qa/qa1747/_index.html)

### Getting Crash Logs Directly From a Device Without Xcode

(It is not possible to get device console logs directly from a device)

1. Open Settings app
2. Go to Privacy, then Diagnostics & Usage
3. Select Diagnostics & Usage Data
4. Locate the log for the crashed app. The logs will be named in the format: <AppName>_<DateTime>_<DeviceName>
5. Select the desired log. Then, using the text selection UI select the entire text of the log. Once the text is selected, tap Copy
6. Paste the copied text to Mail and send to an email address as desired

### Getting Crash Logs and Console Output From a Device Using Xcode

(Even though you won't be able to run the app in Xcode's debugger, Xcode can still give you all the information you need to debug the problem.)

1. Plug in the device and open Xcode
2. Choose Window -> Devices from the menu bar
3. Under the DEVICES section in the left column, choose the device
4. To see the device console, click the up-triangle at the bottom left of the right hand panel
5. Click the down arrow on the bottom right to save the console as a file
6. To see crash logs, select the View Device Logs button under the Device Information section on the right hand panel
7. Find your app in the Process column and select the Crash log to see the contents.
8. To save a crash log, right click the entry on the left column and choose "Export Log"
9. Xcode 6 will also list low memory logs here. These will be shown with a Process name "Unknown" and Type "Unknown". You should examine the contents of these logs to determine whether any of these are caused by your app. For more information about low memory logs, see Understanding and Analyzing iOS Application Crash Reports.

#### Reference

[Technical Note TN2151: Understanding and Analyzing Application Crash Reports](https://developer.apple.com/library/archive/technotes/tn2151/_index.html)