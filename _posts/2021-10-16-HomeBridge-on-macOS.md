---
layout: post
title: HomeBridge on macOS
date: 2021-10-16 09:48:00
comment_id: 196
categories: [macOS, HomeKit]
tags: [HomeBridge]
---

## Download LTS Node.js

<https://nodejs.org/en/download/>

check succeed or not by:

```s
$ npm -v
$ node -v
```

## Install HomeBridge and HomeBridge UI

```s
$ sudo npm install -g --unsafe-perm homebridge homebridge-config-ui-x
$ sudo hb-service install
```

## Login Homebridge UI

1. visit `http://localhost:8581`, with `user: admin, pass: admin`
2. Configure

|   |  File Location / Command |
|---|---|
|  Config File Path |  ~/.homebridge/config.json |
| Storage Path| 	~/.homebridge |
|Restart Command	|sudo hb-service restart
|Stop Command	|sudo hb-service stop
|Start Command	|sudo hb-service start
|View Logs Command	|hb-service logs
|Launchctl Service File	|/Library/LaunchDaemons/com.homebridge.server.plist |

## Connect Nature Remo

<https://developer.nature.global/en/overview>

### Take Access Token

Issue Access Token from: <https://home.nature.global/>

### Get Applications

- Call: <https://swagger.nature.global/#/default/get_1_appliances>
- Find preferred plugin and add them into `accessories`.

ex: `homebridge-nature-remo-sensor` plugin to setup Temperature Sensor

```json
{
    "bridge": {
        ...
    },
    "accessories": [
        {
            "name": "Temperature sensor",
            "deviceName": "Nature Remo Mini",
            "accessToken": "YOUR TOKEN",
            "mini": true,
            "sensors": {
                "temperature": true,
                "humidity": false,
                "light": false
            },
            "accessory": "remo-sensor"
        }
    ],
    "platforms": [
        {
            "..."
        }
    ]
}
```

#### References

- <https://github.com/homebridge/homebridge/wiki/Install-Homebridge-on-macOS>
