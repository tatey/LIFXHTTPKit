//
//  HTTPResponse.swift
//  LIFXHTTPKit-iOS
//
//  Created by Megan Efron on 3/10/18.
//

import Foundation

private let decoder = JSONDecoder()

struct HTTPResponse<T: Decodable> {
    
    let body: T?
    let response: URLResponse?
    let error: Error?
    
    init(data: Data?, response: URLResponse?, error: Error?) {
        if let data = data {
            self.body = try? decoder.decode(T.self, from: data)
        } else {
            self.body = nil
        }
        self.response = response
        self.error = error
    }
}

struct EmptyResponse: Decodable { }
