//
//  FeedStoreSpy.swift
//  EssentialFeedTests
//
//  Created by Mohammed Alwaili on 13/02/2021.
//

import Foundation
import EssentialFeed

class FeedStoreSpy: FeedStore {
    
    enum ReceivedMessage: Equatable {
        case deleteCacheFeed
        case insert(feed: [LocalFeedImage], timestamp: Date)
        case retrieve
    }
    private(set) var receivedMessages = [ReceivedMessage]()
    
    // MARK: - Deletion
    
    private var deletionCompletions: [DeletionCompletion] = []
    
    func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        deletionCompletions.append(completion)
        receivedMessages.append(.deleteCacheFeed)
    }
    
    func completeDeletion(with error: Error, at index: Int = 0) {
        deletionCompletions[index](error)
    }
    
    func completeDeletionSuccessfully(at index: Int = 0) {
        deletionCompletions[index](nil)
    }
    
    // MARK: Insertion -
    
    private var insertionCompletions: [InsertionCompletion] = []
    
    func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        receivedMessages.append(.insert(feed: feed, timestamp: timestamp))
        insertionCompletions.append(completion)
    }
    
    func completeInsertion(with insertionError: Error, at index: Int = 0) {
        insertionCompletions[index](insertionError)
    }
    
    func completeInsertionSuccessfully(at index: Int = 0) {
        insertionCompletions[index](nil)
    }
    
    // MARK: - Retrieving
    
    private var retrievalCompletions: [RetrievalCompletion] = []
    
    func retrieve(completion: @escaping RetrievalCompletion) {
        receivedMessages.append(.retrieve)
        retrievalCompletions.append(completion)
    }
    
    func completeRetrieval(with error: Error, at index: Int = 0) {
        retrievalCompletions[index](.failure(error))
    }
    
    func completeRetrieval(with localFeedImages: [LocalFeedImage], at index: Int = 0) {
        retrievalCompletions[index](.success(localFeedImages))
    }
    
}
