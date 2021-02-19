//
//  SharedTestHelpers.swift
//  EssentialFeedTests
//
//  Created by Mohammed Alwaili on 19/02/2021.
//

import Foundation

func anyNSError() -> NSError {
    NSError(domain: "any error", code: 0)
}

func anyURL() -> URL {
    URL(string: "http://any-url.com")!
}
