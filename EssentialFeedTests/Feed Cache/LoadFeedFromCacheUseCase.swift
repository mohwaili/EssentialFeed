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
    
}
