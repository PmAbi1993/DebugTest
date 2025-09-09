//
//  Debugger.swift
//  Intercepts URLSession traffic and logs request/response pairs.
//
//  Usage (DEBUG only): Call Debugger.enable() once early in app start.
//

import Foundation
import os

#if DEBUG
import ObjectiveC

public enum Debugger {
    fileprivate static var logFileURL: URL? {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documents.appendingPathComponent("ApiLogs")
    }
    /// Call once early in app lifecycle to enable interception
    public static func enable() {
        Swizzler.performSwizzleOnce()
        if let url = logFileURL {
            if !FileManager.default.fileExists(atPath: url.path) {
                try? "".write(to: url, atomically: true, encoding: .utf8)
            }
            print("Log file URL: \(url)")
        }
    }
}

// MARK: - URLProtocol that relays the request and logs
private final class DebugURLProtocol: URLProtocol {
    private static let handledKey = "DebugURLProtocolHandledKey"
    // IMPORTANT: do NOT name this `task` (URLProtocol already has `var task: URLSessionTask?`)
    private var forwardTask: URLSessionDataTask?

    // Intercept all URLRequests
    override class func canInit(with request: URLRequest) -> Bool {
        // Avoid re-handling requests we already marked
        if URLProtocol.property(forKey: handledKey, in: request) != nil {
            return false
        }
        return true
    }

    // Intercept tasks created via task-based APIs
    override class func canInit(with task: URLSessionTask) -> Bool {
        if let req = task.currentRequest {
            return canInit(with: req)
        }
        return false
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override func startLoading() {
        // Mark as handled to prevent loops
        let mutable = (request as NSURLRequest).mutableCopy() as! NSMutableURLRequest
        URLProtocol.setProperty(true, forKey: Self.handledKey, in: mutable)
        let forwardedRequest = mutable as URLRequest

        // Capture request body (if present) before sending
        let requestBodyString = Self.prettyJSONStringFromRequestBody(forwardedRequest)

        // Use a plain session; our canInit prevents reinjection for this request.
        let session = URLSession(configuration: .default)
        forwardTask = session.dataTask(with: forwardedRequest) { [weak self] data, response, error in
            guard let self = self else { return }

            if let response = response {
                self.client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
            if let data = data {
                self.client?.urlProtocol(self, didLoad: data)
            }
            if let error = error {
                self.client?.urlProtocol(self, didFailWithError: error)
            } else {
                self.client?.urlProtocolDidFinishLoading(self)
            }

            // Prepare log output
            let urlString = forwardedRequest.url?.absoluteString ?? "nil"
            let responseJSON = Self.prettyJSONString(data) ?? (error.map { "\"\($0.localizedDescription)\"" } ?? "null")

            Self.printLog(
                url: urlString,
                requestJSON: requestBodyString ?? "null",
                responseJSON: responseJSON
            )
        }
        forwardTask?.resume()
    }

    override func stopLoading() {
        forwardTask?.cancel()
        forwardTask = nil
    }
}

// MARK: - Swizzling URLSessionConfiguration.protocolClasses to inject our URLProtocol
private enum Swizzler {
    private static var didSwizzle = false
    static func performSwizzleOnce() {
        guard !didSwizzle else { return }
        didSwizzle = true

        let cls: AnyClass = URLSessionConfiguration.self

        // Getter for `protocolClasses` (returns [AnyClass]? )
        let originalSelector = #selector(getter: URLSessionConfiguration.protocolClasses)
        let swizzledSelector = #selector(URLSessionConfiguration.dbg_protocolClasses)

        if let originalMethod = class_getInstanceMethod(cls, originalSelector),
           let swizzledMethod = class_getInstanceMethod(cls, swizzledSelector) {
            method_exchangeImplementations(originalMethod, swizzledMethod)
        }

        // Touch common configs so subsequent copies inherit our protocol
        _ = URLSessionConfiguration.default
        _ = URLSessionConfiguration.ephemeral
    }
}

private extension URLSessionConfiguration {
    // After swizzling, calling dbg_protocolClasses() actually invokes the original implementation.
    // Match the original getter's signature exactly: [AnyClass]? (optional).
    @objc dynamic func dbg_protocolClasses() -> [AnyClass]? {
        var classes = self.dbg_protocolClasses() ?? []
        if classes.first(where: { $0 == DebugURLProtocol.self }) == nil {
            classes.insert(DebugURLProtocol.self, at: 0)
        }
        return classes
    }
}

// MARK: - Helpers
private extension DebugURLProtocol {
    static func prettyJSONStringFromRequestBody(_ request: URLRequest) -> String? {
        // httpBody
        if let body = request.httpBody, !body.isEmpty {
            return prettyJSONString(body) ?? String(data: body, encoding: .utf8) ?? "\"<binary>\""
        }

        // httpBodyStream
        if let stream = request.httpBodyStream {
            stream.open()
            defer { stream.close() }

            let bufferSize = 32_768
            let buff = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)
            defer { buff.deallocate() }

            var data = Data()
            while stream.hasBytesAvailable {
                let read = stream.read(buff, maxLength: bufferSize)
                if read > 0 {
                    data.append(buff, count: read)
                } else {
                    break
                }
            }
            if !data.isEmpty {
                return prettyJSONString(data) ?? String(data: data, encoding: .utf8) ?? "\"<binary>\""
            }
        }

        // No body (e.g., GET)
        return "{}"
    }

    static func prettyJSONString(_ data: Data?) -> String? {
        guard let data, !data.isEmpty else { return nil }
        // Try JSON first
        if let obj = try? JSONSerialization.jsonObject(with: data, options: []),
           (obj is [Any]) || (obj is [String: Any]) {
            if #available(iOS 13.0, macOS 10.15, *) {
                let pretty = try? JSONSerialization.data(withJSONObject: obj, options: [.prettyPrinted, .fragmentsAllowed, .sortedKeys])
                if let pretty, let str = String(data: pretty, encoding: .utf8) { return str }
            } else {
                let pretty = try? JSONSerialization.data(withJSONObject: obj, options: [.prettyPrinted])
                if let pretty, let str = String(data: pretty, encoding: .utf8) { return str }
            }
        }
        // Fall back to UTF-8 text
        if let str = String(data: data, encoding: .utf8) { return str }
        // Binary
        return "\"<\(data.count) bytes binary>\""
    }

    static func printLog(url: String, requestJSON: String, responseJSON: String) {
        let log = """
        ------------------------------
        URL: \(url)
        Request: \(requestJSON)
        Response: \(responseJSON)
        ------------------------------
        """
        // Append to file
        if let fileURL = Debugger.logFileURL, let data = log.data(using: .utf8) {
            do {
                let fileHandle = try FileHandle(forWritingTo: fileURL)
                fileHandle.seekToEndOfFile()
                fileHandle.write(data)
                fileHandle.closeFile()
            } catch {
                // Handle error if needed
            }
        }
        // Use OSLog
        let logger = Logger(subsystem: "DebugTest", category: "API")
        logger.info("\(log, privacy: .public)")
    }
}
#endif
