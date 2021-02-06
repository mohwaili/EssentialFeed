//
//  URLSessionHTTPClientTests.swift
//  EssentialFeedTests
//
//  Created by Mohammed Alwaili on 06/02/2021.
//

import XCTest
import EssentialFeed

class URLSessionHTTPClient {
    
    private let session: URLSession
    
    init(session: URLSession) {
        self.session = session
    }
    
    enum URLSessionHTTPClientError: Error {
        case unknown
    }
    
    func get(from url: URL, completion: @escaping (Result<(Data, HTTPURLResponse), Error>) -> Void) {
        session.dataTask(with: url, completionHandler: { data, response, error in
            guard let data = data,
                  let response = response as? HTTPURLResponse else {
                return completion(.failure(error ?? URLSessionHTTPClientError.unknown))
            }
            completion(.success((data, response)))
        }).resume()
    }
    
}

class URLSessionHTTPClientTests: XCTestCase {
    
    func test_getFromURL_dataTaskCallsResumeOnce() {
        let url = URL(string: "http://any-url.com")!
        let session = URLSessionSpy()
        let task = URLSessionDataTaskSpy()
        session.stub(url: url, task: task)
        
        let sut = URLSessionHTTPClient(session: session)
        
        sut.get(from: url) { _ in }
        
        XCTAssertEqual(task.resumeCallCount, 1)
    }
    
    func test_getFromURL_failsOnRequestError() {
        let url = URL(string: "http://any-url.com")!
        let error = NSError(domain: "any error", code: 0)
        let session = URLSessionSpy()
        session.stub(url: url, error: error)
        
        let sut = URLSessionHTTPClient(session: session)
        
        let exp = expectation(description: "get from url")
        sut.get(from: url) { result in
            switch result {
            case let .failure(receivedError as NSError):
                XCTAssertEqual(receivedError, error)
            default:
                XCTFail("Expected failure with error \(error), got \(result) instead")
            }
            exp.fulfill()
        }
            
        wait(for: [exp], timeout: 1.0)
    }
    
    private class URLSessionSpy: URLSession {
        
        override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
            guard let stub = stubs[url] else {
                fatalError("couldn't find a stub for the given url")
            }
            completionHandler(nil, nil, stub.error)
            return stub.task
        }
    
        private struct Stub {
            let task: URLSessionDataTask
            let error: Error?
        }
        
        private var stubs: [URL: Stub] = [:]
        func stub(url: URL, task: URLSessionDataTask = URLSessionDataTaskSpy(), error: Error? = nil) {
            stubs[url] = Stub(task: task, error: error)
        }
        
    }
    
    private class URLSessionDataTaskSpy: URLSessionDataTask {
        var resumeCallCount = 0
        override func resume() {
            resumeCallCount += 1
        }
    }

}
