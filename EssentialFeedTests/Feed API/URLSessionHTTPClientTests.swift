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
    
    func test_getFromURL_failsOnRequestError() {
        let url = URL(string: "http://any-url.com")!
        let error = NSError(domain: "any error", code: 0)
        URLProtocolStub.stub(data: nil, response: nil, error: error)
        
        let sut = makeSUT()
        
        let exp = expectation(description: "get from url")
        sut.get(from: url) { result in
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
    
    // MARK: - Helpers -
    
    private func makeSUT() -> URLSessionHTTPClient {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [URLProtocolStub.self]
        let session = URLSession(configuration: configuration)
        return URLSessionHTTPClient(session: session)
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
//            stubs = [:]
//        }
        
        override class func canInit(with request: URLRequest) -> Bool {
            true
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
