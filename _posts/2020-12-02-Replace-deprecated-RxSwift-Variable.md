---
layout: post
title: Replace deprecated RxSwift.Variable
date: 2020-12-02 23:14:00
comment_id: 115
categories: [Swift, RxSwift]
tags: [Variable, BehaviorRelay, BehaviorSubject]
---

On April, 2019, RxSwift developers released the RxSwift 5.0.0 which include RxRelay transitions and Variable deprecations. In their [release notes](https://github.com/ReactiveX/RxSwift/releases/tag/5.0.0), they've mentioned:

> Variable is now entirely deprecated. #1922

However, the replacing might have some potential problem which I'd like to memo it and do the replace carefully. The first thing we need to take care about is:

- `Variable` is a mutable object
- `BehaviorRelay` is a read-only object

For resetting `BehaviorRelay` object value, we should use:

```swift
var copy = relay.value
copy.mutateSomehow()
relay.accept(copy)
```

But, this is a really dangerous replacing mentioned by RxSwift developer:

> https://github.com/ReactiveX/RxSwift/issues/1501#issuecomment-349341598
> this is a dangerous patten because after you read relay.value a new value could be set before you call relay.accept(mutableCopy) and thus you could accidentally overwrite something.

So, this value resetting might have problem in multi-thread context. After searching, it seems we could have two ways to replace the deprecated `Variable`: `BehaviorRelay` or `BehaviorSubject`.

In the `Variable`'s deprecation message, it shows:

> `Variable` is deprecated: Variable is deprecated. Please use `BehaviorRelay` as a replacement.

So, using `BehaviorRelay` to replace this deprecation Variable should be one way.

Another way is using `BehaviorSubject`. This is because: both `Variable` and `BehaviorRelay` are wrapper of `BehaviorSubject`.

## Single Thread Replacing

Let's test the single thread replacing now(This test code could also be found in [this repository]()):

```swift
var disposeBag = DisposeBag()

var variable = Variable<String>("init variable")

variable.asObservable()
    .do(onNext: {
        print("variable value changed: \($0)")
    })
    .debug("=== variable: ")
    .subscribe()
    .disposed(by: disposeBag)

var behaviorRelay = BehaviorRelay<String>(value: "init relay")

behaviorRelay.asObservable()
    .do(onNext: {
        print("behaviorRelay value changed: \($0)")
    })
    .debug("=== behaviorRelay: ")
    .subscribe()
    .disposed(by: disposeBag)

var behaviorSubject = BehaviorSubject<String>(value: "init subject")

behaviorSubject.asObservable()
    .do(onNext: {
        print("behaviorSubject value changed: \($0)")
    })
    .debug("=== behaviorSubject: ")
    .subscribe()
    .disposed(by: disposeBag)

// test single thread replacing

var singleThreadObservable = PublishSubject<String>()

singleThreadObservable
    .observeOn(MainScheduler.instance)
    .subscribe(onNext: { newValue in
        variable.value = newValue
        behaviorRelay.accept(newValue)
        behaviorSubject.onNext(newValue)
    }, onError: { _ in
        variable.value = "[Error] variable"
        behaviorRelay.accept("[Error] behaviorRelay")
        behaviorSubject.onNext("[Error] behaviorSubject")
    })
    .disposed(by: disposeBag)

singleThreadObservable.onNext("single 1")
singleThreadObservable.onNext("single 2")

let error = NSError.init(domain: "rxtestErrorDomain", code: 401, userInfo: [NSLocalizedDescriptionKey: "Single Thread Error 1"])
singleThreadObservable.onError(error)
singleThreadObservable.onNext("single 3")
singleThreadObservable.onNext("single 4")

singleThreadObservable.onCompleted()
singleThreadObservable.onNext("single 5")
singleThreadObservable.onNext("single 6")

// dealloc/clear disposeBag
disposeBag = DisposeBag()

/* Result:
// whole output:
 2020-11-29 21:07:12.870: === variable:  -> subscribed
 variable value changed: init variable
 2020-11-29 21:07:12.898: === variable:  -> Event next(init variable)
 2020-11-29 21:07:12.924: === behaviorRelay:  -> subscribed
 behaviorRelay value changed: init relay
 2020-11-29 21:07:12.924: === behaviorRelay:  -> Event next(init relay)
 2020-11-29 21:07:12.927: === behaviorSubject:  -> subscribed
 behaviorSubject value changed: init subject
 2020-11-29 21:07:12.927: === behaviorSubject:  -> Event next(init subject)
 variable value changed: single 1
 2020-11-29 21:07:12.928: === variable:  -> Event next(single 1)
 behaviorRelay value changed: single 1
 2020-11-29 21:07:12.929: === behaviorRelay:  -> Event next(single 1)
 behaviorSubject value changed: single 1
 2020-11-29 21:07:12.929: === behaviorSubject:  -> Event next(single 1)
 variable value changed: single 2
 2020-11-29 21:07:12.930: === variable:  -> Event next(single 2)
 behaviorRelay value changed: single 2
 2020-11-29 21:07:12.930: === behaviorRelay:  -> Event next(single 2)
 behaviorSubject value changed: single 2
 2020-11-29 21:07:12.931: === behaviorSubject:  -> Event next(single 2)
 variable value changed: [Error] variable
 2020-11-29 21:07:12.932: === variable:  -> Event next([Error] variable)
 behaviorRelay value changed: [Error] behaviorRelay
 2020-11-29 21:07:12.932: === behaviorRelay:  -> Event next([Error] behaviorRelay)
 behaviorSubject value changed: [Error] behaviorSubject
 2020-11-29 21:07:12.932: === behaviorSubject:  -> Event next([Error] behaviorSubject)
 2020-11-29 21:07:12.935: === variable:  -> isDisposed
 2020-11-29 21:07:12.994: === behaviorRelay:  -> isDisposed
 2020-11-29 21:07:12.994: === behaviorSubject:  -> isDisposed
*/
```

From this result, we could find, `Variable`, `BehaviorRelay`, and `BehaviorSubject` not show so big difference on the single thread observing part.

- For observing on sync thread:
  - `Variable`, `BehaviorRelay`, and `BehaviorSubject`: all of three observables updating the value at the same time. They will not be terminated by subscribed observables onError and onCompleted. And they will disposed together once the bind disposeBag is released.
- For observing on async thread:
  - `Variable`, `BehaviorRelay`, and `BehaviorSubject`: all of three are updating the value at the same time. ex: sometimes the async might only updating the `single 2`, all of these three will update their value to `single 2` together.

## Multi-Thread Context Replacing

### Before applying multi-thread

If we are not specifying the observing thread, all of `Variable`, `BehaviorRelay`, and `BehaviorSubject` have the same behavior:

- we will find in the output part, all of three are updated their value in the same time and same order

```swift
var disposeBag = DisposeBag()

var variable = Variable<String>("init variable")

variable.asObservable()
    .debug("=== variable: ")
    .subscribe()
    .disposed(by: disposeBag)

var behaviorRelay = BehaviorRelay<String>(value: "init relay")

behaviorRelay.asObservable()
    .debug("=== behaviorRelay: ")
    .subscribe()
    .disposed(by: disposeBag)

var behaviorSubject = BehaviorSubject<String>(value: "init subject")

behaviorSubject.asObservable()
    .debug("=== behaviorSubject: ")
    .subscribe()
    .disposed(by: disposeBag)

let thread1 = DispatchQueue(label: "Test Thread1")
let thread2 = DispatchQueue(label: "Test Thread2", qos: .utility, attributes: .concurrent, autoreleaseFrequency: .inherit)
let thread3 = DispatchQueue(label: "Test Thread3", qos: .utility, attributes: .concurrent, autoreleaseFrequency: .inherit)

var multiThreadObservable: Observable<String> = Observable.create { observer -> Disposable in
    observer.onNext("multi 1")
    observer.onNext("multi 2")
    observer.onNext("multi 3")
    
    // if we send this onError,
    // in later observing, it will skip all previous onNext, directly send onError part
//    observer.onError(error)
    observer.onCompleted()
    
    observer.onNext("multi 4")
    observer.onNext("multi 5")
    observer.onNext("multi 6")
    return Disposables.create()
}

multiThreadObservable
    .do(onNext: { newValue in
        let newValue = "[Thread 1] " + newValue
        variable.value = newValue
        behaviorRelay.accept(newValue)
        behaviorSubject.onNext(newValue)
    }, onError: { _ in
        variable.value = "[Error] variable"
        behaviorRelay.accept("[Error] behaviorRelay")
        behaviorSubject.onNext("[Error] behaviorSubject")
    })
    .subscribe()
    .disposed(by: disposeBag)

multiThreadObservable
    .do(onNext: { newValue in
        let newValue = "[Thread 2] " + newValue
        variable.value = newValue
        behaviorRelay.accept(newValue)
        behaviorSubject.onNext(newValue)
    }, onError: { _ in
        variable.value = "[Error] variable"
        behaviorRelay.accept("[Error] behaviorRelay")
        behaviorSubject.onNext("[Error] behaviorSubject")
    })
    .subscribe()
    .disposed(by: disposeBag)

multiThreadObservable
    .do(onNext: { newValue in
        let newValue = "[Thread 3] " + newValue
        variable.value = newValue
        behaviorRelay.accept(newValue)
        behaviorSubject.onNext(newValue)
    }, onError: { _ in
        variable.value = "[Error] variable"
        behaviorRelay.accept("[Error] behaviorRelay")
        behaviorSubject.onNext("[Error] behaviorSubject")
    })
    .subscribe()
    .disposed(by: disposeBag)

/*
// whole output:
2020-12-02 22:45:11.642: === variable:  -> subscribed
2020-12-02 22:45:11.643: === variable:  -> Event next(init variable)
2020-12-02 22:45:11.671: === behaviorRelay:  -> subscribed
2020-12-02 22:45:11.697: === behaviorRelay:  -> Event next(init relay)
2020-12-02 22:45:11.700: === behaviorSubject:  -> subscribed
2020-12-02 22:45:11.700: === behaviorSubject:  -> Event next(init subject)
2020-12-02 22:45:11.703: === variable:  -> Event next([Thread 1] multi 1)
2020-12-02 22:45:11.703: === behaviorRelay:  -> Event next([Thread 1] multi 1)
2020-12-02 22:45:11.703: === behaviorSubject:  -> Event next([Thread 1] multi 1)
2020-12-02 22:45:11.704: === variable:  -> Event next([Thread 1] multi 2)
2020-12-02 22:45:11.705: === behaviorRelay:  -> Event next([Thread 1] multi 2)
2020-12-02 22:45:11.705: === behaviorSubject:  -> Event next([Thread 1] multi 2)
2020-12-02 22:45:11.705: === variable:  -> Event next([Thread 1] multi 3)
2020-12-02 22:45:11.706: === behaviorRelay:  -> Event next([Thread 1] multi 3)
2020-12-02 22:45:11.706: === behaviorSubject:  -> Event next([Thread 1] multi 3)
2020-12-02 22:45:11.707: === variable:  -> Event next([Thread 2] multi 1)
2020-12-02 22:45:11.708: === behaviorRelay:  -> Event next([Thread 2] multi 1)
2020-12-02 22:45:11.708: === behaviorSubject:  -> Event next([Thread 2] multi 1)
2020-12-02 22:45:11.708: === variable:  -> Event next([Thread 2] multi 2)
2020-12-02 22:45:11.709: === behaviorRelay:  -> Event next([Thread 2] multi 2)
2020-12-02 22:45:11.709: === behaviorSubject:  -> Event next([Thread 2] multi 2)
2020-12-02 22:45:11.766: === variable:  -> Event next([Thread 2] multi 3)
2020-12-02 22:45:11.767: === behaviorRelay:  -> Event next([Thread 2] multi 3)
2020-12-02 22:45:11.767: === behaviorSubject:  -> Event next([Thread 2] multi 3)
2020-12-02 22:45:11.767: === variable:  -> Event next([Thread 3] multi 1)
2020-12-02 22:45:11.768: === behaviorRelay:  -> Event next([Thread 3] multi 1)
2020-12-02 22:45:11.768: === behaviorSubject:  -> Event next([Thread 3] multi 1)
2020-12-02 22:45:11.768: === variable:  -> Event next([Thread 3] multi 2)
2020-12-02 22:45:11.769: === behaviorRelay:  -> Event next([Thread 3] multi 2)
2020-12-02 22:45:11.769: === behaviorSubject:  -> Event next([Thread 3] multi 2)
2020-12-02 22:45:11.769: === variable:  -> Event next([Thread 3] multi 3)
2020-12-02 22:45:11.770: === behaviorRelay:  -> Event next([Thread 3] multi 3)
2020-12-02 22:45:11.770: === behaviorSubject:  -> Event next([Thread 3] multi 3)
*/
```

### After applying thread

With updating `multiThreadObservable` by adding the `delay` to control update value in different thread: 

- If the time is not covered, all of three are updating their value in same order and almost same time

```swift
multiThreadObservable
    .delay(.milliseconds(100), scheduler: ConcurrentDispatchQueueScheduler(queue: thread1))
    .do(onNext: { newValue in
        let newValue = "[Thread 1] " + newValue
        variable.value = newValue
        behaviorRelay.accept(newValue)
        behaviorSubject.onNext(newValue)
    }, onError: { _ in
        variable.value = "[Error] variable"
        behaviorRelay.accept("[Error] behaviorRelay")
        behaviorSubject.onNext("[Error] behaviorSubject")
    })
    .subscribe()
    .disposed(by: disposeBag)

multiThreadObservable
    .delay(.milliseconds(200), scheduler: ConcurrentDispatchQueueScheduler(queue: thread2))
    .do(onNext: { newValue in
        let newValue = "[Thread 2] " + newValue
        variable.value = newValue
        behaviorRelay.accept(newValue)
        behaviorSubject.onNext(newValue)
    }, onError: { _ in
        variable.value = "[Error] variable"
        behaviorRelay.accept("[Error] behaviorRelay")
        behaviorSubject.onNext("[Error] behaviorSubject")
    })
    .subscribe()
    .disposed(by: disposeBag)

multiThreadObservable
    .delay(.milliseconds(300), scheduler: ConcurrentDispatchQueueScheduler(queue: thread3))
    .do(onNext: { newValue in
        let newValue = "[Thread 3] " + newValue
        variable.value = newValue
        behaviorRelay.accept(newValue)
        behaviorSubject.onNext(newValue)
    }, onError: { _ in
        variable.value = "[Error] variable"
        behaviorRelay.accept("[Error] behaviorRelay")
        behaviorSubject.onNext("[Error] behaviorSubject")
    })
    .subscribe()
    .disposed(by: disposeBag)

/*
// whole output:
2020-12-02 22:47:43.843: === variable:  -> subscribed
2020-12-02 22:47:43.844: === variable:  -> Event next(init variable)
2020-12-02 22:47:43.871: === behaviorRelay:  -> subscribed
2020-12-02 22:47:43.896: === behaviorRelay:  -> Event next(init relay)
2020-12-02 22:47:43.899: === behaviorSubject:  -> subscribed
2020-12-02 22:47:43.899: === behaviorSubject:  -> Event next(init subject)
2020-12-02 22:47:44.003: === variable:  -> Event next([Thread 1] multi 1)
2020-12-02 22:47:44.004: === behaviorRelay:  -> Event next([Thread 1] multi 1)
2020-12-02 22:47:44.004: === behaviorSubject:  -> Event next([Thread 1] multi 1)
2020-12-02 22:47:44.005: === variable:  -> Event next([Thread 1] multi 2)
2020-12-02 22:47:44.006: === behaviorRelay:  -> Event next([Thread 1] multi 2)
2020-12-02 22:47:44.006: === behaviorSubject:  -> Event next([Thread 1] multi 2)
2020-12-02 22:47:44.007: === variable:  -> Event next([Thread 1] multi 3)
2020-12-02 22:47:44.007: === behaviorRelay:  -> Event next([Thread 1] multi 3)
2020-12-02 22:47:44.008: === behaviorSubject:  -> Event next([Thread 1] multi 3)
2020-12-02 22:47:44.104: === variable:  -> Event next([Thread 2] multi 1)
2020-12-02 22:47:44.105: === behaviorRelay:  -> Event next([Thread 2] multi 1)
2020-12-02 22:47:44.105: === behaviorSubject:  -> Event next([Thread 2] multi 1)
2020-12-02 22:47:44.106: === variable:  -> Event next([Thread 2] multi 2)
2020-12-02 22:47:44.106: === behaviorRelay:  -> Event next([Thread 2] multi 2)
2020-12-02 22:47:44.107: === behaviorSubject:  -> Event next([Thread 2] multi 2)
2020-12-02 22:47:44.108: === variable:  -> Event next([Thread 2] multi 3)
2020-12-02 22:47:44.108: === behaviorRelay:  -> Event next([Thread 2] multi 3)
2020-12-02 22:47:44.108: === behaviorSubject:  -> Event next([Thread 2] multi 3)
2020-12-02 22:47:44.205: === variable:  -> Event next([Thread 3] multi 1)
2020-12-02 22:47:44.206: === behaviorRelay:  -> Event next([Thread 3] multi 1)
2020-12-02 22:47:44.206: === behaviorSubject:  -> Event next([Thread 3] multi 1)
2020-12-02 22:47:44.208: === variable:  -> Event next([Thread 3] multi 2)
2020-12-02 22:47:44.208: === behaviorRelay:  -> Event next([Thread 3] multi 2)
2020-12-02 22:47:44.209: === behaviorSubject:  -> Event next([Thread 3] multi 2)
2020-12-02 22:47:44.209: === variable:  -> Event next([Thread 3] multi 3)
2020-12-02 22:47:44.210: === behaviorRelay:  -> Event next([Thread 3] multi 3)
2020-12-02 22:47:44.210: === behaviorSubject:  -> Event next([Thread 3] multi 3)
*/
```

**NOTE:**

If we update the value in different thread at the same time:

- By using `BehaviorRelay` and `BehaviorSubject`, they will not block any updating, and will not show any warning, but the result are not follow the order.

```swift
multiThreadObservable
    .delay(.milliseconds(100), scheduler: ConcurrentDispatchQueueScheduler(queue: thread1))
    .do(onNext: { newValue in
        let newValue = "[Thread 1] " + newValue
//        variable.value = newValue
        behaviorRelay.accept(newValue)
        behaviorSubject.onNext(newValue)
    }, onError: { _ in
//        variable.value = "[Error] variable"
        behaviorRelay.accept("[Error] behaviorRelay")
        behaviorSubject.onNext("[Error] behaviorSubject")
    })
    .subscribe()
    .disposed(by: disposeBag)

multiThreadObservable
    .delay(.milliseconds(100), scheduler: ConcurrentDispatchQueueScheduler(queue: thread2))
    .do(onNext: { newValue in
        let newValue = "[Thread 2] " + newValue
//        variable.value = newValue
        behaviorRelay.accept(newValue)
        behaviorSubject.onNext(newValue)
    }, onError: { _ in
//        variable.value = "[Error] variable"
        behaviorRelay.accept("[Error] behaviorRelay")
        behaviorSubject.onNext("[Error] behaviorSubject")
    })
    .subscribe()
    .disposed(by: disposeBag)

multiThreadObservable
    .delay(.milliseconds(100), scheduler: ConcurrentDispatchQueueScheduler(queue: thread3))
    .do(onNext: { newValue in
        let newValue = "[Thread 3] " + newValue
//        variable.value = newValue
        behaviorRelay.accept(newValue)
        behaviorSubject.onNext(newValue)
    }, onError: { _ in
//        variable.value = "[Error] variable"
        behaviorRelay.accept("[Error] behaviorRelay")
        behaviorSubject.onNext("[Error] behaviorSubject")
    })
    .subscribe()
    .disposed(by: disposeBag)

/*
// whole output:
2020-12-02 22:52:24.819: === variable:  -> subscribed
2020-12-02 22:52:24.844: === variable:  -> Event next(init variable)
2020-12-02 22:52:24.868: === behaviorRelay:  -> subscribed
2020-12-02 22:52:24.868: === behaviorRelay:  -> Event next(init relay)
2020-12-02 22:52:24.870: === behaviorSubject:  -> subscribed
2020-12-02 22:52:24.870: === behaviorSubject:  -> Event next(init subject)
2020-12-02 22:52:24.974: === behaviorRelay:  -> Event next([Thread 1] multi 1)
2020-12-02 22:52:24.974: === behaviorSubject:  -> Event next([Thread 1] multi 1)
2020-12-02 22:52:24.975: === behaviorRelay:  -> Event next([Thread 2] multi 1)
2020-12-02 22:52:24.975: === behaviorRelay:  -> Event next([Thread 1] multi 2)
2020-12-02 22:52:24.975: === behaviorRelay:  -> Event next([Thread 3] multi 1)
2020-12-02 22:52:24.975: === behaviorSubject:  -> Event next([Thread 2] multi 1)
2020-12-02 22:52:24.976: === behaviorSubject:  -> Event next([Thread 1] multi 2)
2020-12-02 22:52:24.976: === behaviorSubject:  -> Event next([Thread 3] multi 1)
2020-12-02 22:52:24.976: === behaviorRelay:  -> Event next([Thread 1] multi 3)
2020-12-02 22:52:24.977: === behaviorSubject:  -> Event next([Thread 1] multi 3)
2020-12-02 22:52:24.977: === behaviorRelay:  -> Event next([Thread 2] multi 2)
2020-12-02 22:52:24.978: === behaviorSubject:  -> Event next([Thread 2] multi 2)
2020-12-02 22:52:24.979: === behaviorRelay:  -> Event next([Thread 3] multi 2)
2020-12-02 22:52:24.979: === behaviorRelay:  -> Event next([Thread 2] multi 3)
2020-12-02 22:52:24.980: === behaviorSubject:  -> Event next([Thread 3] multi 2)
2020-12-02 22:52:25.031: === behaviorSubject:  -> Event next([Thread 2] multi 3)
2020-12-02 22:52:25.031: === behaviorRelay:  -> Event next([Thread 3] multi 3)
2020-12-02 22:52:25.032: === behaviorSubject:  -> Event next([Thread 3] multi 3)

// summarize
// behaviorRelay value updated order:
2020-12-02 22:52:24.868: === behaviorRelay:  -> subscribed
2020-12-02 22:52:24.868: === behaviorRelay:  -> Event next(init relay)
2020-12-02 22:52:24.974: === behaviorRelay:  -> Event next([Thread 1] multi 1)
2020-12-02 22:52:24.975: === behaviorRelay:  -> Event next([Thread 2] multi 1)
2020-12-02 22:52:24.975: === behaviorRelay:  -> Event next([Thread 1] multi 2)
2020-12-02 22:52:24.975: === behaviorRelay:  -> Event next([Thread 3] multi 1)
2020-12-02 22:52:24.976: === behaviorRelay:  -> Event next([Thread 1] multi 3)
2020-12-02 22:52:24.977: === behaviorRelay:  -> Event next([Thread 2] multi 2)
2020-12-02 22:52:24.979: === behaviorRelay:  -> Event next([Thread 3] multi 2)
2020-12-02 22:52:24.979: === behaviorRelay:  -> Event next([Thread 2] multi 3)
2020-12-02 22:52:25.031: === behaviorRelay:  -> Event next([Thread 3] multi 3)

// behaviorSubject value update order:
2020-12-02 22:52:24.870: === behaviorSubject:  -> subscribed
2020-12-02 22:52:24.870: === behaviorSubject:  -> Event next(init subject)
2020-12-02 22:52:24.974: === behaviorSubject:  -> Event next([Thread 1] multi 1)
2020-12-02 22:52:24.975: === behaviorSubject:  -> Event next([Thread 2] multi 1)
2020-12-02 22:52:24.976: === behaviorSubject:  -> Event next([Thread 1] multi 2)
2020-12-02 22:52:24.976: === behaviorSubject:  -> Event next([Thread 3] multi 1)
2020-12-02 22:52:24.977: === behaviorSubject:  -> Event next([Thread 1] multi 3)
2020-12-02 22:52:24.978: === behaviorSubject:  -> Event next([Thread 2] multi 2)
2020-12-02 22:52:24.980: === behaviorSubject:  -> Event next([Thread 3] multi 2)
2020-12-02 22:52:25.031: === behaviorSubject:  -> Event next([Thread 2] multi 3)
2020-12-02 22:52:25.032: === behaviorSubject:  -> Event next([Thread 3] multi 3)
*/
```

- By using `Variable`, we cannot updating the value in different thread at the same time. It will show `Synchronization anomaly was detected.` warnings. And we can also find that the `Variable` value updated order is same as `BehaviorRelay` and `BehaviorSubject`.

```swift
multiThreadObservable
    .delay(.milliseconds(100), scheduler: ConcurrentDispatchQueueScheduler(queue: thread1))
    .do(onNext: { newValue in
        let newValue = "[Thread 1] " + newValue
        variable.value = newValue
        behaviorRelay.accept(newValue)
        behaviorSubject.onNext(newValue)
    }, onError: { _ in
        variable.value = "[Error] variable"
        behaviorRelay.accept("[Error] behaviorRelay")
        behaviorSubject.onNext("[Error] behaviorSubject")
    })
    .subscribe()
    .disposed(by: disposeBag)

multiThreadObservable
    .delay(.milliseconds(100), scheduler: ConcurrentDispatchQueueScheduler(queue: thread2))
    .do(onNext: { newValue in
        let newValue = "[Thread 2] " + newValue
        variable.value = newValue
        behaviorRelay.accept(newValue)
        behaviorSubject.onNext(newValue)
    }, onError: { _ in
        variable.value = "[Error] variable"
        behaviorRelay.accept("[Error] behaviorRelay")
        behaviorSubject.onNext("[Error] behaviorSubject")
    })
    .subscribe()
    .disposed(by: disposeBag)

multiThreadObservable
    .delay(.milliseconds(100), scheduler: ConcurrentDispatchQueueScheduler(queue: thread3))
    .do(onNext: { newValue in
        let newValue = "[Thread 3] " + newValue
        variable.value = newValue
        behaviorRelay.accept(newValue)
        behaviorSubject.onNext(newValue)
    }, onError: { _ in
        variable.value = "[Error] variable"
        behaviorRelay.accept("[Error] behaviorRelay")
        behaviorSubject.onNext("[Error] behaviorSubject")
    })
    .subscribe()
    .disposed(by: disposeBag)

/*
// whole output:
2020-12-02 23:03:44.883: === variable:  -> subscribed
2020-12-02 23:03:44.885: === variable:  -> Event next(init variable)
2020-12-02 23:03:44.886: === behaviorRelay:  -> subscribed
2020-12-02 23:03:44.886: === behaviorRelay:  -> Event next(init relay)
2020-12-02 23:03:44.943: === behaviorSubject:  -> subscribed
2020-12-02 23:03:44.943: === behaviorSubject:  -> Event next(init subject)
2020-12-02 23:03:45.046: === variable:  -> Event next([Thread 1] multi 1)
2020-12-02 23:03:45.047: === behaviorRelay:  -> Event next([Thread 1] multi 1)
2020-12-02 23:03:45.047: === behaviorSubject:  -> Event next([Thread 1] multi 1)
2020-12-02 23:03:45.048: === variable:  -> Event next([Thread 2] multi 1)
2020-12-02 23:03:45.048: === behaviorRelay:  -> Event next([Thread 2] multi 1)
2020-12-02 23:03:45.048: === variable:  -> Event next([Thread 1] multi 2)
2020-12-02 23:03:45.049: === behaviorRelay:  -> Event next([Thread 1] multi 2)
2020-12-02 23:03:45.049: === behaviorSubject:  -> Event next([Thread 2] multi 1)
⚠️ Synchronization anomaly was detected.
  > Debugging: To debug this issue you can set a breakpoint in /Users/hewu/Project/Practice/RxSwift_playground/Pods/RxSwift/RxSwift/Rx.swift:112 and observe the call stack.
  > Problem: This behavior is breaking the observable sequence grammar. `next (error | completed)?`
    This behavior breaks the grammar because there is overlapping between sequence events.
    Observable sequence is trying to send an event before sending of previous event has finished.
  > Interpretation: Two different unsynchronized threads are trying to send some event simultaneously.
    This is undefined behavior because the ordering of the effects caused by these events is nondeterministic and depends on the 
    operating system thread scheduler. This will result in a random behavior of your program.
  > Remedy: If this is the expected behavior this message can be suppressed by adding `.observeOn(MainScheduler.asyncInstance)`
    or by synchronizing sequence events in some other way.

2020-12-02 23:03:45.049: === variable:  -> Event next([Thread 3] multi 1)
2020-12-02 23:03:45.116: === behaviorSubject:  -> Event next([Thread 1] multi 2)
2020-12-02 23:03:45.116: === behaviorRelay:  -> Event next([Thread 3] multi 1)
2020-12-02 23:03:45.116: === variable:  -> Event next([Thread 1] multi 3)
2020-12-02 23:03:45.116: === variable:  -> Event next([Thread 2] multi 2)
2020-12-02 23:03:45.116: === behaviorSubject:  -> Event next([Thread 3] multi 1)
2020-12-02 23:03:45.117: === behaviorRelay:  -> Event next([Thread 1] multi 3)
⚠️ Synchronization anomaly was detected.
  > Debugging: To debug this issue you can set a breakpoint in /Users/hewu/Project/Practice/RxSwift_playground/Pods/RxSwift/RxSwift/Rx.swift:112 and observe the call stack.
  > Problem: This behavior is breaking the observable sequence grammar. `next (error | completed)?`
    This behavior breaks the grammar because there is overlapping between sequence events.
    Observable sequence is trying to send an event before sending of previous event has finished.
  > Interpretation: Two different unsynchronized threads are trying to send some event simultaneously.
    This is undefined behavior because the ordering of the effects caused by these events is nondeterministic and depends on the 
    operating system thread scheduler. This will result in a random behavior of your program.
  > Remedy: If this is the expected behavior this message can be suppressed by adding `.observeOn(MainScheduler.asyncInstance)`
    or by synchronizing sequence events in some other way.

2020-12-02 23:03:45.117: === variable:  -> Event next([Thread 3] multi 2)
2020-12-02 23:03:45.123: === behaviorRelay:  -> Event next([Thread 2] multi 2)
2020-12-02 23:03:45.124: === behaviorSubject:  -> Event next([Thread 1] multi 3)
⚠️ Synchronization anomaly was detected.
  > Debugging: To debug this issue you can set a breakpoint in /Users/hewu/Project/Practice/RxSwift_playground/Pods/RxSwift/RxSwift/Rx.swift:112 and observe the call stack.
  > Problem: This behavior is breaking the observable sequence grammar. `next (error | completed)?`
    This behavior breaks the grammar because there is overlapping between sequence events.
    Observable sequence is trying to send an event before sending of previous event has finished.
  > Interpretation: Two different unsynchronized threads are trying to send some event simultaneously.
    This is undefined behavior because the ordering of the effects caused by these events is nondeterministic and depends on the 
    operating system thread scheduler. This will result in a random behavior of your program.
  > Remedy: If this is the expected behavior this message can be suppressed by adding `.observeOn(MainScheduler.asyncInstance)`
    or by synchronizing sequence events in some other way.

2020-12-02 23:03:45.124: === behaviorRelay:  -> Event next([Thread 3] multi 2)
2020-12-02 23:03:45.125: === behaviorSubject:  -> Event next([Thread 2] multi 2)
2020-12-02 23:03:45.125: === behaviorSubject:  -> Event next([Thread 3] multi 2)
2020-12-02 23:03:45.125: === variable:  -> Event next([Thread 2] multi 3)
2020-12-02 23:03:45.126: === variable:  -> Event next([Thread 3] multi 3)
2020-12-02 23:03:45.126: === behaviorRelay:  -> Event next([Thread 2] multi 3)
2020-12-02 23:03:45.126: === behaviorRelay:  -> Event next([Thread 3] multi 3)
2020-12-02 23:03:45.126: === behaviorSubject:  -> Event next([Thread 2] multi 3)
2020-12-02 23:03:45.127: === behaviorSubject:  -> Event next([Thread 3] multi 3)

// summarize
// variable
2020-12-02 23:03:44.883: === variable:  -> subscribed
2020-12-02 23:03:44.885: === variable:  -> Event next(init variable)
2020-12-02 23:03:45.046: === variable:  -> Event next([Thread 1] multi 1)
2020-12-02 23:03:45.048: === variable:  -> Event next([Thread 2] multi 1)
2020-12-02 23:03:45.048: === variable:  -> Event next([Thread 1] multi 2)
⚠️ Synchronization anomaly was detected.
  > Debugging: To debug this issue you can set a breakpoint in /Users/hewu/Project/Practice/RxSwift_playground/Pods/RxSwift/RxSwift/Rx.swift:112 and observe the call stack.
  > Problem: This behavior is breaking the observable sequence grammar. `next (error | completed)?`
    This behavior breaks the grammar because there is overlapping between sequence events.
    Observable sequence is trying to send an event before sending of previous event has finished.
  > Interpretation: Two different unsynchronized threads are trying to send some event simultaneously.
    This is undefined behavior because the ordering of the effects caused by these events is nondeterministic and depends on the 
    operating system thread scheduler. This will result in a random behavior of your program.
  > Remedy: If this is the expected behavior this message can be suppressed by adding `.observeOn(MainScheduler.asyncInstance)`
    or by synchronizing sequence events in some other way.

2020-12-02 23:03:45.049: === variable:  -> Event next([Thread 3] multi 1)
2020-12-02 23:03:45.116: === variable:  -> Event next([Thread 1] multi 3)
2020-12-02 23:03:45.116: === variable:  -> Event next([Thread 2] multi 2)
⚠️ Synchronization anomaly was detected.
  > Debugging: To debug this issue you can set a breakpoint in /Users/hewu/Project/Practice/RxSwift_playground/Pods/RxSwift/RxSwift/Rx.swift:112 and observe the call stack.
  > Problem: This behavior is breaking the observable sequence grammar. `next (error | completed)?`
    This behavior breaks the grammar because there is overlapping between sequence events.
    Observable sequence is trying to send an event before sending of previous event has finished.
  > Interpretation: Two different unsynchronized threads are trying to send some event simultaneously.
    This is undefined behavior because the ordering of the effects caused by these events is nondeterministic and depends on the 
    operating system thread scheduler. This will result in a random behavior of your program.
  > Remedy: If this is the expected behavior this message can be suppressed by adding `.observeOn(MainScheduler.asyncInstance)`
    or by synchronizing sequence events in some other way.

2020-12-02 23:03:45.117: === variable:  -> Event next([Thread 3] multi 2)
⚠️ Synchronization anomaly was detected.
  > Debugging: To debug this issue you can set a breakpoint in /Users/hewu/Project/Practice/RxSwift_playground/Pods/RxSwift/RxSwift/Rx.swift:112 and observe the call stack.
  > Problem: This behavior is breaking the observable sequence grammar. `next (error | completed)?`
    This behavior breaks the grammar because there is overlapping between sequence events.
    Observable sequence is trying to send an event before sending of previous event has finished.
  > Interpretation: Two different unsynchronized threads are trying to send some event simultaneously.
    This is undefined behavior because the ordering of the effects caused by these events is nondeterministic and depends on the 
    operating system thread scheduler. This will result in a random behavior of your program.
  > Remedy: If this is the expected behavior this message can be suppressed by adding `.observeOn(MainScheduler.asyncInstance)`
    or by synchronizing sequence events in some other way.

2020-12-02 23:03:45.125: === variable:  -> Event next([Thread 2] multi 3)
2020-12-02 23:03:45.126: === variable:  -> Event next([Thread 3] multi 3)

// behaviorRelay
2020-12-02 23:03:44.886: === behaviorRelay:  -> subscribed
2020-12-02 23:03:44.886: === behaviorRelay:  -> Event next(init relay)
2020-12-02 23:03:45.047: === behaviorRelay:  -> Event next([Thread 1] multi 1)
2020-12-02 23:03:45.048: === behaviorRelay:  -> Event next([Thread 2] multi 1)
2020-12-02 23:03:45.049: === behaviorRelay:  -> Event next([Thread 1] multi 2)
2020-12-02 23:03:45.116: === behaviorRelay:  -> Event next([Thread 3] multi 1)
2020-12-02 23:03:45.117: === behaviorRelay:  -> Event next([Thread 1] multi 3)
2020-12-02 23:03:45.123: === behaviorRelay:  -> Event next([Thread 2] multi 2)
2020-12-02 23:03:45.124: === behaviorRelay:  -> Event next([Thread 3] multi 2)
2020-12-02 23:03:45.126: === behaviorRelay:  -> Event next([Thread 2] multi 3)
2020-12-02 23:03:45.126: === behaviorRelay:  -> Event next([Thread 3] multi 3)

// behaviorSubject
2020-12-02 23:03:44.943: === behaviorSubject:  -> subscribed
2020-12-02 23:03:44.943: === behaviorSubject:  -> Event next(init subject)
2020-12-02 23:03:45.047: === behaviorSubject:  -> Event next([Thread 1] multi 1)
2020-12-02 23:03:45.049: === behaviorSubject:  -> Event next([Thread 2] multi 1)
2020-12-02 23:03:45.116: === behaviorSubject:  -> Event next([Thread 1] multi 2)
2020-12-02 23:03:45.116: === behaviorSubject:  -> Event next([Thread 3] multi 1)
2020-12-02 23:03:45.124: === behaviorSubject:  -> Event next([Thread 1] multi 3)
2020-12-02 23:03:45.125: === behaviorSubject:  -> Event next([Thread 2] multi 2)
2020-12-02 23:03:45.125: === behaviorSubject:  -> Event next([Thread 3] multi 2)
2020-12-02 23:03:45.126: === behaviorSubject:  -> Event next([Thread 2] multi 3)
2020-12-02 23:03:45.127: === behaviorSubject:  -> Event next([Thread 3] multi 3)
*/
```

# Summarize

For replacing `Variable`:

- If we could update the observable value in same thread by order, we can directly replace `Variable` by using `BehaviorRelay` or `BehaviorSubject`
- If we need to update the observable value in different thread, but we can control the update order, we can directly replace `Variable` by using `BehaviorRelay` or `BehaviorSubject`
- If there is a case we need to update the observable value in different thread at the same time, even using `Variable`, we also cannot make sure value is update correctly. For this case, we should consider our code logic again, and making the value update in order then replace `Variable` by using `BehaviorRelay` or `BehaviorSubject`

The difference between `BehaviorRelay` and `BehaviorSubject` is:

- `BehaviorRelay` is a RelayObject, which is a wrapper of `BehaviorSubject`, it will not terminate by error or complete event
- `BehaviorSubject` is an ObserverType, which will terminate by error or complete event

#### Reference

- <https://github.com/ReactiveX/RxSwift/issues/1501#issuecomment-347021795>
- <https://github.com/ReactiveX/RxSwift/pull/1546>
- <https://github.com/ReactiveX/RxSwift/pull/1922>
