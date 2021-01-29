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
        var err: Error? = error
        self.data = data
        if let data = data {
            do {
                self.body = try decoder.decode(T.self, from: data)
            } catch {
                self.body = nil
                err = error
            }
        } else {
            self.body = nil
        }
        self.response = response
        self.error = err
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
