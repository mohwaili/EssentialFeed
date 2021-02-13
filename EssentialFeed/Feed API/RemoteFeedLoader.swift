//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Mohammed Al Waili on 05/02/2021.
//

import Foundation

public final class RemoteFeedLoader: FeedLoader {
  
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
    
    public func load(completion: @escaping (Result<[FeedItem], Swift.Error>) -> Void) {
        client.get(from: url, completion: { [weak self] result in
            guard self != nil else { return }
            switch result {
            case .failure:
                completion(.failure(Error.connectivity))
            case .success((let data, let response)):
                do {
                    let remoteItems = try FeedItemsMapper.map(data, response: response)
                    completion(.success(remoteItems.feedItems))
                } catch {
                    completion(.failure(error))
                }
            }
        })
    }
    
}

private extension Array where Element == RemoteFeedItem {
    
    var feedItems: [FeedItem] {
        self.map {
            FeedItem(id: $0.id,
                     description: $0.description,
                     location: $0.location,
                     imageURL: $0.image)
        }
    }
    
}
