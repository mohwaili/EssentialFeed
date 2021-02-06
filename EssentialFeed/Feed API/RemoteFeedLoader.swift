//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Mohammed Al Waili on 05/02/2021.
//

import Foundation

public protocol HTTPClient {
    func get(from url: URL, completion: @escaping (Result<(Data, HTTPURLResponse), Error>) -> Void)
}

public final class RemoteFeedLoader {
    
    private let url: URL
    private let client: HTTPClient
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    public func load(completion: @escaping (Result<[FeedItem], Error>) -> Void) {
        client.get(from: url, completion: { result in
            switch result {
            case .failure:
                completion(.failure(.connectivity))
            case .success((let data, let response)):
                if response.statusCode != 200 {
                    return completion(.failure(.invalidData))
                }
                guard let json = try? JSONSerialization.jsonObject(with: data) else {
                    return completion(.failure(.invalidData))
                }
                completion(.success([]))
            }
        })
    }
    
}
