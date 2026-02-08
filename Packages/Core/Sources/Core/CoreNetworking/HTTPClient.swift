//
//  File 2.swift
//  Core
//
//  Created by Ives Murillo on 2/7/26.
//

import Foundation

public protocol HTTPClient: Sendable {
    func send(_ request: HTTPRequest) async throws -> HTTPResponse
}

public final class URLSesionHTTPClient: HTTPClient {

    private let session: URLSession

    public init(session: URLSession = .shared) {
        self.session = session
    }

    public func send(_ request: HTTPRequest) async throws -> HTTPResponse {

        var urlRequest = URLRequest(url: request.url)
        urlRequest.httpMethod = request.method.rawValue
        urlRequest.httpBody = request.body

        if let timeout = request.timeout {
            urlRequest.timeoutInterval = timeout
        }

        request.headers.forEach {
            urlRequest.setValue($1, forHTTPHeaderField: $0)
        }

        do {

            let (data, response) = try await session.data(for: urlRequest)
            guard let http = response as? HTTPURLResponse else {
                throw NetworkError.invalidResponse
            }

            return HTTPResponse(
                statusCode: http.statusCode,
                headers: http.allHeaderFields,
                data: data
            )

        } catch is CancellationError {
            throw NetworkError.cancelled
        } catch let urlError as URLError {
            throw NetworkError.transport(urlError.localizedDescription)
        } catch {
            throw NetworkError.unknown(error.localizedDescription)
        }
    }
}
