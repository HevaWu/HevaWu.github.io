---
layout: post
title: Daemon and Services
date: 2020-07-02 23:02:00
comments: true
disqus_category_id: DaemonandServices
categories: [Activity Monitor]
tags: [Background Process]
---

## Daemon

> Many kinds of tasks that do not require user interaction are most effectively handled by a process that runs in the background. You can use a daemon or service to:
>
> - Provide server functionality, such serving web pages.
> - Coordinate access to of a shared resource, such as a database.
> - Perform work for a foreground application, such as file system access.

![daemon](/images/2020-07-02-Daemon-and-Services/daemon.png)

### Types of Background Processes

![type](/images/2020-07-02-Daemon-and-Services/type.png)

### Login Items

> Login items are launched when the user logs in, and continue running until the user logs out or manually quits them. Their primary purpose is to allow users to open frequently-used applications automatically, but they can also be used by application developers. For example, a login item can be used to display a menu extra or to register a global hotkey.

### XPC Services

> XPC services are managed by launchd and provide services to a single application. They are typically used to divide an application into smaller parts. This can be used to improve reliability by limiting the impact if a process crashes, and to improve security by limiting the impact if a process is compromised.
>
> Sandboxing allows you to specify a list of things your program is expected to do during normal operation. The operating system enforces that list, limiting the damage that can by done by an attacker. For example, a text editor might need to edit files on disk that have been opened by the user, but it probably does not need to open arbitrary files in other locations or communicate over the network.
>
> You can combine sandboxing with XPC services to provide privilege separation by splitting a complex application, tool, or daemon into smaller pieces with well-defined functionality. Because of the reduced privileges of of each individual piece, any flaws are less exploitable by an attacker: none of the pieces run with the full capabilities of the user. For example, an application that organizes and edits photographs does not usually need network access. However, if it also allows users to upload photos to a photo sharing website, that functionality can be implemented as an XPC service with network access and mediated access (or no access) to the file-system

### Launch Daemons

> Daemons are managed by launchd on behalf of the OS in the system context, which means they are unaware of the users logged on to the system. A daemon cannot initiate contact with a user process directly; it can only respond to requests made by user processes. Because they have no knowledge of users, daemons also have no access to the window server, and thus no ability to post a visual interface or launch a GUI application. Daemons are strictly background processes that respond to low-level requests.
> 
> Most daemons run in the system context of the system—that is, they run at the lowest level of the system and make their services available to all user sessions. Daemons at this level continue running even when no users are logged into the system, so the daemon program should have no direct knowledge of users. Instead, the daemon must wait for a user program to contact it and make a request. As part of that request, the user program usually tells the daemon how to return any results

### Launch Agents

> Agents are managed by launchd, but are run on behalf of the currently logged-in user (that is, in the user context). Agents can communicate with other processes in the same user session and with system-wide daemons in the system context. They can display a visual interface, but this is not recommended.
> 
> If your code provides both user-specific and user-independent services, you might want to create both a daemon and an agent. Your daemon would run in the system context and provide the user-independent services while an instance of your agent would run in each user session. The agents would coordinate with the daemon to provide the services to each user.

## Communicate with Daemons

4 major communication mechanisms:

- XPC
- traditional client-server communications(including Apple events, TCP/IP. UDP, other socket and pipe mechanisms)
- remote procesure calls(including Mach RPC, Sun RPC, and Distributed Objects)
- memory mapping(used underneath the Core Graphics APIs, among others)

## View Currently Running Daemons

We could use `Activity Monitor` application to check it.

#### References

- <https://developer.apple.com/library/archive/documentation/MacOSX/Conceptual/BPSystemStartup/Chapters/Introduction.html>
- <https://developer.apple.com/library/archive/technotes/tn2083/_index.html#//apple_ref/doc/uid/DTS10003794>