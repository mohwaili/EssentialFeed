//
//  FeedCacheTestHelpers.swift
//  EssentialFeedTests
//
//  Created by Mohammed Alwaili on 19/02/2021.
//

import Foundation
import EssentialFeed

func uniqueImage() -> FeedImage {
    FeedImage(id: UUID(),
             description: nil,
             location: nil,
             url: anyURL())
}

func uniqueImageFeed() -> (models: [FeedImage], local: [LocalFeedImage]) {
    let feed = [uniqueImage(), uniqueImage()]
    let localFeed = feed.map {
        LocalFeedImage(id: $0.id,
                      description: $0.description,
                      location: $0.location,
                      url: $0.url)
    }
    return (feed, localFeed)
}

extension Date {
    func minusFeedCacheMaxAge() -> Date {
        return adding(days: -feedCacheMaxAgeInDays)
    }
    
    private var feedCacheMaxAgeInDays: Int {
        7
    }
    
    func adding(days: Int) -> Date {
        Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
    }
    
    func adding(seconds: Int) -> Date {
        Calendar(identifier: .gregorian).date(byAdding: .second, value: seconds, to: self)!
    }
}
