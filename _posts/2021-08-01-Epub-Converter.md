---
layout: post
title: Epub Converter
date: 2021-08-01 21:55:00
comment_id: 181
categories: [Tool]
---

Normally, I would prefer to read PDF format books, which I can use some note tools to take some memo. Sometimes, when you buy a book, it might be `epub` format. ex: if you are watching from O'REILLY. After doing some search, I notice that we can use [`Calibre`](https://manual.calibre-ebook.com/generated/en/ebook-convert.html) to help converting epub to pdf easily.

Step:

```sh
$ brew install calibre
$ ebook-convert "input file name" "output file name" --[optional options]
```

DONE!

It is easy, right?

You can also download Calibre app from <https://calibre-ebook.com>. It also support downloading and converting functions.

### Example

I plan to download some O'REILLY ebooks, which I find a nice git repo which can download its epub quite clean: <https://github.com/lorenzodifuccia/safaribooks#usage>

Here is how I did it:

```s
$ python safaribooks.py --cred "Email:Pass" "bookID"

# make sure epub is cleaner format
$ ebook-convert ./Books/input_book.epub ./Books/output_book.epub

# convert epub to pdf
$ ebook-convert ./Books/output_book.epub ./Books/output_book.pdf
```

Open it in my iPad, DONE! 🎉

#### Reference

- <https://github.com/lorenzodifuccia/safaribooks#usage>
- <https://manual.calibre-ebook.com/generated/en/ebook-convert.html>
