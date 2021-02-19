//
//  LocalFeedLoader.swift
//  EssentialFeed
//
//  Created by Mohammed Alwaili on 13/02/2021.
//

import Foundation

private final class FeedCachePolicy {
    
    private let currentDate: () -> Date
    private let calendar: Calendar = Calendar(identifier: .gregorian)
    
    public init(currentDate: @escaping @autoclosure () -> Date) {
        self.currentDate = currentDate
    }
    
    private var maxCacheAgeInDays: Int {
        7
    }
    
    func validate(_ timestamp: Date) -> Bool {
        guard let maxCacheAge = calendar.date(byAdding: .day, value: maxCacheAgeInDays, to: timestamp) else {
            return false
        }
        return currentDate() < maxCacheAge
    }
}

public final class LocalFeedLoader: FeedLoader {
    
    private let store: FeedStore
    private let currentDate: () -> Date
    private let cachePolicy: FeedCachePolicy
    
    public init(store: FeedStore, currentDate: @escaping @autoclosure () -> Date) {
        self.store = store
        self.currentDate = currentDate
        self.cachePolicy = FeedCachePolicy(currentDate: currentDate())
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
            case let .found(feed: localFeed, timestamp: timestamp) where self.cachePolicy.validate(timestamp):
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
            case let .found(_, timestamp) where !self.cachePolicy.validate(timestamp):
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
