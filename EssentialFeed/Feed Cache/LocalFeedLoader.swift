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
    
    public func save(_ feed: [FeedImage], completion: @escaping (Error?) -> Void) {
        store.deleteCachedFeed { [weak self] error in
            guard let self = self else { return }
            if let cachedDeletionError = error {
                return completion(cachedDeletionError)
            }
            self.cache(feed, with: completion)
            
        }
    }
    
    public func load(completion: @escaping (Result<[FeedImage], Error>) -> Void) {
        store.retrieve { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case let .found(feed: localFeed, timestamp: timestamp) where self.validate(timestamp):
                completion(.success(localFeed.feed))
            case .found:
                self.store.deleteCachedFeed(completion: { _ in })
                completion(.success([]))
            case .empty:
                completion(.success([]))
            }
        }
    }
    
    public func validateCache() {
        store.retrieve { [unowned self] result in
            switch result {
            case .failure:
                store.deleteCachedFeed { _ in }
            default: break
            }
        }
        
    }
    
    private var maxCacheAgeInDays: Int {
        7
    }
    
    private func cache(_ feed: [FeedImage], with completion: @escaping (Error?) -> Void) {
        self.store.insert(feed.localFeed, timestamp: self.currentDate()) { [weak self] cacheInsertionError in
            guard self != nil else { return }
            completion(cacheInsertionError)
        }
    }
    
    private func validate(_ timestamp: Date) -> Bool {
        let calendar = Calendar(identifier: .gregorian)
        guard let maxCacheAge = calendar.date(byAdding: .day, value: maxCacheAgeInDays, to: timestamp) else {
            return false
        }
        return currentDate() < maxCacheAge
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
