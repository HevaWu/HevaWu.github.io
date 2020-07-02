---
layout: post
title: Debug UIViewAlertForUnsatisfiableConstraints
date: 2019-05-27 16:04:00
comments: true
disqus_category_id: iOSLoggingSystemOSLog
categories: [iOS]
tags: [Layout]
---

When we update our app's UI, sometimes we might got this layout warning like this:

![layout_warning](/images/2019-05-27-Debug-UIViewAlertForUnsatisfiableConstraints/layout_warning.png)

Uhhhhh, What should we do now?

So, follow the instruction
> Make a symbolic breakpoint at UIViewAlertForUnsatisfiableConstraints
to catch this in the debugger`

OK. Got it. Let's set a `Symbolic` breakpoint by setting its `Symbol` to `UIViewAlertForUnsatisfiableConstraints`.

![add_symbolic](/images/2019-05-27-Debug-UIViewAlertForUnsatisfiableConstraints/add_symbolic.png)

DONE. :tada:

Now, go into this warning view again. The breakpoint will automatically
interruput you to this :arrow_down:

![symbolic_breakpoint](/images/2019-05-27-Debug-UIViewAlertForUnsatisfiableConstraints/symbolic_breakpoint.png)

What to do now with pointers and assembly codes?

After searching, I found some solutions to debug this breakpoint.
If you see the :arrow_up: images, you can find strings like
**%rbp, %rsp, %r15, %r14** etc...
These properties hold the address of view-s & constraint-s.
We could print them in XCode console to see more details.

EX: try to print `po $rbx`, which contains all the views & constraints
which are involved in this issue. It also contains the memory address
of the view.

If you want to change the appearance of some views.
You could try below commands:

```objective-c
ex [(UIView *)0x7fb2dceb4e80 setBackgroundColor: [UIColor greenColor]]
```

Now, `Continue program execution`, you will see the related view's
background color has been changed.

Sometimes, the view with changed colors might be burried under other
views, so it wont be immediately visible on the screen.
In such case, use the `Debug View Hierachy` to dig deeper ~~~~

Hope it would be helpful to someone. :relaxed:
