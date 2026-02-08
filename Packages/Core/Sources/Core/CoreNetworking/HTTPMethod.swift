//
//  File.swift
//  Core
//
//  Created by Ives Murillo on 2/7/26.
//

import Foundation

enum HTTPMethod: String, Sendable {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}
