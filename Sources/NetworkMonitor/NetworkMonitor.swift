//
//  NetworkMonitor.swift
//  NetworkMonitor
//
//  Created by Wesley de Groot on 2025-01-23.
//  https://wesleydegroot.nl
//
//  https://github.com/0xWDG/SwiftExtras
//  MIT License
//

#if canImport(Combine) && canImport(Network)
import Combine
import Network

/// NetworkMonitor wraps NWPathMonitor into an Obervable object.
public final class NetworkMonitor: ObservableObject {
    /// This will be used to track the network connectivity
    @Published
    public var isConnected = true

    /// This will be used to track if the network is expensive (e.g. cellular data)
    @Published
    public var isExpensive = false

    /// Types of network interfaces, based on their link layer media types.
    @Published
    var networkType: NWInterface.InterfaceType? = .other

    // This will be used to track the network path (e.g. Wi-Fi, cellular data, etc.)
    /// An object that contains information about the properties of the network that a connection uses,
    /// or that are available to your app.
    @Published
    public var nwPath: NWPath?

    // Create an instance of NWPathMonitor
    let monitor = NWPathMonitor()

    /// NetworkMonitor wraps NWPathMonitor into an Obervable object.
    public init() {
        // Set the pathUpdateHandler
        monitor.pathUpdateHandler = { [weak self] path in

            // Check if the device is connected to the internet
            self?.isConnected = path.status == .satisfied

            // Check if the network is expensive (e.g. cellular data)
            self?.isExpensive = path.isExpensive

            // Check which interface we are currently using
            self?.networkType = path.availableInterfaces.first?.type

            // Update the network path
            self?.nwPath = path
        }

        // Create a queue for the monitor
        let queue = DispatchQueue(label: "Monitor")

        // Start monitoring
        monitor.start(queue: queue)
    }

    deinit {
        // Stop monitoring
        monitor.cancel()
    }
}
#endif
