---
layout: post
title: Duet Activity Scheduler Daemon
date: 2020-07-02 22:37:00
comments: true
disqus_category_id: DuetActivitySchedulerDaemon
categories: [Mac, iPhone, Activity Monitor]
tags: [Background Process]
---

Recently when we tried to add our own remote notification, we notice that there is a thread called `dasd` which cancel our background push notification. So what it is?

## Duet Activity Scheduler Daemon

`dasd` which is called `Duet Activity Scheduler Daemon`. `Daemon` is a background process, this particular daemon manages other background processes. Normally, it shows as:

```s
dasd -- Daemon for background activity scheduling
dasd -- Daemon Canceling Activites: {{}}
dasd -- Removing a launch request for application <private> by activity <private>
...
```

So, it helps manage background activities.

> Duet Activity Scheduler (DAS) maintains a scored list of background activities which usually consists of more than seventy items. Periodically, it rescores each item in its list, according to various criteria such as whether it is now due to be performed, i.e. clock time is now within the time period in which Centralized Task Scheduling (CTS) calculated it should next be run.

It there is some problem probably with a background task, we might need to check to see what other processes are using up a lot of resources and look into them. 🧐

## How macOS processing in the background

### Create and Schedule background activity

`NSBackgroundActivityScheduler`, Apple provides this which for createa an acitivity which it then hands over to macOS to manage in the background(include one-off, on-demand, and repeated activities).

### Run bakcground acitivity

> If its CurrentScore exceeds the ThresholdScore, and is closer to 1.0, then DAS sets the DecisionToRun for that activity to 1, which is the signal to CTS to run the activity. If the CurrentScore is below the ThresholdScore, then its DecisionToRun is set to 0, and the activity is left to the next rescoring.
> 
> With DAS giving an activity the instruction to run, that action is passed to CTS, which writes in the log that “DAS told us to run” the activity. It changes the activity’s state from 1 to 2, and initiates inter-process communication by XPC to the running activity.
> 
> When the activity is complete, its state is changed from 2 to 5, XPC activity finished, and CTS then works out the next time period in which that activity should be run, if it is due to repeat. This is then passed back to DAS for its list of activities and their scores.

### Remove background activity

When the app registed the activity in the first place decides that the activity is no longer required, it signals this through `activity.Invalidate()`, back to CTS(Centralized Task Scheduling)

Here is a diagram drawed by [this article](https://eclecticlight.co/2017/05/13/how-macos-runs-background-activities-1-from-within-an-app/):

![background](/images/2020-07-02-Duet-Activity-Scheduler-Daemon/background.png)

I wil try to put the details of `Daemon` in later article.

#### Reference

- <https://www.howtogeek.com/357437/what-is-dasd-and-why-is-it-running-on-my-mac/>
- <https://eclecticlight.co/2017/05/13/how-macos-runs-background-activities-1-from-within-an-app/>
- <https://developer.apple.com/library/archive/documentation/MacOSX/Conceptual/BPSystemStartup/Chapters/Introduction.html>