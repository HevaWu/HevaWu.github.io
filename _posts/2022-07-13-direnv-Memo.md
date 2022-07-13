---
layout: post
title: direnv Memo
date: 2022-07-13 15:00:00
comment_id: 225
categories: [Shell]
---

`direnv` is a convenience extension for manage shell. It allow user to load and unload environment variables depending on current directory.

## Mac

I pick homebrew install: `brew install direnv`.
Then add `eval "$(direnv hook zsh)"` to `.zshrc` file.

## Linux

```sh
$ sudo apt-get update
$ sudo apt-get install direnv
```
Then add `eval "$(direnv hook zsh)"` to `.zshrc` file.

## Quick test flow

```sh
$ cd ~/test_project
$ echo ${DUMMY}
$ echo export DUMMY=foo > .envrc
# relaunch terminal
$ echo ${DUMMY}
# it will remind us to trust direnv
$ direnv allow
$ echo ${DUMMY}
# should see foo output now
```

#### References

- <https://direnv.net>
