---
layout: post
title: Main Async VS Sync
date: 2019-11-06 12:12:00
comment_id: 31
categories: [Swift, iOS]
tags: [DispatchQueue]
---

Actually, most of time, we might think when we should use `async` and when we should use `sync`. So, this is just a sum up for it.

## Sync & Async

> Synchronous and asynchronous transmissions are two different methods of transmission synchronization. Synchronous transmissions are synchronized by an external clock, while asynchronous transmissions are synchronized by special signals along the transmission medium.

while for programming,

- Sync: run the task synchronously (ex: the thread which can be main/global/any other thread will wait for the task to complete)
- Async: run some task asynchronously (ex: the thread which can be main/global/any other thread will directly push the task to a queue and continue executing next step outside the block. `It won't wait`)

## DispatchQueue.main

Take an example for **DispatchQueue.main**:

```swift
// A: This will cause crash
DispatchQueue.main.async {
    let url = URL(string: imageUrl)
    do {
        let data = try Data(contentsOf: url!)
        DispatchQueue.main.sync {
            self.imageIcon.image = UIImage(data: data)
        }
    }
}

// B: This will not
DispatchQueue.global.async {
    let url = URL(string: imageUrl)
    do {
        let data = try Data(contentsOf: url!)
        DispatchQueue.main.sync {
            self.imageIcon.image = UIImage(data: data)
        }
    }
}
```

At here, `Queue` is not same as `Thread`. The first one(A) crashed is because it using `main.sync` to update the UI which bring the completed task to MainQueue `but` it was already on MainQueue because we didn't switch the Queue, and this `create DeadLock`(MainQueue waiting for itself), causes app crash.

- **DispatchQueue.main.async** means performing the task in `main queue` with using of `background thread`(w/o blocking of UI), when task finished, it will automatic updated to UI because its already in Main Queue.
- **DispatchQueue.global.async** means performing task in `global queue` with using of `background thread` and when task finish, **global.sync** use bring the work `from globalQueue to mainQueue` which update to UI.

## Conclusion

In general, we use `async` other than `sync`, unless `sync` is necessary. Because `sync` will wait until this block has finished executing. We must be careful when we use `sync` on main thread otherwise it will block the UI updates.

#### Reference

<http://et.engr.iupui.edu//~skoskie/ECE362/lecture_notes/LNB25_html/text12.html>

<https://stackoverflow.com/questions/46732016/main-async-vs-main-sync-vs-global-async-in-swift3-gcd>