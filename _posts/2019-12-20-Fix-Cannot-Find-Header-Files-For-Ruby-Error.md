---
layout: post
title: Fix Cannot Find Header Files For Ruby Error
date: 2019-12-20 12:20:00
comments: true
disqus_category_id: FixCannotFindHeaderFilesForRubyError
categories: [Xcode, MacOS14, Ruby]
tags: [HeaderFiles]
---

## Error Description

Recently when I try to update our project `Gemfile.lock`, I got an `gem install json` errror:

![installJson](/images/2019-12-20-Fix-Cannot-Find-Header-Files-For-Ruby-Error/installJson.png)

Then by following the instruction of the error, I try to run:

```shell
sudo gem install json -v '2.3.0' --source 'https://rubygems.org/'
```

Then it appears another error 🤯

![rubyHeader](/images/2019-12-20-Fix-Cannot-Find-Header-Files-For-Ruby-Error/rubyHeader.png)

So, by reading the error description, it looks like there is some problems on my ruby settings. But when I checked, I found it is a `MacOS 10.14` specific error. 🙁

It looks like some development files got moved, or stopped getting installed by some reason ...

## Solution

By searching how to fix it, somebody suggested to:

```shell
xcode-select --install
sudo xcodebuild -license
```

Although I run it, it looks like the CommandLine tools of Xcode still not get installed correctly.

Then I tried

```shell
open /Library/Developer/CommandLineTools/Packages/
```

It shows I don't have this folder.

**Restart the computer !!! 😡**

Then, try to get into the folder again! This time successeed!!! 🤠

![macOSHeader](/images/2019-12-20-Fix-Cannot-Find-Header-Files-For-Ruby-Error/macOSHeader.png)

Follow the installation, after it is finished. Test the previous `gem install json` command again:

```shell
sudo gem install json -v '2.3.0' --source 'https://rubygems.org/'
```

TADA! Success!! 🥳

#### Reference
https://github.com/castwide/vscode-solargraph/issues/78