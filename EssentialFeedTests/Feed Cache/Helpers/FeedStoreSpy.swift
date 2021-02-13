//
//  FeedStoreSpy.swift
//  EssentialFeedTests
//
//  Created by Mohammed Alwaili on 13/02/2021.
//

import Foundation
import EssentialFeed

class FeedStoreSpy: FeedStore {
    typealias OperationCompletion = (Error?) -> Void
        
    enum ReceivedMessage: Equatable {
        case deleteCacheFeed
        case insert(feed: [LocalFeedImage], timestamp: Date)
    }
    private(set) var receivedMessages = [ReceivedMessage]()
    
    private var deletionCompletions: [OperationCompletion] = []
    private var insertionCompletions: [OperationCompletion] = []
    func deleteCachedFeed(completion: @escaping OperationCompletion) {
        deletionCompletions.append(completion)
        receivedMessages.append(.deleteCacheFeed)
    }
    
    func completeDeletion(with error: Error, at index: Int = 0) {
        deletionCompletions[index](error)
    }
    
    func completeDeletionSuccessfully(at index: Int = 0) {
        deletionCompletions[index](nil)
    }
    
    func completeInsertion(with insertionError: Error, at index: Int = 0) {
        insertionCompletions[index](insertionError)
    }
    
    func completeInsertionSuccessfully(at index: Int = 0) {
        insertionCompletions[index](nil)
    }
    
    func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping OperationCompletion) {
        receivedMessages.append(.insert(feed: feed, timestamp: timestamp))
        insertionCompletions.append(completion)
    }
    
}
