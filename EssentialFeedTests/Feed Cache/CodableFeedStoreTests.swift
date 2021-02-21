//
//  CodableFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by Mohammed Al Waili on 21/02/2021.
//

import XCTest
import EssentialFeed

class CodableFeedStore {
    func retrieve(completion: @escaping FeedStore.RetrievalCompletion) {
        completion(.empty)
    }
}

class CodableFeedStoreTests: XCTestCase {
    
    func test_retrieve_deliversEmptyOnEmptyCache() {
        let sut = CodableFeedStore()
        let exp = expectation(description: "wait for completion")
        
        sut.retrieve { result in
            switch result {
            case .empty: break
            default:
                XCTFail("expected empty result, but got \(result) instead!")
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        
    }
    
}
