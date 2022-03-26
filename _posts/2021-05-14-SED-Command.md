---
layout: post
title: SED Command
date: 2021-05-14 14:54:00
comment_id: 154
categories: [Linux, Unix]
---

`sed` is the shorten from `Stream Editor`, and it can process some function like search, find, replace, insert and delete. By using `sed`, we can edit files without opening it.

[Here](https://www.gnu.org/software/sed/manual/html_node/Command_002dLine-Options.html) is a list of GNU `sed` command line options. I'd like to just memo some common command at here.

## Search & Find & Replace

```s
# Replace word "a" with "b"
$sed 's/a/b/' test.txt

# Replace 2 occurrence of word "a" with "b"
$sed 's/a/b/2' test.txt

# Parenthesize first character of each word
$ echo "Welcome To The Geek Stuff" | sed 's/\(\b[A-Z]\)/\(\1\)/g'
# (W)elcome (T)o (T)he (G)eek (S)tuff

# Replace string on a range of lines (ex: 1-3 lines)
$sed '1,3 s/a/b/' test.txt
```

## Insert

```s
# add line "hello word" after 3rd line
$sed '3 a/hello word/' test.txt

# insert line before 4th line
$sed '4 i/hello word/' test.txt
```

## Delete

```s
# Delete particular line (ex: 5 line)
$ sed '5d' test.txt

# Delete last line
$ sed '$d' test.txt

# Delete 3-6 lines
$ sed '3,6d' test.txt

# Delete from 10th to last line
$ sed '12,$d' test.txt

# Delete pattern matching line
$ sed '/pattern/d' test.txt
```

#### Reference

- <https://www.geeksforgeeks.org/sed-command-in-linux-unix-with-examples/>
- <https://www.gnu.org/software/sed/manual/html_node/Command_002dLine-Options.html>
