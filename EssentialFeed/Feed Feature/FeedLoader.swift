//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Mohammed Al Waili on 03/02/2021.
//

import Foundation

public struct FeedItem: Equatable {
    public let id: UUID
    public let description: String?
    public let location: String?
    public let imageURL: URL
    
    public init(id: UUID, description: String?, location: String?, imageURL: URL) {
        self.id = id
        self.description = description
        self.location = location
        self.imageURL = imageURL
    }
    
    public static func ==(lhs: FeedItem, rhs: FeedItem) -> Bool {
        lhs.id == rhs.id
    }
}

public protocol FeedLoader {
    func retrieveFeed(completion: @escaping (Result<FeedItem, Error>) -> Void)
}