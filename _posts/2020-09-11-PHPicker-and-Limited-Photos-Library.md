---
layout: post
title: PHPicker and Limited Photos Library
date: 2020-09-11 19:40:00
comment_id: 98
categories: [iOS, WWDC2020]
tags: [iOS14]
---

As we shared in previous [User Privacy and Data Use](https://hevawu.github.io/blog/2020/08/13/User-Privacy-and-Data-Use) article, Apple provided the limited photo library options to users in iOS 14. And this article will primary talk about this part.

# PHPicker

## What is PHPicker

> PHPicker is the system provided Picker which allows you to get access to photos and videos from the users photo library. It is now built-in support for search just like the photos app. It supports fluid zooming in the grid. And a very often requested feature, multi-select for third party apps, where you can even review your selection in one up.

We will use PHPicker to access photos and video data. It has new design in iOS 14, and will be easy to use.

## Private by default

- No direct access to user Photos Library required
- Won't prompt for Photos Library access
- Provides user selected photos and videos only

![xpc](/images/2020-09-11-PHPicker-and-Limited-Photos-Library/xpc.png)

## New API

- `PHPickerConfiguration`: specify the multi-select limited
- `PHPickerFilter`: optional, selectable types

![api](/images/2020-09-11-PHPicker-and-Limited-Photos-Library/api.png)

### PHPickerConfiguration

Optional properties:

- Selection limit (single item limit by default)
- Item type filtering

```swift
import PhotosUI

var configuration = PHPickerConfiguration()

// “unlimited” selection by specifying 0, default is 1
configuration.selectionLimit = 0

// Only show images (including Live Photos)
configuration.filter = .images
// Uncomment next line for other example: Only show videos or Live Photos (for their video complement), but no images
// configuration.filter = .any(of: [.videos, .livePhotos])
```

### PHPickerViewController

- Initialize with a PHPickerConfiguration
- Client is responsible for presentation

```swift
import UIKit
import PhotosUI

class SingleSelectionPickerViewController: UIViewController, PHPickerViewControllerDelegate {
    @IBAction func presentPicker(_ sender: Any) {
        var configuration = PHPickerConfiguration()
        // Only wants images
        configuration.filter = .images

		// Initialize picker view controller with a configuration
        let picker = PHPickerViewController(configuration: configuration)

		// Assign a delegate
        picker.delegate = self

        // The client is responsible for presentation and dismissal
        present(picker, animated: true)
    }

	// Handling results

    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        // The client is responsible for presentation and dismissal
        picker.dismiss(animated: true)

        // Get the first item provider from the results, the configuration only allowed one image to be selected
        let itemProvider = results.first?.itemProvider

		// Access the UIImage representation for the result
        if let itemProvider = itemProvider, itemProvider.canLoadObject(ofClass: UIImage.self) {
            itemProvider.loadObject(ofClass: UIImage.self) { (image, error) in
                // TODO: Do something with the image or handle the error
            }
        } else {
            // TODO: Handle empty results or item provider not being able load UIImage
        }
    }
}
```

### Demo

- Single Selection

```swift
import UIKit
import PhotosUI

class ViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!

    @IBAction func presentPicker(_ sender: Any) {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images

        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true)
    }
}

extension ViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        dismiss(animated: true)

        if let itemProvider = results.first?.itemProvider, itemProvider.canLoadObject(ofClass: UIImage.self) {
            let previousImage = imageView.image
            itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
                DispatchQueue.main.async {
                    guard let self = self, let image = image as? UIImage, self.imageView.image == previousImage else { return }
                    self.imageView.image = image
                }
            }
        }
    }
}
```

- Multiple Selection

```swift
import UIKit
import PhotosUI

class ViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!

    var itemProviders: [NSItemProvider] = []

	// use iterator to step the multi-images
    var iterator: IndexingIterator<[NSItemProvider]>?

    @IBAction func presentPicker(_ sender: Any) {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images

		// set this selectionLimit for enable multi selection
        configuration.selectionLimit = 0

        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true)
    }

    func displayNextImage() {
        if let itemProvider = iterator?.next(), itemProvider.canLoadObject(ofClass: UIImage.self) {
            let previousImage = imageView.image
            itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
                DispatchQueue.main.async {
                    guard let self = self, let image = image as? UIImage, self.imageView.image == previousImage else { return }
                    self.imageView.image = image
                }
            }
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        displayNextImage()
    }

}

extension ViewController: PHPickerViewControllerDelegate {

    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        dismiss(animated: true)

        itemProviders = results.map(\.itemProvider)
        iterator = itemProviders.makeIterator()
        displayNextImage()
    }

}
```

## Using PHPicker with PhotoKit

```swift
import UIKit
import PhotosUI

class PhotoKitPickerViewController: UIViewController, PHPickerViewControllerDelegate {
    @IBAction func presentPicker(_ sender: Any) {
        let photoLibrary = PHPhotoLibrary.shared()
        let configuration = PHPickerConfiguration(photoLibrary: photoLibrary)
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true)
    }

    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)

        let identifiers = results.compactMap(\.assetIdentifier)
        let fetchResult = PHAsset.fetchAssets(withLocalIdentifiers: identifiers, options: nil)

        // TODO: Do something with the fetch result if you have Photos Library access
    }
}
```

## Notes

- PHPicker will still show the entire library. All photos and videos can be selected.
- Limited Photos Library won't be extended.
- `AssetLibrary` is deprecated, we should use `PhotoKit` instead.
- `UIImagePickerController` will be deprecated, we should use `PHPickerViewController` instead.

![last](/images/2020-09-11-PHPicker-and-Limited-Photos-Library/last.png)

# Limited Photos Library

![full](/images/2020-09-11-PHPicker-and-Limited-Photos-Library/full.png)

![limited](/images/2020-09-11-PHPicker-and-Limited-Photos-Library/limited.png)

Once user select the images, they will only see these images in the app. If user would like to change the selections, they might need to come to Settings to edit their options. OR we could allow user to modify the selections in the app which we will share it in the later.

Use PHPicker when we can:

- Replacement for UIImagePickerController
- Improved with search and multi-select
- Doesn't required user to grant photo library access

## Authorization Status

There will be a new authorization status value: `limited`. And new enumeration: `PHAccessLevel`, which could be `add only` or `read/write`.

![PHAccessLevel](/images/2020-09-11-PHPicker-and-Limited-Photos-Library/PHAccessLevel.png)

```swift
import Photos

let accessLevel: PHAccessLevel = .readWrite
let authorizationStatus = PHPhotoLibrary.authorizationStatus(for: accessLevel)

switch authorizationStatus {
case .limited:
    print("limited authorization granted")
default:
    //FIXME: Implement handling for all authorizationStatus values
    print("Not implemented")
}
```

## Request Access

```swift
import Photos

let requiredAccessLevel: PHAccessLevel = .readWrite // or .addOnly
PHPhotoLibrary.requestAuthorization(for: requiredAccessLevel) { authorizationStatus in
    switch authorizationStatus {
    // Handle all possible PHAuthorizationStatus values
    case .limited:
        print("limited authorization granted")
    default:
        //FIXME: Implement handling for all authorizationStatus
        print("Unimplemented")

    }
}
```

Future deprecation:

![deprecation](/images/2020-09-11-PHPicker-and-Limited-Photos-Library/deprecation.png)

## Notable API differences with limited access

- PHAssets created with PHAssetCreationRequests accessible to the app
- Can't create or fetch user albums
- No cloud shared assets or albums

## Possible UI change

- prompt user to change their selection when appropriate
- stop the system prompt happening on the first photo library access

## Present limited library management UI

```swift
import PhotosUI

let library = PHPhotoLibrary.shared()
let viewController = self

library.presentLimitedLibraryPicker(from: viewController)
```

- Set `PHPhotoLibraryPreventAutomaticLimitedAccessAlert` in app's info.plist

#### References

- <https://developer.apple.com/videos/play/wwdc2020/10652/>
- <https://developer.apple.com/videos/play/wwdc2020/10641/>
