---
layout: post
title: Resize UIImage
date: 2019-09-26 17:15:00
comment_id: 27
categories: [iOS]
tags: [UIImage, CGImage]
---

Actually there is a screenshot problem in our project

- <- only for iOS 13 device, when we try to add a image mask on it, it only generate the `half vertical` image mask.
- <- which means only half side have the mask image.

So the problem should come from the mask part.

But the interesting thing is:
After doing the research, if I use the same image, and try to use its cgImage to make mask context. The printed result is almost same between iOS 13 & iOS 11/12.

```s
--------iOS 13
<CGImage 0x12fe68370> (IP)
	<<CGColorSpace 0x282850f00> (kCGColorSpaceICCBased; kCGColorSpaceModelRGB; Display P3)>
		width = 750, height = 1334, bpc = 16, bpp = 64, row bytes = 6000
		kCGImageAlphaLast | kCGImageByteOrder16Little  | kCGImagePixelFormatPacked
		is mask? No, has masking color? No, has soft mask? No, has matte? No, should interpolate? Yes

<CGContext 0x28029de00> (kCGContextTypeBitmap)
	<<CGColorSpace 0x2813940c0> (kCGColorSpaceDeviceGray)>
		width = 750, height = 1334, bpc = 16, bpp = 16, row bytes = 1500
		kCGImageAlphaNone | 0 (default byte order) | kCGImagePixelFormatPacked (default)

--------iOS 12
<CGImage 0x10c95b590> (IP)
	<<CGColorSpace 0x280a55c20> (kCGColorSpaceICCBased; kCGColorSpaceModelRGB; Display P3)>
		width = 750, height = 1334, bpc = 16, bpp = 64, row bytes = 6000
		kCGImageAlphaLast | kCGImageByteOrder16Little  | kCGImagePixelFormatPacked
		is mask? No, has masking color? No, has soft mask? No, has matte? No, should interpolate? Yes

<CGContext 0x280062700> (kCGContextTypeBitmap)
	<<CGColorSpace 0x2811601e0> (kCGColorSpaceDeviceGray)>
		width = 750, height = 1334, bpc = 16, bpp = 16, row bytes = 1500
		kCGImageAlphaNone | 0 (default byte order)
```

The result above is generated by the following code:

```swift
private func _generateMaskContext(image: UIImage) -> CGContext? {
        guard let cgImage = image.cgImage else { return nil }
        let bpc = cgImage.bitsPerComponent
        return CGContext(data: nil,
                          width: cgImage.width,
                          height: cgImage.height,
                          bitsPerComponent: bpc,
                          bytesPerRow: cgImage.width * bpc / 8,
                          space: CGColorSpaceCreateDeviceGray(),
                          bitmapInfo: CGImageAlphaInfo.none.rawValue)
}

... Do other processing on the mask context
```

So, this function is divide in 2 steps:

- get the image's cgImage
- create a gray color space context based on that's cgImage

And the interesting things happen, it looks like all of the params are same, but the mask result is different <- half mask is disappear TOT

But, wait

This only happens on the `screenshot` <- which is 16 bpc 64 bpp kCGImageAlphaLast picture.

For the normal picture, which take by iPhone camera, the image params are:

```s
<CGImage 0x10c6b73a0> (IP)
	<<CGColorSpace 0x2804da220> (kCGColorSpaceICCBased; kCGColorSpaceModelRGB; Display P3)>
		width = 4032, height = 3024, bpc = 8, bpp = 32, row bytes = 16128
		kCGImageAlphaNoneSkipLast | 0 (default byte order)  | kCGImagePixelFormatPacked
		is mask? No, has masking color? No, has soft mask? No, has matte? No, should interpolate? Yes
```

So I am start wondering, for fixing this bug, maybe I could try to transfer the *16 bpc* picture to *8bpc* one?

For transfering, I use the `UIGraphicsBeginImageContextWithOptions(_:_:_:)` which is recommonended for iOS app. Here is the code:

```swift
extension CGImage {
    static func extractTo8BPC(from uiImage: UIImage) -> CGImage? {
        guard let _cgImage = uiImage.cgImage else {
            return nil
        }

        if _cgImage.bitsPerComponent == 8 {
            return _cgImage
        } else {
            // downscale to 8 bpc
            let _size = uiImage.size

            UIGraphicsBeginImageContextWithOptions(_size, false, 1)
            defer { UIGraphicsEndImageContext() }
            guard let _context = UIGraphicsGetCurrentContext() else { return _cgImage }

            // Note: it is needed to flip the image if drawing a CGImage
            _context.scaleBy(x: 1.0, y: -1.0)
            _context.translateBy(x: 0, y: -_size.height)

            _context.interpolationQuality = .high
            _context.draw(_cgImage, in: CGRect(origin: .zero, size: _size))
            return _context.makeImage()
        }
    }
}
```

The steps of this function is:

- get the iamge's cgimage first
- check if current cgimage is a 8 bpc image, if it is, pass it
- for others(for our case, it would only 16 bpc here), use `UIGraphicsBeginImageContextWithOptions` to generate a context, and draw the current image on it. **Note:** since we are drawing a cgimage at here, we need to manually flip this image, otherwise, it will auto-flip vertically which I actually didn't know why.

Because it need to pass the `size` & `scale` params, so if we want to resize the image, we could also change these 2 params by the code. For example:

```swift
extension UIImage {
    func resize(size _size: CGSize) -> UIImage? {
        let widthRatio = _size.width / size.width
        let heightRatio = _size.height / size.height
        let ratio = widthRatio < heightRatio ? widthRatio : heightRatio

        let resizedSize = CGSize(width: size.width * ratio, height: size.height * ratio)

        // resize the image
        UIGraphicsBeginImageContextWithOptions(resizedSize, false, 0.0)
        draw(in: CGRect(origin: .zero, size: resizedSize))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return resizedImage
    }
}
```

After using this function to generate the cgimage, we could use this cgimage to create the mask context. Since current context is also the 8 bpc one, the mask problem will be solved.

Actually, this is only the temp way to solve the problem. And unfortunately, until now I still not find the root cause of this issue. And if you find other better solutions, please add the comment ~

#### Reference

<https://developer.apple.com/documentation/uikit/1623912-uigraphicsbeginimagecontextwitho>