---
layout: post
title: Difference between SSH keys & Deploy keys
date: 2019-04-03 16:30:00
comments: true
disqus_category_id: DifferenceInSSHKeys&DeployKeys
categories: [Github]
tags: [Github]
---

We always have many repository in Github.
When we start to build track our git remote repo, we need to set our ssh keys.
-> Add `id_rsa.pub` to our account `SSH Keys`
*NOTE: DO NOT add it into the `Deploy Keys`. Otherwise it might cause the other repository cannot add `Deploy Keys`.*

### Difference between SSH Keys & Deploy Keys:
- `SSH Keys` is the account's highest level key, so, if you have the account authority, you will be able to access all of its repository
- `Repository`'s `Deploy Keys` is the repository's private key
- More easily understanding is:
  - `SSH Keys` is a big apartment key(with this key you could oepn each room in this apartment)
  - `Deploy Keys` is the room key(with this key you could only open this room)

One more thing, `id_rsa.pub` is the public key, and you could add it to the server side. And local `id_rsa` is the correspond private key, they are `pair`.