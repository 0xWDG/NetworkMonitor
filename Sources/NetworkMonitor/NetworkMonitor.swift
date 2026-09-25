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

#if canImport(Foundation) && canImport(os)
import Foundation
import os

/// Intercepts HTTP and HTTPS requests made through the URL loading system.
public enum NetworkMonitor {
    /// The network-traffic fields that NetworkMonitor writes to OSLog.
    public struct LogOptions: OptionSet, Sendable {
        /// The raw value that stores the selected options.
        public let rawValue: UInt

        /// Logs the request method and complete URL.
        public static let request = Self(rawValue: 1 << 0)

        /// Logs the response status code, duration, and failures.
        public static let response = Self(rawValue: 1 << 1)

        /// Logs the request host.
        public static let host = Self(rawValue: 1 << 2)

        /// Logs the request path and query string.
        public static let path = Self(rawValue: 1 << 3)

        /// Logs request and response HTTP bodies as UTF-8 text or Base64 data.
        public static let httpBody = Self(rawValue: 1 << 4)

        /// Logs request and response HTTP headers.
        public static let headers = Self(rawValue: 1 << 5)

        /// Logs request Cookie headers and response Set-Cookie values.
        public static let cookies = Self(rawValue: 1 << 6)

        /// Logs the request and response summaries without potentially sensitive content.
        public static let `default`: Self = [.request, .response]

        /// Logs every supported traffic field.
        public static let all: Self = [.request, .response, .host, .path, .httpBody, .headers, .cookies]

        /// Creates a set of network-traffic logging options.
        public init(rawValue: UInt) {
            self.rawValue = rawValue
        }
    }

    /// The OSLog used when no custom log is supplied.
    public static let defaultLog = OSLog(
        subsystem: "nl.wesleydegroot.NetworkMonitor",
        category: "NetworkTraffic"
    )

    private static let stateLock = NSLock()
    private static var log = defaultLog
    private static var logOptions: LogOptions = .default
    private static var isRegistered = false

    /// Registers NetworkMonitor's URL protocol and logs network traffic.
    ///
    /// Call this before creating URL sessions. Use ``LogOptions`` to select the fields that are
    /// included in each entry. Headers, cookies, and HTTP bodies can contain sensitive data.
    ///
    /// - Parameter log: The OSLog that receives traffic entries. When `nil`, the log uses the
    ///   `nl.wesleydegroot.NetworkMonitor` subsystem.
    /// - Parameter options: The request and response fields to log. The default logs summaries
    ///   only; use ``LogOptions/all`` to include every supported field.
    /// - Returns: `true` when the interceptor is registered or was already registered.
    @discardableResult
    public static func interceptNetworkTraffic(
        log: OSLog? = nil,
        options: LogOptions = .default
    ) -> Bool {
        stateLock.lock()
        defer { stateLock.unlock() }

        self.log = log ?? defaultLog
        self.logOptions = options

        guard isRegistered == false else {
            return true
        }

        isRegistered = URLProtocol.registerClass(NetworkTrafficURLProtocol.self)
        return isRegistered
    }

    fileprivate static func writeLog(_ message: String, type: OSLogType = .info) {
        stateLock.lock()
        let log = self.log
        stateLock.unlock()

        os_log("%{public}@", log: log, type: type, message)
    }

    fileprivate static func selectedLogOptions() -> LogOptions {
        stateLock.lock()
        defer { stateLock.unlock() }
        return logOptions
    }
}

private class NetworkTrafficURLProtocol: URLProtocol {
    private static let handledRequestKey = "nl.wesleydegroot.NetworkMonitor.handled"

    private var loadingTask: URLSessionDataTask?
    private var startedAt: Date?

    override class func canInit(with request: URLRequest) -> Bool {
        guard let scheme = request.url?.scheme?.lowercased(), scheme == "http" || scheme == "https" else {
            return false
        }

        return URLProtocol.property(forKey: handledRequestKey, in: request) == nil
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override func startLoading() {
        guard let mutableRequest = (request as NSURLRequest).mutableCopy() as? NSMutableURLRequest else {
            client?.urlProtocol(self, didFailWithError: URLError(.badURL))
            return
        }

        URLProtocol.setProperty(true, forKey: Self.handledRequestKey, in: mutableRequest)
        let request = mutableRequest as URLRequest
        let method = request.httpMethod ?? "GET"
        let url = request.url?.absoluteString ?? "<unknown URL>"
        let options = NetworkMonitor.selectedLogOptions()
        startedAt = Date()

        NetworkMonitor.writeLog(requestLogMessage(for: request, options: options))

        loadingTask = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self else {
                return
            }

            let duration = Date().timeIntervalSince(self.startedAt ?? Date())

            if let error {
                if options.contains(.response) {
                    NetworkMonitor.writeLog(
                        "Network request failed: \(method) \(url) (\(error.localizedDescription)) in \(duration) s",
                        type: .error
                    )
                }
                self.client?.urlProtocol(self, didFailWithError: error)
                return
            }

            if let response {
                self.client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
            if let data {
                self.client?.urlProtocol(self, didLoad: data)
            }

            if let message = responseLogMessage(response, data: data, duration: duration, options: options) {
                NetworkMonitor.writeLog(message)
            }
            self.client?.urlProtocolDidFinishLoading(self)
        }
        loadingTask?.resume()
    }

    override func stopLoading() {
        loadingTask?.cancel()
        loadingTask = nil
    }

    private func requestLogMessage(for request: URLRequest, options: NetworkMonitor.LogOptions) -> String {
        var fields = [String]()
        let method = request.httpMethod ?? "GET"

        if options.contains(.request) {
            fields.append("request=\(method) \(request.url?.absoluteString ?? "<unknown URL>")")
        }
        if options.contains(.host) {
            fields.append("host=\(request.url?.host ?? "<unknown host>")")
        }
        if options.contains(.path) {
            let path = request.url.map { url in
                url.path + (url.query.map { "?\($0)" } ?? "")
            } ?? "<unknown path>"
            fields.append("path=\(path)")
        }
        if options.contains(.httpBody) {
            fields.append("requestBody=\(bodyDescription(request.httpBody))")
        }
        if options.contains(.headers) {
            fields.append("requestHeaders=\(request.allHTTPHeaderFields ?? [:])")
        }
        if options.contains(.cookies) {
            fields.append("requestCookies=\(request.value(forHTTPHeaderField: "Cookie") ?? "<none>")")
        }

        return fields.isEmpty ? "Network request started" : "Network request started: \(fields.joined(separator: ", "))"
    }

    private func responseLogMessage(
        _ response: URLResponse?,
        data: Data?,
        duration: TimeInterval,
        options: NetworkMonitor.LogOptions
    ) -> String? {
        var fields = [String]()

        if options.contains(.response) {
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
            fields.append("response=\(statusCode) duration=\(duration)s")
        }
        if options.contains(.httpBody) {
            fields.append("responseBody=\(bodyDescription(data))")
        }
        if options.contains(.headers), let response = response as? HTTPURLResponse {
            fields.append("responseHeaders=\(response.allHeaderFields)")
        }
        if options.contains(.cookies), let response = response as? HTTPURLResponse {
            let headerFields = response.allHeaderFields.reduce(into: [String: String]()) { result, item in
                result[String(describing: item.key)] = String(describing: item.value)
            }
            if let url = response.url ?? request.url {
                let cookies = HTTPCookie.cookies(withResponseHeaderFields: headerFields, for: url)
                fields.append("responseCookies=\(cookies.map { "\($0.name)=\($0.value)" })")
            } else {
                fields.append("responseCookies=<unavailable>")
            }
        }

        return fields.isEmpty ? nil : "Network request completed: \(fields.joined(separator: ", "))"
    }

    private func bodyDescription(_ body: Data?) -> String {
        guard let body else {
            return "<none>"
        }

        return String(data: body, encoding: .utf8) ?? body.base64EncodedString()
    }
}
#endif
