---
layout: post
title: Bazel Memo
date: 2022-08-08 11:30:00
comment_id: 228
categories: [Bazel]
---

Install from `brew`, use

```s
brew install bazelisk
```

## File

- [BUILD or BUILD.bazel](https://bazel.build/reference/glossary#build-file) file: main configuration file tells Bazel what software outputs to build, what their dependencies are, how to build them.
  - Bazel takes a `BUILD` file as input and use the file to create graph of dependencies and to derive actions that must be completed to build intermediate and final software outputs
  - mark directory and any sub-directories not containing a `BUILD` file as a `package`, can contain `targets` created by `rules`
- [WORKSPACE](https://bazel.build/reference/glossary#workspace-file) file: a directory to be a workspace.
  - file can be empty
  - usually contain external repository declarations to fetch additional dependencies from network or local filesystem.

## Commands

```s
# buld BUILD file
# ex: bazel build //main:hello-world
bazel build //[path from WORKSPACE to BUILD:target name]

# test build
# ex: bazel-bin/main/hello-world
bazel-bin/[path from WORKSPACE to BUILD]/[target name]
```

## Common C++ Rules

- [cc_binary](https://bazel.build/reference/be/c-cpp#cc_binary): build self-contained executable binary form source file and some dependencies
- [cc_library](https://bazel.build/reference/be/c-cpp#cc_library)
  - all header files that are used in build must be declared in `hdrs` or `srcs` of `cc_*` rules
  - headers in `hdrs` comprise the public interface of library, can be directly included both from `hdrs` and `srcs` as well as from files in `hdrs` and `srcs` of `cc_*` that list the library in `deps`
  - headers in `srcs` must only be directly included form files in `hdrs` and `srcs` of the library itself
  - whether to put header into `hdrs` or `srcs`, check whether we want this library to be able to directly include it
    - roughly `public` and `private`
  - only apply to `direct` inclusions
  - compilation of `.cc` file transitively include any header in `hdrs` or `srcs` in any `cc_library` in transitive `deps` closure

## [Common C++ Build Use Cases](https://bazel.build/tutorials/cpp-use-cases)

```s
# include multiple files in target
cc_library(
    name = "build-all-the-files",
    srcs = glob(["*.cc"]),
    hdrs = glob(["*.h"]),
)

# =================================================

# transitive includes
# sandwich depends on bread, bread depends on flour
# but sandwich NOT include flour
cc_library(
    name = "sandwich",
    srcs = ["sandwich.cc"],
    hdrs = ["sandwich.h"],
    deps = [":bread"],
)

cc_library(
    name = "bread",
    srcs = ["bread.cc"],
    hdrs = ["bread.h"],
    deps = [":flour"],
)

cc_library(
    name = "flour",
    srcs = ["flour.cc"],
    hdrs = ["flour.h"],
)

# =================================================

# include paths
# use copts to specify include directly
# └── my-project
#     ├── legacy
#     │   └── some_lib
#     │       ├── BUILD
#     │       ├── include
#     │       │   └── some_lib.h
#     │       └── some_lib.cc
#     └── WORKSPACE
cc_library(
    name = "some_lib",
    srcs = ["some_lib.cc"],
    hdrs = ["include/some_lib.h"],
    copts = ["-Ilegacy/some_lib/include"],
)

# =================================================

# include external libraries
# cc_ rules can depend on @gtest://main

# Code Style 1
# in WORKSPACE
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

http_archive(
    name = "gtest",
    url = "https://github.com/google/googletest/archive/release-1.10.0.zip",
    sha256 = "94c634d499558a76fa649edb13721dce6e98fb1e7018dfaeba3cd7a083945e91",
    build_file = "@//:gtest.BUILD",
)

# in create gtest.BUILD, which use to compile
cc_library(
    name = "main",
    srcs = glob(
        ["googletest-release-1.10.0/src/*.cc"],
        exclude = ["googletest-release-1.10.0/src/gtest-all.cc"]
    ),
    hdrs = glob([
        "googletest-release-1.10.0/include/**/*.h",
        "googletest-release-1.10.0/src/*.h"
    ]),
    copts = [
        "-Iexternal/gtest/googletest-release-1.10.0/include",
        "-Iexternal/gtest/googletest-release-1.10.0"
    ],
    linkopts = ["-pthread"],
    visibility = ["//visibility:public"],
)

# Code Style 2
# use strip_prefix
# in WORKSPACE
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

http_archive(
    name = ...,
    url = ...,
    sha256 = ...,
    build_file = ...,
    strip_prefix = "googletest-release-1.10.0",
)

# in gtest.BUILD
cc_library(
    name = "main",
    srcs = glob(
        ["src/*.cc"],
        exclude = ["src/gtest-all.cc"]
    ),
    hdrs = glob([
        "include/**/*.h",
        "src/*.h"
    ]),
    copts = ["-Iexternal/gtest/include"],
    linkopts = ["-pthread"],
    visibility = ["//visibility:public"],
)

# =================================================

# write and run C++ tests
# in ./test/hello-test.cc

#include "gtest/gtest.h"
#include "main/hello-greet.h"
TEST(HelloTest, GetGreet) {
  EXPECT_EQ(get_greet("Bazel"), "Hello Bazel");
}

# in ./test/BUILD
cc_test(
    name = "hello-test",
    srcs = ["hello-test.cc"],
    copts = ["-Iexternal/gtest/include"],
    deps = [
        "@gtest//:main",
        "//main:hello-greet",
    ],
)

# in ./main/BUILD
# add "//test:__pkg__" to `visibility`

# run test command
bazel test test:hello-test

# =================================================

# add dependencies on pre-compiled libraries
# ex: only have compiled version, headers and a .so file
cc_library(
    name = "mylib",
    srcs = ["mylib.so"],
    hdrs = ["mylib.h"],
)
```

## Definitions

- [Action](https://bazel.build/reference/glossary#action): a command to run during build. Includes metadata like the command line arguments, action key, environment variables, and declared input/output artifacts.
- [Artifact](https://bazel.build/reference/glossary#artifact): source file of a generated file
  - artifact can be an input to multiple actions, but must only be generated by at most one action
- [Package Group](https://bazel.build/reference/glossary#package-group): a target representing a set of packages
  - often used in visibility attribute values
- [Package](https://bazel.build/reference/glossary#package): set of `targets` defined by `BUILD` file. A package's name is `BUILD` file's path relative to the workspace root. A package can contain sub-packages, or subdirectories containing `BUILD` files.
- [Rule](https://bazel.build/reference/glossary#rule): function implementation that register a series of `actions` to be performed on input `artifacts` to produce a set of output artifacts.
  - read values from attributes as inputs
  - for language specific rules: <https://bazel.build/reference/be/c-cpp>
- [Target](https://bazel.build/reference/glossary#target): build-able unit. Can be a `rule` target, file target, `package group`.
  - rule target are instantiated from rule declarations in BUILD files. Based on implementation, can be testable or runnable.
  - file target: every file used in BUILD files
  - targets can
  - configured target: pair of target and build configuration
- [Workspace](https://bazel.build/reference/glossary#workspace): directory contain a `WORKSPACE` file and source code. Labels that start with `//` are relative to workspace directory

#### References

- Bazel: <https://bazel.build/>
- Glossary: <https://bazel.build/reference/glossary>
- Language Specific rules: <https://bazel.build/reference/be/c-cpp>
- Bazel C++ tutorial: <https://bazel.build/tutorials/cpp>
- Configure C++ Toolchain: <https://bazel.build/tutorials/cc-toolchain-config>
