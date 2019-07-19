---
layout: post
pagination:
  enabled: true
  categories: Test
  tags: Test
title: Dispatch Group
date: 2019-02-19 19:19:00
comments: true
disqus_category_id: DispatchGroup
categories: [iOS, Dispatch]
tags: [iOS, Dispatch, Dispatch Group]
---

## Introduction

`Dispatch Group` is a part of GCD. As you can read from [Apple Documents](https://developer.apple.com/documentation/dispatch/dispatchgroup). :arrow_down:

```
DispatchGroup allows for aggregate synchronization of work. You can use them to submit
 multiple different work items and track when they all complete, even though they might
 run on different queues. This behavior can be helpful when progress can’t be made until
 all of the specified tasks are complete.
```

You might still be confusing, :confused: . So, let's check the example code.

## First Method: Directly add `DispatchGroup` where we needed it

Here is the code:

```swift
let dispatchQueue = DispatchQueue(label: "dispatch queue")
let dispatchGroup = DispatchGroup()

func dispatchGroup_useEnter() {
    DispatchQueue.main.async { [dispatchQueue, dispatchGroup]
        for i in 0..<3 {
            dispatchGroup.wait()
            dispatchGroup.enter()
            dispatchQueue.async {
                print("start \(i) task")
                sleep(UInt32(3 - i))
                print("end \(i) task")
                dispatchGroup.leave()
            }
        }
        //
        let result = dispatchGroup.wait(timeout: DispatchTime.distantFuture)
        if result == .success {
            print("All Done")
        } else {
            print("Run out of time")
        }
    }
}
```

Based on the code, you could find, we just simplify running this procedure in the `Main thread`. And trying to use it to use `DispatchQueue` to synchronize running 3 tasks.

At here, we use `DispatchGroup` to make sure each task is started after the former one is finished.
- 1.run `wait()` to wait former thread is finished(current resource is empty)
- 2.run `enter()` to start the group
- 3.Do the async code, and add `leave()` when the async is finished.

At the end of code, we add `result` to help confirming if all of the tasks is done.

Here is the print out:
```
start 0 task
end 0 task
start 1 task
end 1 task
start 2 task
end 2 task
All Done
```

## Second Method: Generate `DispatchGroup` when init `async DispatchQueue`

This method is kind of similar with the former one. The difference is where we put/init the `DispatchGroup`. Here is the code:

```swift
func dispatchGroup_useAsyncGroup() {
    DispatchQueue.main.async { [dispatchQueue, dispatchGroup]
        for i in 0..<3 {
            dispatchQueue.async(group: dispatchGroup, execute: {
                print("start \(i) task")
                sleep(UInt32(3 - i))
                print("end \(i) task")
            })
        }
        //
        let result = dispatchGroup.wait(timeout: DispatchTime.distantFuture)
        if result == .success {
            print("All Done")
        } else {
            print("Run out of time")
        }
    }
}
```

As you can see, we init the group by using `dispatchQueue.async(group: dispatchGroup, execute: {...}`. This function is automatically do the `enter()` & `leave()` things for us. We don't need to manually call `enter()` & `leave()`. It will automatically call it at the start & end part of the `DispatchQueue`.

The result is as same as the former one:
```
start 0 task
end 0 task
start 1 task
end 1 task
start 2 task
end 2 task
All Done
```

Two methods. You could pick what you want according to the requests. Enjoy! :fireworks: