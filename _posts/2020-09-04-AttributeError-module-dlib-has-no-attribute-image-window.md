---
layout: post
title: "AttributeError: module 'dlib' has no attribute 'image_window'"
date: 2020-09-04 12:14:00
comment_id: 97
categories: [ML]
tags: [dlib]
---

## Problem

After running `pip install dlib` to install the `dlib` library, I found I couldn't run ⬇️

```python
dlib.image_window()
```

The script will throw this error:

```s
AttributeError: module 'dlib' has no attribute 'image_window'
```

## Solution

After several researching, I tried to solve it by:

- uninstall the `dlib`: If you are using pip to install it, you could directly run `pip uninstall dlib`

- Clone `dlib` git repo to local: `git clone https://github.com/davisking/dlib`

- Run `dlib` `setup.py`: `python setup.py install`

- Try to check setup log, if it shows any `GUI` error, fix the error first. I'm having ⬇️ error, then I tried to download the `XQuartz`.

```s
 *****************************************************************************
 *** DLIB GUI SUPPORT DISABLED BECAUSE X11 DEVELOPMENT LIBRARIES NOT FOUND ***
 *** Make sure XQuartz is installed if you want GUI support.               ***
 *** You can download XQuartz from: https://www.xquartz.org/               ***
 *****************************************************************************
```

- uninstall the `dlib` from pip: `pip uninstall dlib`

- install the `dlib` again: `pip install dlib`

- Run dlib python test file: `python python_examples/face_detector.py examples/faces/2007_007763.jpg`

- If it shows the `RuntimeError`, it means we need to `turn on XQuartz` when running the script, `XQuartz` is just like an app, open it will be okay ~

```s
RuntimeError: Failed to initialize X11 resources
```

All of error should disappear now. 🎉

#### Reference

- <https://github.com/davisking/dlib>
