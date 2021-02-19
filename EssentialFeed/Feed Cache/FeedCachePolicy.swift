//
//  FeedCachePolicy.swift
//  EssentialFeed
//
//  Created by Mohammed Alwaili on 20/02/2021.
//

import Foundation

internal final class FeedCachePolicy {
    
    private init() {}
    
    private static let calendar: Calendar = Calendar(identifier: .gregorian)
    
    private static var maxCacheAgeInDays: Int {
        7
    }
    
    static func validate(_ timestamp: Date, against date: Date) -> Bool {
        guard let maxCacheAge = calendar.date(byAdding: .day, value: maxCacheAgeInDays, to: timestamp) else {
            return false
        }
        return date < maxCacheAge
    }
}
