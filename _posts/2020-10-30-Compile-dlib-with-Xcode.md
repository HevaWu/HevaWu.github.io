---
layout: post
title: Compile dlib with Xcode
date: 2020-10-30 14:33:00
comment_id: 106
categories: [Xcode]
tags: [dlib, undefined symbol]
---

Recently I'm trying to test if dlib could also work well in Xcode, so I want to memo some troubleshooting what I met at here.

## Build Static Library

For using it, we could download the source code from [dlib github](https://github.com/davisking/dlib). Then follow these steps to compile it.

```s
cd examples
mkdir build && cd build
cmake -D BUILD_SHARED_LIBS=ON -G Xcode ..
cmake --build . --config Release
```

Next, come to "./examples/build/dlib_build", there will be a generated Xcode project there. By changing this project settings to what we want, ex: platforms -> iOS, iOS Deployment Target -> iOS 12.0.

Set the running target to `Any iOS Device` for building arm static library.

![](/images/2020-10-30-Compile-dlib-with-Xcode/iphoneos.png)

Set the running target to any simulator, ex: `iPhone XR` for building x86 static library.

![](/images/2020-10-30-Compile-dlib-with-Xcode/iphoneSimulator.png)

We could find the libraries under "./examples/build/dlib_build/Debug-iphoneos" & "./examples/build/dlib_build/Debug-iphonesimulator".

## Add Static Library into project

- Create a directory, ex: "Dlib". Add files of "./dlib", "./examples/build/dlib_build/Debug-iphoneos", "./examples/build/dlib_build/Debug-iphonesimulator" into this folder.
- Drag "Dlib" folder, into project. Remove project `reference` of "./dlib", "./examples/build/dlib_build/Debug-iphoneos", "./examples/build/dlib_build/Debug-iphonesimulator". Note: only remove `reference`, this should be same as only add files into project directory.
- Add `Build Settings -> HEADER_SEARCH_PATH`: `$(PROJECT_DIR)/TestProject/Dlib`
- Add `Build Settings -> OTHER_FLAGS`: `-l"dlib"`
- Add `Build Settings -> OTHER_CFLAGS`: `-DNDEBUG -DDLIB_JPEG_SUPPORT -DDLIB_USE_BLAS -DDLIB_USE_LAPACK -DLAPACK_FORCE_UNDERSCORE`
- Add `Build Settings -> SWIFT_OBJC_BRIDGING_HEADER`: `TestProject/TestProject-Bridging-Header.h`.I plan to use Swift as project language, so I need to create `TestProject-Bridging-Header.h` for compiling ObjectiveC++.
- Set `Apple Clang - Code Generation -> Optimization Level` Debug env as `Fastest, Samallest[-Os]`. This used for quick building the project. After debugging, we could change it back to `None[-O0]`
- Link Framework: `Accelerate.framework`, `libdlib.a`. The libdlib.a should be the universal static library, which could be generated by previous downloaded 2 static libraries:
    ```s
	cd into TestProject/Dlib
	mkdir Lib-universallib
	xcrun -sdk iphoneos lipo -create Debug-iphoneos/libdlib.a Debug-iphonesimulator/libdlib.a -output Lib-universallib/libdlib.a
    ```
- Add the dlib wrapper ObjectiveC++ code, and add header into `TestProject/TestProject-Bridging-Header.h`

🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉

## Troubleshooting

### Undefined symbol

It seems everything goes well when I test the face landmark detection, however, when I try to test some dnn models, ex: dog_hipsterizer, it throws me these errors ⬇️

```s
Undefined symbol: dlib::tt::affine_transform(dlib::tensor&, dlib::tensor const&, dlib::tensor const&, dlib::tensor const&)
Undefined symbol: dlib::tt::affine_transform_conv(dlib::tensor&, dlib::tensor const&, dlib::tensor const&, dlib::tensor const&)
Undefined symbol: dlib::cpu::tensor_conv::operator()(bool, dlib::resizable_tensor&. dlib::tensor const&, dlib::tensor const&)
Undefined symbol: dlib::tt::add(float, dlib::tensor&, float, dlib::tensor const&)
Undefined symbol: dlib::tt::relu(dlib::tensor&, dlib::tensor const&)
Undefined symbol: dlib::tt::resize_bilinear(dlib::tensor&, long, long, dlib::tensor const&, long, long)
```

**Solution:**
After researching, this might be the library link issue. I'm compiling dlib into 2 static library: iphoneos & iphonesimulator. And I link these 2 libraries by adding them in the `Build Settings -> Library Search Paths` by setting as `$(PROJECT_DIR)/TestProject/Dlib/Debug$(EFFECTIVE_PLATFORM_NAME)` for switch compiling lib automatically. But it seems it cannot work well for the dog_hipsterizer one which are using some cuda libraries. So I switch to use the universal static library for this part.

#### Reference

- <http://dlib.net/>
- <https://github.com/davisking/dlib>
