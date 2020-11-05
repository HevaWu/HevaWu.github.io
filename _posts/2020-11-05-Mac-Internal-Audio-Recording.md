---
layout: post
title: Mac Internal Audio Recording  
date: 2020-11-05 21:43:00
comment_id: 107
categories: [Mac]
tags: [audio, record]
---

MacOS provide the `QuickTime` to record screen with audio. However, it will also record the microphone audio. Sometimes, I prefer to only record internal audio video. And I would like to memo how I do it at here.

There are many third-party plugins that could help modifying the sound settings configuration. The tools I used at here is [Soundflower](https://github.com/mattingalls/Soundflower).

## Steps

- Download latest `Sounflower.dmg` from [here](https://github.com/mattingalls/Soundflower/releases/tag/2.0b2)
- Open the pkg and follow the instruction to install it
- Set `Audio MIDI setup`
  - click `+` button to create an `Aggregate Device` and rename it to `SF Input`. In the right checkbox, select `soundflower 2ch` only. (NOTE: This settings will only use internal audio, if you also want to record the microphone, please select the correspond microphone, mac system one is `Built-in Microphone`)
  - click `+` button to create a `Multi-Output Device` and rename it to `SF Output`. In the right checkbox, select `soundflower 2ch` and `Built-in Output`. (NOTE: `Built-in Output` is for later we could hear pc audio when recording video. If we didn't select it, during recording, we might hear nothing.)
- Click the navigation volume icon to select `SF Output`. (Note: We shouls switch back to Internal Speakers/Headphones once recording finished)
- Open `QuickTime`, select `SF Input` in the bottom `Options - Microphone` Menu and start recording 

#### Reference

- <https://github.com/mattingalls/Soundflower>
