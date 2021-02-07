//
//  XCTestCase+MemoryLeaks.swift
//  EssentialFeedTests
//
//  Created by Mohammed Al Waili on 07/02/2021.
//

import Foundation
import XCTest

//
extension XCTestCase {
    
    func trackForMemoryLeaks(_ instance: AnyObject,
                                     file: StaticString = #filePath,
                                     line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "instance should have been deallocated", file: file, line: line)
        }
    }
    
}
