//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Mohammed Al Waili on 04/02/2021.
//

import XCTest
import EssentialFeed

final class RemoteFeedLoaderTests: XCTestCase {
    
    func test_init_doesNotRequestDataFromURL() {
        let (_, client) = makeSUT()
        
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_load_reqeustsDataFromURL() {
        let url = URL(string: "https://a-given-url.com")!
        let (sut, client) = makeSUT(url: url)
        
        sut.load { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_loadTwice_requestsDataFromURLTwice() {
        let url = URL(string: "https://a-given-url.com")!
        let (sut, client) = makeSUT(url: url)
        
        sut.load { _ in }
        sut.load { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    func test_load_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()
        
        expect(sut: sut,
               toCompleteWith: failure(.connectivity)) {
            let clientError = NSError(domain: "Test", code: 0)
            client.complete(with: clientError)
        }
    }
    
    func test_load_deliversErrorOnNon200HTTPResponse() {
        let (sut, client) = makeSUT()
        
        let samples = [199, 201, 300, 400, 500]
        samples.enumerated().forEach { index, statusCode in
            expect(sut: sut,
                   toCompleteWith: failure(.invalidData)) {
                let data = makeItemsJSON(items: [])
                client.complete(withStatusCode: statusCode, at: index, data: data)
            }
        }
    }
    
    func test_load_deliversNoItemsOn200HTTPResponseWithEmptyJSONList() {
        let (sut, client) = makeSUT()
        
        expect(sut: sut,
               toCompleteWith: .success([])) {
            let emptyListJSON = makeItemsJSON(items: [])
            client.complete(withStatusCode: 200, data: emptyListJSON)
        }

    }
    
    func test_load_deliversErrorOn200ResponseWithInvalidJSON() {
        let (sut, client) = makeSUT()
        
        expect(sut: sut, toCompleteWith: failure(.invalidData)) {
            let invalidJSON = Data("invalid_json".utf8)
            client.complete(withStatusCode: 200, data: invalidJSON)
        }
    }
    
    func test_load_deliversItemsOn200ResponseWithValidJSON() {
        let (sut, client) = makeSUT()
        
        let item1 = makeItem(id: UUID(),
                             imageURL: URL(string: "https://a-image-url.com")!)
        let item2 = makeItem(id: UUID(),
                             description: "a description",
                             location: "a location",
                             imageURL: URL(string: "https://a-image-url.com")!)
        
        expect(sut: sut, toCompleteWith: .success([item1.model, item2.model])) {
            let data = makeItemsJSON(items: [item1.json, item2.json])
            client.complete(withStatusCode: 200, data: data)
        }
    }
    
    func test_load_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
        let url = URL(string: "https://a-give-url.com")!
        let client = HTTPClientSpy()
        var sut: RemoteFeedLoader? = RemoteFeedLoader(url: url, client: client)
        
        var capturedResults: [Result<[FeedItem], Error>] = []
        sut?.load { result in
            capturedResults.append(result)
        }
        sut = nil
        client.complete(withStatusCode: 300, data: Data())
        
        XCTAssertTrue(capturedResults.isEmpty)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(url: URL = URL(string: "https://a-given-url")!,
                         file: StaticString = #filePath,
                         line: UInt = #line) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(client, file: file, line: line)
        return (sut, client)
    }
    
    private func makeItem(id: UUID,
                          description: String? = nil,
                          location: String? = nil,
                          imageURL: URL) -> (model: FeedItem, json: [String: Any]) {
        let item = FeedItem(id: id,
                 description: description,
                 location: location,
                 imageURL: imageURL)
        let json = [
            "id": item.id.uuidString,
            "description": item.description,
            "location": item.location,
            "image": item.imageURL.absoluteString
        ].compactMapValues { $0 as Any }
        return (item, json)
    }
    
    private func makeItemsJSON(items: [[String: Any]]) -> Data {
        let itemsJSON = ["items": items]
        return try! JSONSerialization.data(withJSONObject: itemsJSON)
    }
    
    private func expect(sut: RemoteFeedLoader,
                        toCompleteWith expectedResult: Result<[FeedItem], Error>,
                        when closure: () -> Void,
                        file: StaticString = #filePath,
                        line: UInt = #line) {
        let exp = expectation(description: "load for load completion")
        sut.load { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.failure(recievedError as RemoteFeedLoader.Error), .failure(expectedError as RemoteFeedLoader.Error)):
                XCTAssertEqual(recievedError, expectedError, file: file, line: line)
            case let (.success(receivedItems), .success(expedtedItems)):
                XCTAssertEqual(receivedItems, expedtedItems, file: file, line: line)
            default:
                XCTFail("Expected result: \(expectedResult) but got \(receivedResult) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        closure()
        
        wait(for: [exp], timeout: 1.0)
    }
    
    private func failure(_ error: RemoteFeedLoader.Error) -> Result<[FeedItem], Error> {
        .failure(error)
    }
    
    private class HTTPClientSpy: HTTPClient {
        var messages: [(url: URL, completion: (Result<(Data, HTTPURLResponse), Error>) -> Void)] = []
        
        var requestedURLs: [URL] {
            messages.map { $0.url  }
        }
        
        func get(from url: URL, completion: @escaping (Result<(Data, HTTPURLResponse), Error>) -> Void) {
            messages.append((url, completion))
        }
        
        func complete(with clientError: Error, at index: Int = 0) {
            messages[index].completion(.failure(clientError))
        }
        
        func complete(withStatusCode code: Int, at index: Int = 0, data: Data) {
            let response = HTTPURLResponse(url: requestedURLs[index],
                                           statusCode: code,
                                           httpVersion: nil,
                                           headerFields: nil)!
            messages[index].completion(.success((data, response)))
        }
        
    }
    
}
