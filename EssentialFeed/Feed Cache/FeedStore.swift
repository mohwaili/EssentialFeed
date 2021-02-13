//
//  FeedStore.swift
//  EssentialFeed
//
//  Created by Mohammed Alwaili on 13/02/2021.
//

import Foundation

public protocol FeedStore {
    typealias OperationCompletion = (Error?) -> Void

    func deleteCachedFeed(completion: @escaping OperationCompletion)
    func insert(_ items: [LocalFeedItem], timestamp: Date, completion: @escaping OperationCompletion)
}
