//
//  URLSessionHTTPClient.swift
//  EssentialFeed
//
//  Created by Mohammed Al Waili on 07/02/2021.
//

import Foundation

public class URLSessionHTTPClient: HTTPClient {
    
    private let session: URLSession
    
    public init(session: URLSession = .shared) {
        self.session = session
    }
    
    private struct UnexpectedValuesRepresentation: Error { }
    
    public func test() -> Result<String, Error> {
        Result {
            throw UnexpectedValuesRepresentation()
        }
    }
    
    public func get(from url: URL, completion: @escaping (Result<(Data, HTTPURLResponse), Error>) -> Void) {
        session.dataTask(with: url, completionHandler: { data, response, error in
            completion(Result {
                if let error = error {
                    throw error
                } else if let data = data, let response = response as? HTTPURLResponse {
                    return (data, response)
                } else {
                    throw UnexpectedValuesRepresentation()
                }
            })
        }).resume()
    }
    
}
