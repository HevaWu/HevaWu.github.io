---
layout: post
title: iOS Networking
date: 2021-07-25 21:42:00
comment_id: 180
categories: [iOS, WWDC2019]
tag: [Network]
---

# Advance Network

## Low Data Mode

- User preference to minimize data usage
  - Explicit signal to reduce network data usage
  - Per WiFi and Cellular network
- System policy
  - Discretionary tasks deferred
  - Background App Refresh disabled
- Application adoption

What app can adopt?

- Reduce image quality
- Reduce pre-fetching
- Synchronize less often
- Mark tasks discretionary
- Disable auto-play
- Do not block user-initiated work

### APIs

URLSession

- Try large/prefetch with `allowsConstrainedNetworkAccess = false`
- On failure with `error.networkUnavailableReason == .constrained` => try low data mode alternative

Network.framework

- Set `prohibitConstrainedPaths` on `NWParameters`
- Check `isConstrained` on `NWPath`
- Handle path updates

### Constrained and Expensive

- Constrained - low data mode
- Expensive - Cellular and Personal Hotspot
    - URLSession: `allowsExpensiveNetworkAccess` (suggested)
    - Network.framework: `isExpensive`

```swift
request.allowsConstrainedNetworkAccess = false

if error.networkUnavailableReason == .constrained {
    session.dataTask(with: lowResImageURL) { data, response, error in
        // handle low data mode url image
    }.resume()
}
```

# Combine in URLSession

- `debounce`, set debounce value
- `removeDuplicates()`, record last value, only send value when its changes

Combine: a declarative API for processing values over time.

## DataTaskPublisher

- single value publisher
- similar to `URLSession.dataTask(with:completionHandler:)`

```swift
// in TableViewCell
var subscriber: AnyCancellable?

override func prepareForReuse() {
    itemImageView.image = nil
    // cancel to make sure we will never got wrong imageView cell
    subscriber?.cancel()
}

// in tableView(_,cellForRowAt:)
request.allowsConstrainedNetworkAccess = false
cell.subscriber = session.dataTaskPublisher(for: request)
    .tryCatch { error -> URLSession.DataTaskPublisher in
        guard error.networkUnavailableReason == .constrained else {
            throw error
        }
        return session.dataTaskPublisher(for: lowResImageURL)
    }
    .tryMap { data, response -> UIImage in
        guard let httpResponse = response as? HTTPURLResponse,
        httpResponse.statusCode == 200,
        let image = UIImage(data: data) else {
            throw invalidServerResponseError
        }
        return image
    }
    .retry(1) // retry catchError, retries and fetch image again, retry once at here
    .replaceError(with: placeHolderImage)
    .receive(on: DispatchQueue.main)
    .assign(to: \.itemImageView.image, on: cell)
```

*NOTE: `retry` is no exception. Avoid `retry` if possible. If we add it, start with very low number.*

```swift
// make generalized publisher for URL loading
func adaptiveLoader(regularURL: URL, lowDataURL: URL) -> AnyPublisher<Data, Error> {
    var request = URLRequest(url: regularURL)
    request.allowsConstrainedNetworkAccess = false
    return URLSession.shared.dataTaskPublisher(for: request)
        .tryCatch { error -> URLSession.DataTaskPublisher in
            guard error.networkUnavailableReason == .constrained else {
                throw error
            }
            return URLSession.shared.dataTaskPublisher(for: lowDataURL)
        }
        .tryMap { data, response -> UIImage in
            guard let httpResponse = response as? HTTPURLResponse,
            httpResponse.statusCode == 200 else {
                throw invalidServerResponseError
            }
            return data
        }
        .eraseToAnyPublisher()
}
```

# WebSocket

- Two-way communication over TLS/TCP connection
- Works with Firewalls and CDNs
- Proxy support

## URLSessionWebSocketTask

- Foundation API for WebSocket
- Works with existing URLSession

```swift
let task = URLSession.shared.webSocketTask(with: testURL)
task.resume()

task.send(.string("Hello")) { error in ... }
task.receive { result in ... }
```

## Network.framework

- Both client and server support
- Receive partial or complete WebSocket messages

```swift
let parameters = NWParameters.tls
let websocketOptions = NWProtocolWebSocket.Options()
websocketOptions.autoReplyPing = true
parameters.defaultProtocolStack.applicationProtocols.insert(websocketOptions, at: 0)

let websocketConnection = NWConnection(to: endpoint, using: parameters)
let websocketListener = try NWListener(using: parameters)

// for context
let metadata = NWProtocolWebSocket.Metadata(opcode: .binary)
let context = NWConnection.ContentContext(identifier: "context", metadata: [metadata])
client.send(content: data, contentContext: context, isComplete: true, completion: ...)

// in websocket client
let task = session.webSocketTask(with: webSocketURL)
task.resume()
task.receive { result in
    switch result {
        case .success(.data(let data)):
            if let priceChanges = try? JSONDecoder().decode([MenuItem].self, from: data {
                self.applyPriceChanges(priceChanges)
            })
            self.readMessage()
        default:
            self.disconnect()
    }
}
```

## Recap

- Server: NWListener
- Client: URlSessionWebSocketTask
- Transport: Bidirectional WebSocket Messages
- Advantage: less HTTP overhead

## WebSocket APIs

- WebKit: JavaScript WebSocket
- URLSession: URlSessionWebSocketTask
- Network.framework: WebSocket Connection, WebSocket Listener

# Mobility

## WiFi Assist

![](/images/2021-07-25-iOS-Networking/wifi_assist.png#simulator)

- Use high-level APIs like URLSession or Network.framework
- Rethink `SCNetworkReachability`
- Control access with `allowsExpensiveNetworkAccess = false` (request will not go to cellular)

## Multipath Transports

- `multipathServiceType` URLSessionConfiguration and Network.framework
- Server-side configuration: Linux Kernel at <https://multipath-tcp.org>

# Optimize App for 5G

> Because 5G networks typically offer better performance than Wi-Fi, it’s up to you to decide how your app best utilizes network resources — and you no longer need to rely on overall network type (cellular or Wi-Fi) to do so. Instead, you can use [Constrained](https://developer.apple.com/documentation/foundation/urlsessiontasktransactionmetrics/3240628-isconstrained) and [Expensive](https://developer.apple.com/documentation/foundation/urlsessiontasktransactionmetrics/3240635-isexpensive) to describe various network states. Each of these states relies on information from a person’s Data Mode choices (as defined in Settings > Cellular > Cellular Data Options) as well as their cellular plan restrictions.
>
> When using URLRequest, for example, your app can indicate which resource should be retrieved by setting the appropriate value on the `allowsConstrainedNetworkAccess` and `allowsExpensiveNetworkAccess` properties. In contrast, when using NWConnection, your app can access the state of the network through stateUpdateHandler as the `isConstrained` `isExpensive` properties of your connection’s currentPath.
>
> if your app uses `AVFoundation` instead of the Network framework or URLRequest, there are similar keys including `AVURLAssetAllowsConstrainedNetworkAccessKey` and `AVURLAssetAllowsExpensiveNetworkAccessKey`

#### References

- <https://developer.apple.com/videos/play/wwdc2019/712/>
- <https://developer.apple.com/news/?id=z0onzfy5>
