//
//  HTTPResponse.swift
//  LIFXHTTPKit-iOS
//
//  Created by Megan Efron on 3/10/18.
//

import Foundation

private let decoder = JSONDecoder()

struct HTTPResponse<T: Decodable>: CustomStringConvertible {
    
    let data: Data?
    let body: T?
    let response: URLResponse?
    let error: Error?
    
    init(data: Data?, response: URLResponse?, error: Error?) {
        self.data = data
        if let data = data {
            self.body = try? decoder.decode(T.self, from: data)
        } else {
            self.body = nil
        }
        self.response = response
        self.error = error
    }
    
    var description: String {
        var description: String = "RESPONSE '\(response?.url?.path ?? "Unknown URL")'"
        
        if let error = error {
            description += "\nError:\n\(error)"
        } else if let data = data, let json = try? JSONSerialization.jsonObject(with: data, options: []) {
            description += "\nBody:\n\(json)"
        } else if let body = body {
            description += "\nBody:\n\(body)"
        } else {
            description += "\nNo message"
        }
        
        return description
    }
}

struct EmptyResponse: Decodable { }
