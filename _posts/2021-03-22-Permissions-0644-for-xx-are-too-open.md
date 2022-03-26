---
layout: post
title: Permissions 0644 for xx are too open
date: 2021-03-22 16:42:00
comment_id: 145
categories: [Mac, Github]
tags: [SSH]
---

When I try to pull one repository, it shows me this warning:

```s
WARNING: UNPROTECTED PRIVATE KEY FILE!
Permissions 0644 for 'file path/file' are too open.
It is required that your private key files are NOT accessible by others. 
This private key will be ignored. Once
Load key "file": bad permissions
```

## Solutions

Update file authority by:

```s
$ chmod 600 file
```
