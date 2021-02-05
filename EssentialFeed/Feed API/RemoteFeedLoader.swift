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
    
    public func load(completion: @escaping (Error) -> Void) {
        client.get(from: url, completion: { result in
            switch result {
            case .failure:
                completion(.connectivity)
            case .success((let data, let response)):
                if response.statusCode != 200 {
                    return completion(.invalidData)
                }
                guard let object = try? JSONDecoder().decode([FeedItem].self, from: data) else {
                    return completion(.invalidData)
                }
            }
        })
    }
    
}
