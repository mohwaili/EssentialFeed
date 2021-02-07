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
            && lhs.description == rhs.description
            && lhs.location == rhs.location
            && lhs.imageURL == rhs.imageURL
    }
}

public protocol FeedLoader {
    func load(completion: @escaping (Result<[FeedItem], Swift.Error>) -> Void)
}
