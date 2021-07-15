---
layout: post
title: Mobile App Architecture Design
date: 2021-07-15 22:13:00
comment_id: 174
categories: [Application Architecture]
---

## Why Architecture is Necessary

Recent years, mobile application architecture has improved. More and more engineers start paying more attention to patterns and standards. If one application create by low-quality source code, or based on anti-pattern, it will be hard to maintain and develop further. **Good architecture can save time and cost of development.**

One good mobile application architecture can help accelerating development and make future maintenance easier. It always better to programming it follow [SOLID](https://en.wikipedia.org/wiki/SOLID), [KISS](https://www.interaction-design.org/literature/topics/keep-it-simple-stupid), [DRY](https://en.wikipedia.org/wiki/Don%27t_repeat_yourself) or ensure components have multiple responsible layers.

## Divide Layers

One most popular multilayer architecture is [`three-layers architecture`](https://appinventiv.com/blog/mobile-app-architecture-explained/):

- Presentation Layer
  > The aim of this layer is to look into how to present the application to end users. When designing this layer, the mobile app developers must identify the correct client type for intended infrastructure. Additionally, the client’s deployment restrictions must also be kept in mind. Another necessity is selecting the correct data format and using robust data validation mechanisms for protecting the apps from invalid entry.
- Business Layer
  >This layer looks into elements on the business front. In layman words, it looks into the way businesses are presented to the end users. This consists of business components, workflow, and the entities under two sub-layer hood: Domain model and Service.
  >
  > The service layer looks into the definition of common application function set that are available to the end users. While the domain model layer looks into the knowledge and expertise linked to specific problem areas.
- Data Layer
  > The data access layer must meet the application requirements and should help in offering efficient and secure data transactions. Mobile app developers should also consider the maintenance side of the data while ensuring that the data layer can be modified easily with the changing business requirements.
  >
  > This layer consists of the data specific components such as access components, utilities, helpers, and the service agents.

## Pick Right Architecture

- **Platform Specific App**
  - Built for specific mobile platform. Normally it will use specific definite programming languages and frameworks.
  - **good**: fast, work offline, user-friendly, work smoothly on suitable devices
  - **not good**: require considerable investments of time, money into development, need frequent upgrades, not flexible
- **Hybrid App**
  - While platform specific app is limit on one platform, this provide a choice to support multi-platforms. Display web-based content in the native app wrapper. The content can be placed on the app or accessed from a web server. Therefore, these apps have access to the hardware of a device while being web-based, combining web and native screens
  - **good**: cheaper and faster
  - **not good**: connection limitations, can’t work offline, much slower
- **Mobile Web App**
  - Mobile web apps are completely based on web technology and accessible through URL in a browser. Many mobile web app providers create icons that are placed on a home screen and can be launched from there. However, the app isn’t installed into a device but bookmarked on the screen. These apps are built with the help of HTML, JavaScript, and CSS technologies and get automatically updated from the web without any submission process or vendor approval.
  - **good**: highly compatible, easier and cheaper to maintain
  - **not good**: don’t have access to native device features like GPS, cameras, and so on, can have trouble with screen sizes, very limited functionality

Personally, I might still prefer to pick platform-specific technology, ex: Swift for iOS, Kotlin for Android. It can help reducing some un-predictable issue. For long-term perspective, this should be the most time saving way.

Well, in real case, we should always pick proper way depends on our requirements.🤠
