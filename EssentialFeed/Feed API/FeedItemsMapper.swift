//
//  FeedItemsMapper.swift
//  EssentialFeed
//
//  Created by Mohammed Al Waili on 06/02/2021.
//

import Foundation

internal final class FeedItemsMapper {
    
    private struct Root: Decodable {
        let items: [Item]
        
        var feed: [FeedItem] {
            items.map { $0.feedItem }
        }
    }

    private struct Item: Decodable {
        let id: UUID
        let description: String?
        let location: String?
        let image: URL
        
        var feedItem: FeedItem {
            FeedItem(id: id,
                     description: description,
                     location: location,
                     imageURL: image)
        }
    }
    
    private static let OK_200: Int = 200
    
    internal static func map(_ data: Data, response: HTTPURLResponse) -> Result<[FeedItem], RemoteFeedLoader.Error> {
        guard response.statusCode == OK_200,
              let root = try? JSONDecoder().decode(Root.self, from: data) else {
            return .failure(RemoteFeedLoader.Error.invalidData)
        }
        return .success(root.feed)
    }
}
