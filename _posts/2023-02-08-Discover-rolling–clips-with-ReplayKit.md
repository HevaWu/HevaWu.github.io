---
layout: post
title: Discover rolling clips with ReplayKit
date: 2023-02-08 21:46:00
comment_id: 232
categories: [iOS, WWDC2021]
tags: [ReplayKit]
---

Here is how Apple introduce [ReplayKit](https://developer.apple.com/documentation/replaykit):

> Using the ReplayKit framework, users can record video from the screen, and audio from the app and microphone. They can then share their recordings with other users through email, messages, and social media. You can build app extensions for live broadcasting your content to sharing services. ReplayKit is incompatible with AVPlayer content.

- `In-App Screen Recording`, easy for people to record screen and audio of the app, share recording
- `In-App Screen Capture`, easy for people to have more
  control like additional filters or overlaps, it can be done as . It give the audio and video samples directly to application process
- `In-App Screen Broadcast`, easy for people to stream application to 3rd party broadcast services

Currently, when player play the game, they have to record entire game play in order to save memorable highlights, which results large space.

Let RepayKit to auto record the highlights right when they happen, give the video clip of each moment.

## WWDC2021: In-App Clips Recording

![](/images/2023-02-08-Discover-rolling–clips-with-ReplayKit/clips_recording.png)

Clips recording keep rolling buffer of audio and video samples. When clip export is called, the samples up to 15s prior can be exported into a short video clip. Convert issue to know when user want to export.

- user driven clips
  - add UI button or game controller, people can manual control on when to capture clips
- achievement drive clips
  - add trigger in application, auto capture clips

## Support

Clips recording is available for iOS and macOS. Provide HD quality, low performance impact, privacy safeguards.

## API

3 APIs: start, stop and export.

App call into `RPSScreenRecorder` to get `sharedRecorder` singleton instance. Then call the **`startClipBuffering` API**.

Any samples older than 15s will be discarded. After rolling buffer start, ReplayKit wait for application to tell it to export. When app calls **export clip API**, ReplayKit take care of the rest and return the video clip of that moment.

When no longer need rolling buffer, or when want to user another ReplayKit feature, can call **stop API**, and ReplayKit will tear down the session.

### Sample

```swift
// Start clip buffering API call

func startClipBuffering() {
    RPScreenRecorder.shared().startClipBuffering { error in
        if error != nil {
            print("Error attempting to start Clip Buffering")
            // Update the app recording state and UI.
            self.setClipState(active: false)
        } else {
            // No error encountered attempting to start a clip session.
            // Update the app recording state and UI.
            self.setClipState(active: true)

            // Set up camera View.
            self.setupCameraView()
        }
    }
}

// Stop clip buffering

func stopClipBuffering() {
    RPScreenRecorder.shared().stopClipBuffering { error in
        if error != nil {
            print("Error attempting to stop clip buffering")
        }
        // Update the app recording state and UI.
        self.setClipState(active: false)

        // Tear down camera view.
        self.tearDownCameraView()
    }
}

// Export clip button

@IBAction func exportClipButtonTapped(_ sender: Any) {
    // If clip buffering is active, export clip
    if self.isActive && self.getClipButton.isEnabled {
        exportClip()
    }
}

// Export clip

func exportClip() {
    let clipURL = getAppTempDirectory()
    let interval = TimeInterval(5)

    print("Generating clip at URL: \(clipURL)")
    RPScreenRecorder.shared().exportClip(to: clipURL, duration: interval) { error in
        if error != nil {
            print("Error attempting to export clip")
        } else {
            // No error, so save clip at URL to photos
            self.saveToPhotos(tempURL: clipURL)
        }
    }
}
```

## Game controller integration

- Start and stop recording from controller
- Recording automatically saved to Photos or the Desktop

Suggest code as:

- key value observing available
- key value observing recording
- follow RPScreenRecorderDelegate protocol

#### References

- <https://developer.apple.com/wwdc21/10101>
