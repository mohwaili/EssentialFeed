//
//  CacheFeedUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Mohammed Alwaili on 12/02/2021.
//

import XCTest
import EssentialFeed

class CacheFeedUseCaseTests: XCTestCase {
    
    func test_init_doesNotMessageStoreUponCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.receivedMessages, [])
    }
    
    func test_save_requestACacheDeletion() {
        let (sut, store) = makeSUT()
        
        sut.save(uniqueImageFeed().models) { _ in }
        
        XCTAssertEqual(store.receivedMessages, [.deleteCacheFeed])
    }
    
    func test_save_doesNotRequestCacheInsertionOnDeletionError() {
        let (sut, store) = makeSUT()
        
        sut.save(uniqueImageFeed().models) { _ in }
        let deletionError = anyNSError()
        store.completeDeletion(with: deletionError)
        
        XCTAssertEqual(store.receivedMessages, [.deleteCacheFeed])
    }
    
    func test_save_requestsNewCacheInsertionWithTimestampOnSuccessfulDeletion() {
        let timestamp = Date()
        let (sut, store) = makeSUT(currentDate: timestamp)
        let feed = uniqueImageFeed()
        
        sut.save(feed.models) { _ in }
        store.completeDeletionSuccessfully()

        XCTAssertEqual(store.receivedMessages, [.deleteCacheFeed, .insert(feed: feed.local, timestamp: timestamp)])
    }
    
    func test_save_failsOnDeletionsError() {
        let (sut, store) = makeSUT()
        let deletionError = anyNSError()
        
        expect(sut, toCompletionWithError: deletionError, when: {
            store.completeDeletion(with: deletionError)
        })
    }
    
    func test_save_failsOnInsertionError() {
        let (sut, store) = makeSUT()
        let insertionError = anyNSError()
        
        expect(sut, toCompletionWithError: insertionError, when: {
            store.completeDeletionSuccessfully()
            store.completeInsertion(with: insertionError)
        })
    }
    
    func test_save_succeedsOnSuccessfulCacheInsertion() {
        let (sut, store) = makeSUT()
        
        expect(sut, toCompletionWithError: nil, when: {
            store.completeDeletionSuccessfully()
            store.completeInsertionSuccessfully()
        })
    }
    
    func test_save_doesNotDeliverDeletionErrorAfterSUTInstanceHasBeenDeallocated() {
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date())
        
        var receivedResults = [LocalFeedLoader.SaveResult]()
        sut?.save(uniqueImageFeed().models, completion: { error in
            receivedResults.append(error)
        })
        sut = nil
        store.completeDeletion(with: anyNSError())
        
        XCTAssertEqual(receivedResults.count, 0)
    }
    
    func test_save_doesNotDeliverInsertionErrorAfterSUTInstanceHasBeenDeallocated() {
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date())
        
        var receivedResults = [LocalFeedLoader.SaveResult]()
        sut?.save(uniqueImageFeed().models, completion: { error in
            receivedResults.append(error)
        })
        store.completeDeletionSuccessfully()
        sut = nil
        store.completeInsertion(with: anyNSError())
        
        XCTAssertEqual(receivedResults.count, 0)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(currentDate: @escaping @autoclosure () -> Date = Date(),
                 file: StaticString = #filePath,
                 line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate())
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, store)
    }
    
    private func expect(_ sut: LocalFeedLoader,
                        toCompletionWithError expectedError: NSError?,
                        when action: () -> Void,
                        file: StaticString = #file,
                        line: UInt = #line) {
        
        let exp = expectation(description: "wait for completion")
        
        var receivedError: Error?
        sut.save(uniqueImageFeed().models) { error in
            receivedError = error
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
        XCTAssertEqual(receivedError as NSError?, expectedError, file: file, line: line)
    }
    
}
