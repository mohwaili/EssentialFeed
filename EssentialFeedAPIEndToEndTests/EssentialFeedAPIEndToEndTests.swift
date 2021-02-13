//
//  EssentialFeedAPIEndToEndTests.swift
//  EssentialFeedAPIEndToEndTests
//
//  Created by Mohammed Alwaili on 07/02/2021.
//

import XCTest
import EssentialFeed

class EssentialFeedAPIEndToEndTests: XCTestCase {

    func test_endToEndTestServerGETFeedResult_matchesFixedTestAccountData() {
        let result = getFeedResult()
        
        switch result {
        case .success(let imageFeed):
            XCTAssertEqual(imageFeed.count, 8)
            XCTAssertEqual(imageFeed[0], expectedImage(at: 0))
            XCTAssertEqual(imageFeed[1], expectedImage(at: 1))
            XCTAssertEqual(imageFeed[2], expectedImage(at: 2))
            XCTAssertEqual(imageFeed[3], expectedImage(at: 3))
            XCTAssertEqual(imageFeed[4], expectedImage(at: 4))
            XCTAssertEqual(imageFeed[5], expectedImage(at: 5))
            XCTAssertEqual(imageFeed[6], expectedImage(at: 6))
            XCTAssertEqual(imageFeed[7], expectedImage(at: 7))
        default:
            XCTFail("Expected successful feed result, got error instead")
        }
    }
    
    // MARK: - Helpers -
    
    private func getFeedResult(file: StaticString = #file, line: UInt = #line) -> Result<[FeedImage], Error>? {
        let url = URL(string: "https://essentialdeveloper.com/feed-case-study/test-api/feed")!
        let client = URLSessionHTTPClient()
        let loader = RemoteFeedLoader(url: url, client: client)
        
        trackForMemoryLeaks(client, file: file, line: line)
        trackForMemoryLeaks(loader, file: file, line: line)
        
        let exp = expectation(description: "wait for load completion")
        var receivedResult: Result<[FeedImage], Error>?
        loader.load { result in
            receivedResult = result
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 5.0)
        return receivedResult
    }
    
    private func expectedImage(at index: Int) -> FeedImage {
        FeedImage(
            id: id(at: index),
            description: description(at: index),
            location: location(at: index),
            url: imageURL(at: index))
    }
    
    private func id(at index: Int) -> UUID {
        UUID(uuidString: [
            "73A7F70C-75DA-4C2E-B5A3-EED40DC53AA6",
            "BA298A85-6275-48D3-8315-9C8F7C1CD109",
            "5A0D45B3-8E26-4385-8C5D-213E160A5E3C",
            "FF0ECFE2-2879-403F-8DBE-A83B4010B340",
            "DC97EF5E-2CC9-4905-A8AD-3C351C311001",
            "557D87F1-25D3-4D77-82E9-364B2ED9CB30",
            "A83284EF-C2DF-415D-AB73-2A9B8B04950B",
            "F79BD7F8-063F-46E2-8147-A67635C3BB01"
        ][index])!
    }
    
    private func description(at index: Int) -> String? {
        ["Description 1",
         nil,
         "Description 3",
         nil,
         "Description 5",
         "Description 6",
         "Description 7",
         "Description 8"
        ][index]
    }
    
    private func location(at index: Int) -> String? {
        ["Location 1",
         "Location 2",
         nil,
         nil,
         "Location 5",
         "Location 6",
         "Location 7",
         "Location 8"
        ][index]
    }
    
    private func imageURL(at index: Int) -> URL {
        URL(string: "https://url-\(index + 1).com")!
    }

}
