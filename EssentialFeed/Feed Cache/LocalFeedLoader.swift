//
//  LocalFeedLoader.swift
//  EssentialFeed
//
//  Created by Mohammed Alwaili on 13/02/2021.
//

import Foundation

public final class LocalFeedLoader: FeedLoader {
    
    private let store: FeedStore
    private let currentDate: () -> Date
    
    public init(store: FeedStore, currentDate: @escaping @autoclosure () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
    
}

// MARK: - Save
extension LocalFeedLoader {
    
    public typealias SaveResult = Error?
    
    public func save(_ feed: [FeedImage], completion: @escaping (SaveResult) -> Void) {
        store.deleteCachedFeed { [weak self] error in
            guard let self = self else { return }
            if let cachedDeletionError = error {
                return completion(cachedDeletionError)
            }
            self.cache(feed, with: completion)
        }
    }
    
    private func cache(_ feed: [FeedImage], with completion: @escaping (Error?) -> Void) {
        self.store.insert(feed.localFeed, timestamp: self.currentDate()) { [weak self] cacheInsertionError in
            guard self != nil else { return }
            completion(cacheInsertionError)
        }
    }
    
}
 
// MARK: - Load
extension LocalFeedLoader {
    
    public func load(completion: @escaping (Result<[FeedImage], Error>) -> Void) {
        store.retrieve { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case let .found(feed: localFeed, timestamp: timestamp) where FeedCachePolicy.validate(timestamp, against: self.currentDate()):
                completion(.success(localFeed.feed))
            case .found, .empty:
                completion(.success([]))
            }
        }
    }
    
}
    
// MARK: - Validate
extension LocalFeedLoader {
    
    public func validateCache() {
        store.retrieve { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure:
                self.store.deleteCachedFeed { _ in }
            case let .found(_, timestamp) where !FeedCachePolicy.validate(timestamp, against: self.currentDate()):
                self.store.deleteCachedFeed { _ in }
            case .empty, .found: break
            }
        }
    }
    
}

private extension Array where Element == FeedImage {
    
    var localFeed: [LocalFeedImage] {
        self.map { item in
            LocalFeedImage(id: item.id,
                          description: item.description,
                          location: item.location,
                          url: item.url)
        }
    }
    
}

private extension Array where Element == LocalFeedImage {
    
    var feed: [FeedImage] {
        self.map { item in
            FeedImage(id: item.id,
                          description: item.description,
                          location: item.location,
                          url: item.url)
        }
    }
    
}
