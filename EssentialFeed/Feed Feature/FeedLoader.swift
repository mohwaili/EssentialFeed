//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Mohammed Alwaili on 13/02/2021.
//

import Foundation

public protocol FeedLoader {
    func load(completion: @escaping (Result<[FeedItem], Swift.Error>) -> Void)
}
