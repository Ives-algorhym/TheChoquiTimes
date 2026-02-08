//
//  File.swift
//  Core
//
//  Created by Ives Murillo on 2/7/26.
//

import Foundation

public struct HTTPResponse {
    public let statusCode: Int
    public let headers: [AnyHashable:  Any]
    public let data: Data

    public init(statusCode: Int, headers: [AnyHashable: Any], data: Data) {
        self.statusCode = statusCode
        self.headers = headers
        self.data = data
    }
}
