//
//  URLSessionHTTPClientTests.swift
//  EssentialFeedTests
//
//  Created by Mohammed Alwaili on 06/02/2021.
//

import XCTest
import EssentialFeed

class URLSessionHTTPClientTests: XCTestCase {
    
    func test_getFromURL_performsGETRequestWithURL() {
        let url = anyURL()
        let exp = expectation(description: "wait for request")
        
        URLProtocolStub.observerRequests = { [weak exp] request in
            XCTAssertEqual(request.url, url)
            XCTAssertEqual(request.httpMethod, "GET")
            exp?.fulfill()
        }
        
        makeSUT().get(from: url, completion: { _ in })
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_getFromURL_failsOnRequestError() {
        let requestError = anyNSError()
        
        let receivedError = resultErrorFor(data: nil, response: nil, error: requestError)
        
        XCTAssertEqual((receivedError as NSError?)?.code, requestError.code)
        XCTAssertEqual((receivedError as NSError?)?.domain, requestError.domain)
    }
    
    func test_getFromURL_failsOnAllInvalidRepresentationCase() {
        XCTAssertNotNil(resultErrorFor(data: nil, response: nil, error: nil))
        XCTAssertNotNil(resultErrorFor(data: nil, response: nonHTTPURLResponse(), error: nil))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nil, error: nil))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nil, error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: nil, response: nonHTTPURLResponse(), error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: nil, response: anyHTTPURLResponse(), error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nonHTTPURLResponse(), error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: anyHTTPURLResponse(), error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nonHTTPURLResponse(), error: nil))
    }
    
    func test_getFromURL_succeedsWithEmptyDataWhenHTTURLResponseDataIsNil() {
        let expectedResponse = anyHTTPURLResponse()
        
        let receivedValues = resultValuesFor(data: nil, response: expectedResponse, error: nil)
        
        XCTAssertEqual(receivedValues?.data, Data())
        XCTAssertEqual(receivedValues?.response.statusCode, expectedResponse.statusCode)
        XCTAssertEqual(receivedValues?.response.url, expectedResponse.url)
    }
    
    func test_getFromURL_succeedsOnDataAndHTTPURLResponse() {
        let expectedData = anyData()
        let expectedResponse = anyHTTPURLResponse()
        
        let receivedValues = resultValuesFor(data: expectedData, response: expectedResponse, error: nil)
        
        XCTAssertEqual(receivedValues?.data, expectedData)
        XCTAssertEqual(receivedValues?.response.statusCode, expectedResponse.statusCode)
        XCTAssertEqual(receivedValues?.response.url, expectedResponse.url)
    }
    
    // MARK: - Helpers -
    
    private func makeSUT(file: StaticString = #filePath,
                         line: UInt = #line) -> HTTPClient {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [URLProtocolStub.self]
        let session = URLSession(configuration: configuration)
        let sut = URLSessionHTTPClient(session: session)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    private func resultErrorFor(data: Data?,
                                response: URLResponse?,
                                error: Error?,
                                file: StaticString = #file,
                                line: UInt = #line) -> Error? {
        let result = resultFor(data: data, response: response, error: error)
        
        var receivedError: Error?
        switch result {
        case let .failure(error):
            receivedError = error
        default:
            XCTFail("Expected failure with error \(String(describing: error)), got \(String(describing: result)) instead")
        }
        
        return receivedError
    }
    
    private func resultValuesFor(data: Data?,
                                response: URLResponse?,
                                error: Error?,
                                file: StaticString = #file,
                                line: UInt = #line) -> (data: Data, response: HTTPURLResponse)? {
        let result = resultFor(data: data, response: response, error: error)
        var receivedValues: (Data, HTTPURLResponse)?
        
        switch result {
        case let .success((data, response)):
            receivedValues = (data, response)
        default:
            XCTFail("Expected success with result \(String(describing: data)) \(String(describing: response)), got \(String(describing: result)) instead")
        }
        
        return receivedValues
    }
    
    private func resultFor(data: Data?,
                                response: URLResponse?,
                                error: Error?,
                                file: StaticString = #file,
                                line: UInt = #line) -> Result<(Data, HTTPURLResponse), Error>? {
        URLProtocolStub.stub(data: data, response: response, error: error)
        let sut = makeSUT(file: file, line: line)
        let exp = expectation(description: "wait for completion")
        
        var receivedResult: Result<(Data, HTTPURLResponse), Error>?
        sut.get(from: anyURL()) { result in
            receivedResult = result
            exp.fulfill()
        }
            
        wait(for: [exp], timeout: 1.0)
        return receivedResult
    }
    
    private func anyURL() -> URL {
        URL(string: "http://any-url.com")!
    }
    
    private func anyNSError() -> NSError {
        NSError(domain: "any error", code: 0)
    }
    
    private func anyData() -> Data {
        Data("any data".utf8)
    }
    
    private func nonHTTPURLResponse() -> URLResponse {
        URLResponse(url: anyURL(),
                    mimeType: nil,
                    expectedContentLength: 0,
                    textEncodingName: nil)
    }
    
    private func anyHTTPURLResponse() -> HTTPURLResponse {
        HTTPURLResponse(url: anyURL(),
                        statusCode: 200,
                        httpVersion: nil,
                        headerFields: nil)!
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
