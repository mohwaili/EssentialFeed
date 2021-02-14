//
//  LoadFeedFromCacheUseCase.swift
//  EssentialFeedTests
//
//  Created by Mohammed Alwaili on 13/02/2021.
//

import XCTest
import EssentialFeed

class LoadFeedFromCacheUseCase: XCTestCase {
    
    func test_init_doesNotMessageStoreUponCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.receivedMessages, [])
    }
    
    func test_load_requestsCacheRetrieval() {
        let (sut, store) = makeSUT()
        
        sut.load { _ in }
        
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_load_failsOnRetrievalError() {
        let (sut, store) = makeSUT()
        let retrievalError = anyNSError()
        let exp = expectation(description: "wait for load completion")
        
        var receiverError: Error?
        sut.load { error in
            receiverError = error
            exp.fulfill()
        }
        store.completeRetrieval(with: retrievalError)
        
        wait(for: [exp], timeout: 1.0)
        XCTAssertEqual(receiverError as NSError?, retrievalError)
    }
    
    // MARK: - Helpers -
    
    private func makeSUT(currentDate: @escaping @autoclosure () -> Date = Date(),
                 file: StaticString = #filePath,
                 line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate())
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, store)
    }
    
    private func anyNSError() -> NSError {
        NSError(domain: "any error", code: 0)
    }
    
}
