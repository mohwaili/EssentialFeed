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
    
    enum URLSessionHTTPClientError: Error {
        case unknown
    }
    
    private struct UnexpectedValuesRepresentation: Error { }
    
    public func get(from url: URL, completion: @escaping (Result<(Data, HTTPURLResponse), Error>) -> Void) {
        session.dataTask(with: url, completionHandler: { data, response, error in
            if let error = error {
                completion(.failure(error))
            } else {
                guard let data = data,
                      let response = response as? HTTPURLResponse else {
                    return completion(.failure(UnexpectedValuesRepresentation()))
                }
                completion(.success((data, response)))
            }
        }).resume()
    }
    
}
