//
//  HTTPRequest.swift
//  LIFXHTTPKit
//
//  Created by Megan Efron on 3/10/18.
//

import Foundation

private let encoder = JSONEncoder()

public struct HTTPRequest<T: Encodable> {
    
    public enum Method: String {
        case get = "GET"
        case put = "PUT"
    }
    
    let baseURL: URL
    let path: String?
    let method: Method
    let headers: [String: String]?
    let body: T?
    let expectedStatusCodes: [Int]
    
    init(baseURL: URL, path: String?, method: Method = .get, headers: [String: String]? = nil, body: T? = nil, expectedStatusCodes: [Int] = [200]) {
        self.baseURL = baseURL
        self.path = path
        self.method = method
        self.headers = headers
        self.body = body
        self.expectedStatusCodes = expectedStatusCodes
    }
    
    func toURLRequest() -> URLRequest {
        var url = baseURL
        if let path = path {
            url.appendPathComponent(path)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        
        // Add headers
        headers?.forEach({ (key, value) in
            request.addValue(value, forHTTPHeaderField: key)
        })
        
        // Add body if applicable
        if let body = body {
            request.httpBody = try? encoder.encode(body)
        }
        
        return request
    }
}

struct EmptyRequest: Encodable { }
