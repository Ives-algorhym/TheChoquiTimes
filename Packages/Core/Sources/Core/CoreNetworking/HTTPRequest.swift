//
//  File.swift
//  Core
//
//  Created by Ives Murillo on 2/7/26.
//

import Foundation

import Foundation

public struct HTTPRequest: Sendable {

    public let url: URL
    public let method: HTTPMethod
    public let headers: [String: String]
    public let body: Data?
    public let timeout: TimeInterval?

    public init(
        url: URL,
        method: HTTPMethod,
        headers: [String: String] = [:],
        body: Data? = nil,
        timeout: TimeInterval? = nil
    ) {
        self.url = url
        self.method = method
        self.headers = headers
        self.body = body
        self.timeout = timeout
    }
}

public extension HTTPRequest {

    func addingHeader(_ key: String, value: String) -> HTTPRequest {
        var newHeaders = headers
        newHeaders[key] = value

        return HTTPRequest(
            url: url,
            method: method,
            headers: newHeaders,
            body: body,
            timeout: timeout
        )
    }

    func addingHeaders(_ headers: [String: String]) -> HTTPRequest {
        let merged = self.headers.merging(headers) { _, new in new }

        return HTTPRequest(
            url: url,
            method: method,
            headers: merged,
            body: body,
            timeout: timeout
        )
    }

    func withBody(_ body: Data?) -> HTTPRequest {
        HTTPRequest(
            url: url,
            method: method,
            headers: headers,
            body: body,
            timeout: timeout
        )
    }

    func withTimeout(_ timeout: TimeInterval) -> HTTPRequest {
        HTTPRequest(
            url: url,
            method: method,
            headers: headers,
            body: body,
            timeout: timeout
        )
    }
}

// this extension goes on real implementation
//extension HTTPRequest {
//
//    func buildURLRequest() -> URLRequest {
//        var request = URLRequest(url: url)
//        request.httpMethod = method.rawValue
//        request.httpBody = body
//
//        headers.forEach {
//            request.setValue($1, forHTTPHeaderField: $0)
//        }
//
//        if let timeout {
//            request.timeoutInterval = timeout
//        }
//
//        return request
//    }
//}
