---
layout: post
title: Rail Fence Cipher
date: 2020-04-08 10:45:00
comment_id: 78
categories: [Cipher]
---

## Overview

`Rail Fence Cipher` also called `Zigzag Cipher` is kind of transposition cipher.

## How To Cipher

> In the rail fence cipher, the plain text is written downwards and diagonally on successive "rails" of an imaginary fence, then moving up when the bottom rail is reached. When the top rail is reached, the message is written downwards again until the whole plaintext is written out. The message is then read off in rows.

Example:

```s
W . . . E . . . C . . . R . . . L . . . T . . . E
. E . R . D . S . O . E . E . F . E . A . O . C .
. . A . . . I . . . V . . . D . . . E . . . N . .
```

This is a `3 rails` and message is `WE ARE DISCOVERED. FLEE AT ONCE`.

The reads off ciphertext is:

```s
WECRLTEERDSOEEFEAOCAIVDEN
```

**Note:** But this example `Not use the space seperating`. Decipherer will need to add it based on the text.

## How To Dicypher

Example: 3 rails cipher text is

```s
IA_EZS_ELYLK_UZERLIPL
```

For solving the cipher, we need to know the `height` & `cycle` of this cipher first. For this example, we already know `3` fence rails were used, so the height is 3. About puzzle width, we need to determine the `cycle` of letters.

> A `cycle` of letters runs from the top row, down through each subsequent row, and then up again, but stopping before reaching the top row again. (The next letter on the top row will actually begin the next cycle.)

So, 2 rail puzzle has a cycle of 2 letters, 3 rails puzzle has a cycle of 4 letters.

```s
cycle = (num of rails * 2) - 2
```

Our 3-rail fence example has a "cycle" of 4 units. So `divide the total units (letters + spaces) by the cycle number and round down to the next whole number`. There are 21 units in the example, so our "base puzzle width" is 5 (21 / 4 = 5.25, which rounds down to 5).

```s
I . . . A . . . _ . . . E . . . Z . . . S
. _ . E . L . Y . L . K . _ . U . Z . E .
. . R . . . L . . . I . . . P . . . L . .
```

Then we could just follow the down-up-down-up pattern to find the original message:

```s
 I_REALLY_LIKE_PUZZLES!
```

#### Reference

<https://en.wikipedia.org/wiki/Rail_fence_cipher>