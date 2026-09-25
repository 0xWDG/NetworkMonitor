//
//  NetworkMonitorTests.swift
//  NetworkMonitor
//
//  Created by Wesley de Groot on 2025-01-10.
//  https://wesleydegroot.nl
//
//  https://github.com/0xWDG/SwiftExtras
//  MIT License
//

#if canImport(Testing)
@testable import NetworkMonitor
import Testing

@Test
@MainActor
func initialSnapshotDoesNotAssumeConnectivity() {
    let snapshot = NetworkMonitorObserver.Snapshot()

    #expect(snapshot.isConnected == false)
    #expect(snapshot.isExpensive == false)
    #expect(snapshot.networkType == nil)
    #expect(snapshot.path == nil)
}

@Test
func networkTrafficInterceptionCanBeEnabled() {
    #expect(NetworkMonitor.interceptNetworkTraffic(options: [.host, .path]))
    #expect(NetworkMonitor.LogOptions.all.contains(.httpBody))
}
#endif
