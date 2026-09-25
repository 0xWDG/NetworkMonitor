//
//  NetworkMonitorObserver.swift
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
import Dispatch
import Network

/// Legacy observable wrapper around `NWPathMonitor` for network-path state.
///
/// Use ``NetworkMonitor/interceptNetworkTraffic(log:)`` to log HTTP and HTTPS traffic.
@MainActor
public final class NetworkMonitorObserver: ObservableObject {
    /// An immutable representation of the latest network path.
    public struct Snapshot {
        /// Whether the latest path can satisfy network connections.
        public let isConnected: Bool

        /// Whether the latest path is considered expensive.
        public let isExpensive: Bool

        /// The preferred interface type used by the latest path.
        public let networkType: NWInterface.InterfaceType?

        /// The latest path reported by `NWPathMonitor`.
        public let path: NWPath?

        init(path: NWPath? = nil) {
            self.path = path
            self.isConnected = path?.status == .satisfied
            self.isExpensive = path?.isExpensive ?? false
            self.networkType = Self.preferredInterfaceType(for: path)
        }

        private static func preferredInterfaceType(for path: NWPath?) -> NWInterface.InterfaceType? {
            let preferredTypes: [NWInterface.InterfaceType] = [
                .wifi,
                .wiredEthernet,
                .cellular,
                .loopback,
                .other
            ]

            return preferredTypes.first { path?.usesInterfaceType($0) == true }
        }
    }

    /// The latest network state. A path update causes one publication.
    @Published
    public private(set) var snapshot = Snapshot()

    /// Whether the latest path can satisfy network connections.
    public var isConnected: Bool { snapshot.isConnected }

    /// Whether the latest path is considered expensive.
    public var isExpensive: Bool { snapshot.isExpensive }

    /// The preferred interface type used by the latest path.
    public var networkType: NWInterface.InterfaceType? { snapshot.networkType }

    /// The latest path reported by `NWPathMonitor`.
    public var nwPath: NWPath? { snapshot.path }

    private let monitor: NWPathMonitor
    private let monitorQueue: DispatchQueue

    /// Creates and starts a network path monitor.
    public convenience init() {
        self.init(monitor: NWPathMonitor())
    }

    init(
        monitor: NWPathMonitor,
        queue: DispatchQueue = DispatchQueue(label: "NetworkMonitor.path-updates")
    ) {
        self.monitor = monitor
        self.monitorQueue = queue

        monitor.pathUpdateHandler = { [weak self] path in
            Task { @MainActor [weak self] in
                self?.snapshot = Snapshot(path: path)
            }
        }
        monitor.start(queue: queue)
    }

    deinit {
        monitor.pathUpdateHandler = nil
        monitor.cancel()
    }
}
#endif
