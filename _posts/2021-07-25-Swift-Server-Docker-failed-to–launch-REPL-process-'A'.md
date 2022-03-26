---
layout: post
title: Swift Server Docker - failed to launch REPL process 'A'
date: 2021-07-25 18:52:00
comment_id: 178
categories: [Docker, Swift]
---

When I tried the official Apple published [Swift Docker Image](https://hub.docker.com/_/swift), I notice it throws me error ⬇️ even I followed the guide.

```s
$ docker run --cap-add sys_ptrace -it --rm swift swift
Unable to find image 'swift:latest' locally
latest: Pulling from library/swift
e7ae86ffe2df: Pull complete
53185c7ef032: Pull complete
4906d3fbd8ee: Pull complete
Digest: sha256:afeaee88cf71f0f0b15ec3db504257abb63e78f6554e8f9091295dbf301424ff
Status: Downloaded newer image for swift:latest
error: failed to launch REPL process: 'A' packet returned an error: 8
```

For solving it, I found 2 ways in this [discussion thread](https://github.com/apple/swift-docker/issues/9#issuecomment-665394982):

- append `--privileged`

```s
$ docker run --privileged --cap-add sys_ptrace -it --rm swift swift
Welcome to Swift version 5.4.2 (swift-5.4.2-RELEASE).
Type :help for assistance.
  1>
```

- append `--security-opt seccomp=unconfined`

```s
$ docker run --cap-add sys_ptrace --security-opt seccomp=unconfined -it --rm swift swift

Welcome to Swift version 5.4.2 (swift-5.4.2-RELEASE).
Type :help for assistance.
  1>
```

#### Reference

- <https://hub.docker.com/_/swift>
- <https://github.com/apple/swift-docker/issues/9>
