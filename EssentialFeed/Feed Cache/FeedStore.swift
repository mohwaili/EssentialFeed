//
//  FeedStore.swift
//  EssentialFeed
//
//  Created by Mohammed Alwaili on 13/02/2021.
//

import Foundation

public protocol FeedStore {
    typealias DeletionCompletion = (Error?) -> Void
    typealias InsertionCompletion = (Error?) -> Void
    typealias RetrievalCompletion = (Result<[LocalFeedImage], Error>) -> Void

    func deleteCachedFeed(completion: @escaping DeletionCompletion)
    func insert(_ feed: [LocalFeedImage],
                timestamp: Date,
                completion: @escaping InsertionCompletion)
    func retrieve(completion: @escaping RetrievalCompletion)
}
