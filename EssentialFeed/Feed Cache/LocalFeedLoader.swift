//
//  LocalFeedLoader.swift
//  EssentialFeed
//
//  Created by Mohammed Alwaili on 13/02/2021.
//

import Foundation

public final class LocalFeedLoader {
    
    public typealias SaveResult = Error?
    
    private let store: FeedStore
    private let currentDate: () -> Date
    
    public init(store: FeedStore, currentDate: @escaping @autoclosure () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
    
    public func save(_ items: [FeedItem], completion: @escaping (Error?) -> Void) {
        store.deleteCachedFeed { [weak self] error in
            guard let self = self else { return }
            if let cachedDeletionError = error {
                return completion(cachedDeletionError)
            }
            self.cache(items, with: completion)
            
        }
    }
    
    private func cache(_ items: [FeedItem], with completion: @escaping (Error?) -> Void) {
        self.store.insert(items.localFeedItems, timestamp: self.currentDate()) { [weak self] cacheInsertionError in
            guard self != nil else { return }
            completion(cacheInsertionError)
        }
    }
    
}

private extension Array where Element == FeedItem {
    
    var localFeedItems: [LocalFeedImage] {
        self.map { item in
            LocalFeedImage(id: item.id,
                          description: item.description,
                          location: item.location,
                          imageURL: item.imageURL)
        }
    }
    
}
