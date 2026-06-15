# NetworkMonitor

NetworkMonitor wraps `NWPathMonitor` into an observable object.

[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2F0xWDG%2FNetworkMonitor%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/0xWDG/NetworkMonitor)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2F0xWDG%2FNetworkMonitor%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/0xWDG/NetworkMonitor)
[![Swift Package Manager](https://img.shields.io/badge/SPM-compatible-brightgreen.svg)](https://swift.org/package-manager)
![License](https://img.shields.io/github/license/0xWDG/NetworkMonitor)

## Requirements

- Swift 5.8+
- iOS 13.0+, iPadOS 13.0+, macOS 11.0+, tvOS 13.0+, visionOS 1.0+, watchOS 7.0+

## Installation (Package.swift)

```swift
dependencies: [
    .package(url: "https://github.com/0xWDG/NetworkMonitor.git", branch: "main"),
],
targets: [
    .target(name: "MyTarget", dependencies: [
        .product(name: "NetworkMonitor", package: "NetworkMonitor"),
    ]),
]
```

## Installation (Xcode)

1. In Xcode, open your project and navigate to **File** → **Swift Packages** → **Add Package Dependency...**
2. Paste the repository URL (`https://github.com/0xWDG/NetworkMonitor`) and click **Next**.
3. Click **Finish**.

## Usage

```swift
import SwiftUI
import NetworkMonitor

struct ContentView: View {
    @StateObject
    private var network = NetworkMonitor()

    var body: some View {
        VStack {
            Text("Hello!")
            Text("The network status is \(network.isConnected ? "Connected" : "Disconnected")")
            Text("You are using a \"\(network.isExpensive ? "Expensive" : "Normal")\" internet connection")

            HStack(spacing: 0) {
                Text("You are using \"")
                switch (network.networkType) {
                case .cellular:
                    Text("Cellular")
                case .wifi:
                    Text("Wi-Fi")
                case .loopback:
                    Text("Loopback")
                case .other:
                    Text("Other")
                case .wiredEthernet:
                    Text("Wired")
                default:
                    Text("Unknown")
                }
                Text("\" to connect to the internet")
            }
        }
    }
}
```

## Contact

🦋 [@0xWDG](https://bsky.app/profile/0xWDG.bsky.social)
🐘 [mastodon.social/@0xWDG](https://mastodon.social/@0xWDG)
🐦 [@0xWDG](https://x.com/0xWDG)
🧵 [@0xWDG](https://www.threads.net/@0xWDG)
🌐 [wesleydegroot.nl](https://wesleydegroot.nl)
🤖 [Discord](https://discordapp.com/users/918438083861573692)

Interested learning more about Swift? [Check out my blog](https://wesleydegroot.nl/blog/).
