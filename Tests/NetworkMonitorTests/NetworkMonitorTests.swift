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
import Testing
@testable import NetworkMonitor

@Test
@MainActor
func initialSnapshotDoesNotAssumeConnectivity() {
    let snapshot = NetworkMonitor.Snapshot()

    #expect(snapshot.isConnected == false)
    #expect(snapshot.isExpensive == false)
    #expect(snapshot.networkType == nil)
    #expect(snapshot.path == nil)
}
#endif
