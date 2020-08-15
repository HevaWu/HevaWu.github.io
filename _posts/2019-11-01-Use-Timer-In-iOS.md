---
layout: post
title: Use Timer In iOS
date: 2019-11-01 16:24:00
comment_id: 30
categories: [iOS, Swift]
tags: [Timer]
---

## Timer Types

Timer allows to repeat tasks in time interval. There are multiple types for timer: (referenced from: <https://medium.com/@danielemargutti/the-secret-world-of-nstimer-708f508c9eb)>

- **[Real-time clock or RTC](https://en.wikipedia.org/wiki/Real-time_clock)** : The computer clock that keeps track of the current time, user can change this clock and the NTP(Network Time Protocol) keep it in sync with an external reference. Its value increases by one second per real second but sometimes it may run faster/slower or jump forward when it attempts to sync with the external source.
- **Monotonic Timer** Its a counter incremented by a physical signal sent to the CPU using a ntimer interrupt. On Apple platforms this value is returned by the Mach kernel via mach_abosolute_time(). Returned value is `dependent by the CPU` so you can't just multiply it by a constant to get a real world value. rather, you should call a system-provided conversion function to convert it to a real world value(CoreAnimation has a convenient method for that: CACurrentMediaTime()). The fact it gets reset on boot make it not so interesting to get how much time has elapsed in real world, however its the most precise way to measure difference between 2 intervals.
- **Boot Timer** Just a special *Monotonic Timer* which does not pause when the system goes to sleep. the most common way to get its value is to call the `uptime` function from terminal.

On Apple platform, we might need to use `NSTimer`, the timer that fires after a certain time interval. And this timer is just a wrapper around a monotonic timer. Thus, using NSTimer may end with an unpredictably behaviour, especially on iOS, where the opportunistic use of resources may ends in some edge cases as described above.

## Principle

> Timers work in conjunction with run loops. Run loops maintain strong references to their timers, so you don’t have to maintain your own strong reference to a timer after you have added it to a run loop.

## Repeating & Nonrepeating Timers

It is able to specify whether a timer is repeating or nonrepeating at creation time.

- Nonrepeating timer fires `once` and then invalidates itself automatically, thereby preventin the timer from firing again.
- Repeating timer fires and then reschedules itself on the same run loop. The repeating timer always schedules itself based on the scheduled firing time, as opposed to the actual firing time.

## Tolerance

> In iOS 7 and later and macOS 10.9 and later, you can specify a tolerance for a timer (tolerance). This flexibility in when a timer fires improves the system's ability to optimize for increased power savings and responsiveness.

By setting the tolerance, the timer might fire at anytime(between its scheduled fire date & the scheduled fire date + the tolerance).

For repeating timers, the next fire date is caculated from the original fire date `regardless` of tolerance applied at individual fire times, to avoid drift.

The default value is `0`, which means no additional tolerance is applied.

Even you set the tolerence, Apple said ⬇️

> The system reserves the right to apply a small amount of tolerance to certain timers regardless of the value of the tolerance property.

The general rule would be :

> set the tolerance to at least 10% of the interval, for a repeating timer

Even a small amount of tolerance has significant positive impact on the power usage of your application. The system may enforce a maximum value for the tolerance.

## Schedule Timers in Run Loops

It is possible to register a timer in only 1 run loop at a time, although it can be added to multiple run loop modes within that run loop.

There are 3 ways to create a timer:

- Use `scheduledTimerWithTimeInterval:invocation:repeats:` or `scheduledTimerWithTimeInterval:target:selector:userInfo:repeats:` class method to create the timer and schedule it on the current run loop in the default mode.
- Use the `timerWithTimeInterval:invocation:repeats:` or `timerWithTimeInterval:target:selector:userInfo:repeats:` class method to create the timer object without scheduling it on a run loop. (After creating it, you must add the timer to a run loop manually by calling the `addTimer:forMode:` method of the corresponding NSRunLoop object.)
- Allocate the timer and initialize it using the `initWithFireDate:interval:target:selector:userInfo:repeats:` method. (After creating it, you must add the timer to a run loop manually by calling the `addTimer:forMode:` method of the corresponding NSRunLoop object.)

After scheduled on a run loop, the timer fires at the specified interval unitl it is invalidated.

- A nonrepeating timer invalidates itself immediately after it fires.
- A repeating timer, we `must` invalidate the timer object by ourselves by calling its `invalidate` method. Calling this method requests the removal of the timer from the current run loop. **Note: This means we should always call the `invalidate` method from the same thread on which the timer was installed.**

Invalidating the timer immediately disables it so that it no longer affects the run loop. The run loop then removes the timer(and also the `strong reference` it had to the timer), either just before the `invalidate` method returns OR at some later point. Once invalidated, timer objects cannot be reused.

## Take Care

- To use a timer effectively, it is needed to be aware of run loops.
- If timer's firing time occurs during ⬇️, the timer doesn't fire until the next time the run loop checks the timer. <- The actual time at which a timer fires can be significantly later.
    - a long run loop callout
    - the run loop is in a mode that isn't monitoring the timer
- Do not subclass `NSTimer`

## Try to Create a new Timer

The target for our timer would be:

- simple to manage
- avoid strong reference
- use callback to inform the fire events
- able to pause, start, resume, reset the timer

## Create a new Timer in background thread

Sometimes, we might only want the timer run in the background thread instead of main thread.

So, let's create a `BackgroundTimer` first.

```swift
final class BackgroundTimer {
    private var timer: Timer?

    private var block: (Timer) -> Void
    private let duration: TimeInterval

    private let backgroundQueue = DispatchQueue(label: "backgroundQueue", attributes: .concurrent)

    init(duration: TimeInterval, block: @escaping (Timer) -> Void) {
        self.duration = duration
        self.block = block
    }

    func schedule() {
        backgroundQueue.async { [weak self] in
            guard let self = self else {
                NSLog("[BackgroundTimer] self is nil ... ")
                return
            }
            NSLog("[BackgroundTimer] Will be scheduled ... ")
            Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: self.block)
            NSLog("[BackgroundTimer] Start scheduled ... ")
        }
    }
}
```

And we directly call it in the ViewController.swift:

```swift
class ViewController: UIViewController {
    var backgroundTimer: BackgroundTimer?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        backgroundTimer = BackgroundTimer(duration: 3.0, block: backgroundTimerFiredBlock(timer:))
        backgroundTimer?.schedule()
    }

    func backgroundTimerFiredBlock(timer: Timer) -> Void {
        NSLog("[BackgroundTimer] Timer Fired")
    }
 }
```

Run it! 😠

The print out is:

```swift
2019-11-01 18:15:57.565317+0900 TestNSTimer[48346:18222107] [BackgroundTimer] Will be scheduled ...
2019-11-01 18:15:57.565702+0900 TestNSTimer[48346:18222107] [BackgroundTimer] Start scheduled ...
```

So, the `[BackgroundTimer] Timer Fired` fired is never running !!! So actually the timers is not called correctly. For fixing this, as we mentioned before, each thread will has one run loop, and we should run the timer in the run loop of this thread.

Change the `BackgroundTimer.schedule()` part as:

```swift
        backgroundQueue.async { [weak self] in
            guard let self = self else {
                NSLog("[BackgroundTimer] self is nil ... ")
                return
            }
            NSLog("[BackgroundTimer] Will be scheduled ... ")
            let runLoop = RunLoop.current
            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: self.block)

            runLoop.add(timer, forMode: .default)
            runLoop.run()
            NSLog("[BackgroundTimer] Start scheduled ... ")
        }
```

Run it again! 😠

```swift
2019-11-01 18:18:39.978333+0900 TestNSTimer[48490:18225098] [BackgroundTimer] Will be scheduled ...
2019-11-01 18:18:40.979713+0900 TestNSTimer[48490:18225098] [BackgroundTimer] Timer Fired
2019-11-01 18:18:41.980628+0900 TestNSTimer[48490:18225098] [BackgroundTimer] Timer Fired
2019-11-01 18:18:42.979163+0900 TestNSTimer[48490:18225098] [BackgroundTimer] Timer Fired
```

This time it works well !!! 🎉

## Create a new Timer by uinsg GCD Timer

There is another way to implement this things which would be using `GCD Timer`. Grand Central Dispatch provide a easy way to create a timer: `DispatchSourceTimer`.

Let's create a `GCDTimer` first:

```swift
final class GCDTimer {
    private lazy var timer: DispatchSourceTimer? = {
        let timer = DispatchSource.makeTimerSource(queue: gcdQueue)
        timer.schedule(deadline: .now() + self.duration, repeating: self.duration)
        timer.setEventHandler { [weak self] in
            NSLog("[GCDTimer] Timer Prepare Scheduled")
            self?.block?()
        }
        return timer
    }()

    private var block: (() -> Void)?
    private let duration: TimeInterval
    private let gcdQueue = DispatchQueue(label: "GCDTimerQueue", attributes: .concurrent)

    init(duration: TimeInterval, block: @escaping () -> Void) {
        self.duration = duration
        self.block = block
    }

    func schedule() {
        if timer == nil {
            NSLog("[GCDTimer] Timer is nil")
            return
        }
        NSLog("[GCDTimer] Timer will be scheduled")
        timer?.resume()
    }
}
```

And call it in the `ViewController.swift` as:

```swift
gcdTimer =  GCDTimer(duration: 3.0, block: gcdTimerFiredBlock)
gcdTimer?.schedule()

    func gcdTimerFiredBlock() -> Void {
        NSLog("[GCDTimer] Timer Fired")
    }
```

Run it! And the print out would be:

```swift
2019-11-05 12:18:34.477133+0900 TestNSTimer[93375:18349565] [GCDTimer] Timer will be scheduled
2019-11-05 12:18:37.477677+0900 TestNSTimer[93375:18349715] [GCDTimer] Timer Prepare Scheduled
2019-11-05 12:18:51.046441+0900 TestNSTimer[93375:18349715] [GCDTimer] Timer Fired
2019-11-05 12:18:51.046826+0900 TestNSTimer[93375:18349715] [GCDTimer] Timer Prepare Scheduled
2019-11-05 12:18:51.047035+0900 TestNSTimer[93375:18349715] [GCDTimer] Timer Fired
2019-11-05 12:18:52.477717+0900 TestNSTimer[93375:18349716] [GCDTimer] Timer Prepare Scheduled
2019-11-05 12:18:52.478171+0900 TestNSTimer[93375:18349716] [GCDTimer] Timer Fired
```

It runs well!!! 🎉

You could also find all of the source code at:
<https://github.com/HevaWu/TestNSTimer>

#### Reference

<https://developer.apple.com/documentation/foundation/nstimer?language=objc>

<https://medium.com/@danielemargutti/the-secret-world-of-nstimer-708f508c9eb>
