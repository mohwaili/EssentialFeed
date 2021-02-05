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
        
        var capturedErrors: [RemoteFeedLoader.Error] = []
        sut.load { error in
            capturedErrors.append(error)
        }
        
        let clientError = NSError(domain: "Test", code: 0)
        client.complete(with: clientError)
        
        XCTAssertEqual(capturedErrors, [.connectivity])
    }
    
    func test_load_deliversErrorOnNon200HTTPResponse() {
        let (sut, client) = makeSUT()
        
        let samples = [199, 201, 300, 400, 500]
        samples.enumerated().forEach { index, statusCode in
            var capturedErrors: [RemoteFeedLoader.Error] = []
            sut.load { error in
                capturedErrors.append(error)
            }
            client.complete(withStatusCode: statusCode, at: index)
            XCTAssertEqual(capturedErrors, [.invalidData])
        }
        
    }
    
    // MARK: - Helpers
    
    private func makeSUT(url: URL = URL(string: "https://a-given-url")!) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        return (RemoteFeedLoader(url: url, client: client), client)
    }
    
    private class HTTPClientSpy: HTTPClient {
        var messages: [(url: URL, completion: (Result<HTTPURLResponse, Error>) -> Void)] = []
        
        var requestedURLs: [URL] {
            messages.map { $0.url  }
        }
        
        func get(from url: URL, completion: @escaping (Result<HTTPURLResponse, Error>) -> Void) {
            messages.append((url, completion))
        }
        
        func complete(with clientError: Error, at index: Int = 0) {
            messages[index].completion(.failure(clientError))
        }
        
        func complete(withStatusCode code: Int, at index: Int = 0) {
            let response = HTTPURLResponse(url: requestedURLs[index],
                                           statusCode: code,
                                           httpVersion: nil,
                                           headerFields: nil)!
            messages[index].completion(.success(response))
        }
        
    }
    
}
