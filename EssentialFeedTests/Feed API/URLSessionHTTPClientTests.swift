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
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    enum URLSessionHTTPClientError: Error {
        case unknown
    }
    
    struct UnexpectedValuesRepresentation: Error { }
    
    func get(from url: URL, completion: @escaping (Result<(Data, HTTPURLResponse), Error>) -> Void) {
        session.dataTask(with: url, completionHandler: { data, response, error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.failure(UnexpectedValuesRepresentation()))
            }
        }).resume()
    }
    
}

class URLSessionHTTPClientTests: XCTestCase {
    
    func test_getFromURL_performsGETRequestWithURL() {
        let url = anyURL()
        let exp = expectation(description: "wait for request")
        
        URLProtocolStub.observerRequests = { request in
            XCTAssertEqual(request.url, url)
            XCTAssertEqual(request.httpMethod, "GET")
            exp.fulfill()
        }
        
        makeSUT().get(from: url, completion: { _ in })
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_getFromURL_failsOnRequestError() {
        let error = anyError()
        URLProtocolStub.stub(data: nil, response: nil, error: error)
        
        let exp = expectation(description: "get from url")
        makeSUT().get(from: anyURL()) { result in
            switch result {
            case let .failure(receivedError as NSError):
                XCTAssertEqual(receivedError.domain, error.domain)
                XCTAssertEqual(receivedError.code, error.code)
            default:
                XCTFail("Expected failure with error \(error), got \(result) instead")
            }
            exp.fulfill()
        }
            
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_getFromURL_failsOnAllNilValues() {
        URLProtocolStub.stub(data: nil, response: nil, error: nil)
        
        let exp = expectation(description: "get from url")
        makeSUT().get(from: anyURL()) { result in
            switch result {
            case .failure:
                break
            default:
                XCTFail("Expected failure with error")
            }
            exp.fulfill()
        }
            
        wait(for: [exp], timeout: 1.0)
    }
    
    // MARK: - Helpers -
    
    private func makeSUT(file: StaticString = #filePath,
                         line: UInt = #line) -> URLSessionHTTPClient {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [URLProtocolStub.self]
        let session = URLSession(configuration: configuration)
        let sut = URLSessionHTTPClient(session: session)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    private func anyURL() -> URL {
        URL(string: "http://any-url.com")!
    }
    
    private func anyError() -> NSError {
        NSError(domain: "any error", code: 0)
    }
    
    private class URLProtocolStub: URLProtocol {
        private static var stub: Stub?
        
        private struct Stub {
            let data: Data?
            let response: URLResponse?
            let error: Error?
        }
        
        static func stub(data: Data?, response: URLResponse?, error: Error?) {
            stub = Stub(data: data, response: response, error: error)
        }
        
//        static func startInterceptingRequest() {
//            URLProtocol.registerClass(URLProtocolStub.self)
//        }
//
//        static func stopInterceptingRequest() {
//            URLProtocol.unregisterClass(URLProtocolStub.self)
//            stub = nil
//        }
        
        static var observerRequests: ((URLRequest) -> Void)?
        
        override class func canInit(with request: URLRequest) -> Bool {
            observerRequests?(request)
            return true
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }
        
        override func startLoading() {
            if let data = URLProtocolStub.stub?.data {
                client?.urlProtocol(self, didLoad: data)
            }
            
            if let response = URLProtocolStub.stub?.response {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
            
            if let error = URLProtocolStub.stub?.error {
                client?.urlProtocol(self, didFailWithError: error)
            }
            
            client?.urlProtocolDidFinishLoading(self)
        }
        
        override func stopLoading() {
            
        }
        
    }

}
