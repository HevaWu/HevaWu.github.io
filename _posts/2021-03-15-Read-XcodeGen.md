---
layout: post
title: Read XcodeGen
date: 2021-03-15 16:14:00
comment_id: 143
categories: [Swift, Xcode]
tags: [YAML]
---

Memo some XcodeGen settings we might common use:

# Project

- **name**: **String** - Name of the generated project
- **include**: **Include** - One or more paths to other specs
- **options**: [**Options**](https://github.com/yonaskolb/XcodeGen/blob/master/Docs/ProjectSpec.md#options) - Various options to override default behavior
- **attributes**: **[String: Any]** - The PBXProject attributes. This is for advanced use. This defaults to {"LastUpgradeCheck": "XcodeVersion"} with xcodeVersion being set by Options.xcodeVersion
- **configs**: **Configs** - Project build configurations. Defaults to Debug and Release configs
- **configFiles**: **Config Files** - .xcconfig files per config
- **settings**: **Settings** - Project specific settings. Default base and config type settings will be applied first before any settings defined here
- **settingGroups**: **Setting Groups** - Setting groups mapped by name
- **targets**: **[String: Target]** - The list of targets in the project mapped by name
- **fileGroups**: **[String]** - A list of paths to add to the root of the project. These aren't files that will be included in your targets, but that you'd like to include in the project hierarchy anyway. For example a folder of xcconfig files that aren't already added by any target sources, or a Readme file.
- **schemes**: **Scheme** - A list of schemes by name. This allows more control over what is found in Target Scheme
- **schemeTemplates**: **[String: Scheme Template]** - a list of schemes that can be used as templates for actual schemes which reference them via a template property. They can be used to extract common scheme settings. Works great in combination with include.
- **targetTemplates**: **[String: Target Template]** - a list of targets that can be used as templates for actual targets which reference them via a template property. They can be used to extract common target settings. Works great in combination with include.
- **packages**: **[String: Swift Package]** - a map of Swift packages by name.
- **projectReferences**: **[String: Project Reference]** - a map of project references by name

## Include

> Include can either be a list of includes or a single include.

```sh
include:
  # provide via string
  - includedFile.yml
  # provide via object: (path, relativePaths)
  - path: path/to/includedFile.yml 
    relativePaths: false
```

## Configs

> Each config maps to a build type of either debug or release which will then apply default build settings to the project. Any value other than debug or release (for example none), will mean no default build settings will be applied to the project.

```sh
configs:
  Debug: debug
  Beta: release
  AppStore: release
```

## Config Files

Specify `.xcconfig` files for each configuration.

```sh
configFiles:
  Debug: debug.xcconfig
  Release: release.xcconfig
targets:
  App:
    configFiles:
      Debug: App/debug.xcconfig
      Release: App/release.xcconfig
```

# Settings

Settings are merged in the following order: groups, base, configs. Xcode Build Settings Doc is here: <https://help.apple.com/xcode/mac/11.4/#/itcaec37c2a6>

- single map of build settings **[String: String]**
- advanced:
  - **groups**: **[String]** - List of setting groups to include and merge
  - **configs**: **[String:Settings]** - Mapping of config name to a settings spec. These settings will only be applied for that config. Each key will be matched to any configs that contain the key and is case insensitive. So if you had Staging Debug and Staging Release, you could apply settings to both of them using staging. However if a config name is an exact match to a config it won't be applied to any others. eg Release will be applied to config Release but not Staging Release
  - **base**: **[String:String]** - Used to specify default settings that apply to any config

# Target

- **type**: **Product Type** - Product type of the target
- **platform**: **Platform** - Platform of the target
- **deploymentTarget**: **String** - The deployment target (eg 9.2). If this is not specified the value from the project set in Options.deploymentTarget.PLATFORM will be used.
- **sources**: **Sources** - Source directories of the target
- **configFiles**: **Config Files** - .xcconfig files per config
- **settings**: **Settings** - Target specific build settings. Default platform and product type settings will be applied first before any custom settings defined here. Other context dependant settings will be set automatically as well:
  - INFOPLIST_FILE: If it doesn't exist your sources will be searched for Info.plist files and the first one found will be used for this setting
  - FRAMEWORK_SEARCH_PATHS: If carthage dependencies are used, the platform build path will be added to this setting
  - OTHER_LDFLAGS: See requiresObjCLinking below
  - TEST_TARGET_NAME: for ui tests that target an application
  - TEST_HOST: for unit tests that target an application
- **dependencies**: **[Dependency]** - Dependencies for the target
- **info**: **Plist** - If defined, this will generate and write an Info.plist to the specified path and use it by setting the INFOPLIST_FILE build setting for every configuration, unless INFOPLIST_FILE is already defined in settings for this configuration. The following properties are generated automatically if appropriate, the rest will have to be provided.
  - CFBundleIdentifier
  - CFBundleInfoDictionaryVersion
  - CFBundleExecutable Not generated for targets of type bundle
  - CFBundleName
  - CFBundleDevelopmentRegion
  - CFBundleShortVersionString
  - CFBundleVersion
  - CFBundlePackageType
- **entitlements**: **Plist** - If defined this will generate and write a .entitlements file, and use it by setting CODE_SIGN_ENTITLEMENTS build setting for every configuration. All properties must be provided
- **templates**: **[String]** - A list of Target Templates referenced by name that will be merged with the target in order. Any instances of ${target_name} within these templates will be replaced with the target name.
- **templateAttributes**: **[String: String]** - A list of attributes where each instance of ${attributeName} within the templates listed in templates will be replaced with the value specified.
- **transitivelyLinkDependencies**: **Bool** - If this is not specified the value from the project set in Options.transitivelyLinkDependencies will be used.
- **directlyEmbedCarthageDependencies**: **Bool** - If this is true Carthage dependencies will be embedded using an Embed Frameworks build phase instead of the copy-frameworks script. Defaults to true for all targets except iOS/tvOS/watchOS Applications.
- **requiresObjCLinking**: **Bool** - If this is true any targets that link to this target will have -ObjC added to their OTHER_LDFLAGS. This is required if a static library has any catagories or extensions on Objective-C code. See this guide for more details. Defaults to true if type is library.static. If you are 100% sure you don't have catagories or extensions on Objective-C code (pure Swift with no use of Foundation/UIKit) you can set this to false, otherwise it's best to leave it alone.
- **onlyCopyFilesOnInstall**: **Bool** – If this is true, the Embed Frameworks and Embed App Extensions (if available) build phases will have the "Copy only when installing" chekbox checked. Defaults to false.
- **preBuildScripts**: **[Build Script]** - Build scripts that run before any other build phases
- **postCompileScripts**: **[Build Script]** - Build scripts that run after the Compile Sources phase
- **postBuildScripts**: **[Build Script]** - Build scripts that run after any other build phases
- **buildRules**: **[Build Rule]** - Custom build rules
- **scheme**: **Target Scheme** - Generated scheme with tests or config variants
- **legacy**: **Legacy Target** - When present, opt-in to make an Xcode "External Build System" legacy target instead.
- **attributes**: **[String: Any]** - This sets values in the project TargetAttributes. It is merged with attributes from the project and anything automatically added by XcodeGen, with any duplicate values being override by values specified here. This is for advanced use only. Properties that are already set include:
  - DevelopmentTeam: if all configurations have the same DEVELOPMENT_TEAM setting
  - ProvisioningStyle: if all configurations have the same CODE_SIGN_STYLE setting
  - TestTargetID: if all configurations have the same TEST_TARGET_NAME setting

## Product Type

- application
- application.on-demand-install-capable
- application.messages
- application.watchapp
- application.watchapp2
- app-extension
- app-extension.intents-service
- app-extension.messages
- app-extension.messages-sticker-pack
- bundle
- bundle.ocunit-test
- bundle.ui-testing
- bundle.unit-test
- framework
- instruments-package
- library.dynamic
- library.static
- framework.static
- tool
- tv-app-extension
- watchapp2-container
- watchkit-extension
- watchkit2-extension
- xcode-extension
- xpc-service
- "" (used for legacy targets)

# Scheme

- **build**: Build options
- **run**: The run action
- **test**: The test action
- **profile**: The profile action
- **analyze**: The analyze action
- **archive**: The archive action

# Swift Package

```sh
packages:
  # remote package
  Yams:
    url: https://github.com/jpsim/Yams
    from: 2.0.0
  Yams:
    github: JohnSundell/Ink
    from: 0.5.0
  # local package
  RxClient:
    path: ../RxClient
```

## Remote Package

- **url**: **URL** - the url to the package
- **version**: **String** - the version of the package to use. It can take a few forms:
  - majorVersion: 1.2.0 or from: 1.2.0
  - minorVersion: 1.2.1
  - exactVersion: 1.2.1 or version: 1.2.1
  - minVersion: 1.0.0, maxVersion: 1.2.9
  - branch: master
  - revision: xxxxxx
- **github** : **String**- this is an optional helper you can use for github repos. Instead of specifying the full url in url you can just specify the github org and repo

## Local Package

- **path**: **String** - the path to the package in local. The path must be directory with a Package.swift.

#### References

- <https://github.com/yonaskolb/XcodeGen/blob/master/Docs/ProjectSpec.md>
- <https://github.com/yonaskolb/XcodeGen/blob/master/Docs/Usage.md>
