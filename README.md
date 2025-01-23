# NetworkMonitor

NetworkMonitor wraps NWPathMonitor into an Obervable object.

[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2F0xWDG%2FNetworkMonitor%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/0xWDG/NetworkMonitor)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2F0xWDG%2FNetworkMonitor%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/0xWDG/NetworkMonitor)
[![Swift Package Manager](https://img.shields.io/badge/SPM-compatible-brightgreen.svg)](https://swift.org/package-manager)
![License](https://img.shields.io/github/license/0xWDG/NetworkMonitor)

## Requirements

- Swift 5.9+ (Xcode 15+)
- iOS 12.0+, iPadOS 12.0+, macOS 10.15+, tvOS 12.0+, visionOS 1.0+, watchOS 6.0+,

## Installation (Pakage.swift)

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
    @ObservedObject
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
                    Text("Celluar")
                case .wifi:
                    Text("Wifi")
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
        }.task {
            print(network.nwPath)
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
