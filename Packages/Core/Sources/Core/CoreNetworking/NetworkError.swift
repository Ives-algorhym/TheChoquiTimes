//
//  File.swift
//  Core
//
//  Created by Ives Murillo on 2/7/26.
//

import Foundation

public enum NetworkError: Error, Sendable, Equatable {
    case invalidResponse
    case unnaceptableStatusCode(Int)
    case transport(String)
    case cancelled
    case unknown(String)
}
