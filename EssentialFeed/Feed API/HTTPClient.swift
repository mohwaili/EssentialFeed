//
//  HTTPClient.swift
//  EssentialFeed
//
//  Created by Mohammed Al Waili on 06/02/2021.
//

import Foundation

public protocol HTTPClient {
    func get(from url: URL, completion: @escaping (Result<(Data, HTTPURLResponse), Error>) -> Void)
}
