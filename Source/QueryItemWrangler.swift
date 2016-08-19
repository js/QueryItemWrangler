//
//  QueryItemWrangler.swift
//  QueryItemWrangler
//
//  Created by Johan Sørensen on 28/06/16.
//  Copyright © 2016 Johan Sørensen. All rights reserved.
//

import Foundation

public struct QueryItemWrangler {
    public private(set) var queryItems: [NSURLQueryItem]

    public init(items: [NSURLQueryItem]?) {
        self.queryItems = items ?? []
    }

    public subscript(key: String) -> String? {
        get {
            return queryItemForKey(key)?.value
        }
        set {
            setQueryItemValue(key, value: newValue)
        }
    }

    func get<T: QueryRepresentable>(key: QueryItemKey<T>) -> T? {
        return self[key.key].flatMap({ T(queryItemValue: $0) })
    }

    mutating func set<T: QueryRepresentable>(key: QueryItemKey<T>, value: T?) {
        self[key.key] = value?.queryItemValueRepresentation
    }

    // MARK: Typed Subscripts

    public subscript(key: QueryItemKey<String>) -> String? {
        get { return get(key) }
        set { set(key, value: newValue) }
    }

    public subscript(key: QueryItemKey<Int>) -> Int? {
        get { return get(key) }
        set { set(key, value: newValue) }
    }

    public subscript(key: QueryItemKey<Bool>) -> Bool? {
        get { return get(key) }
        set { set(key, value: newValue) }
    }
}

extension QueryItemWrangler: CustomStringConvertible {
    public var description: String {
        let items = queryItems.map({ "\($0.name): \($0.value ?? "nil")" }).joinWithSeparator(", ")
        return "QueryItemWrangler{\(items)}"
    }
}

extension QueryItemWrangler: Equatable {}

public func ==(lhs: QueryItemWrangler, rhs: QueryItemWrangler) -> Bool {
    return lhs.queryItems == rhs.queryItems
}

private extension QueryItemWrangler {
    private func queryItemForKey(key: String) -> NSURLQueryItem? {
        return queryItems.filter({ $0.name == key }).first
    }

    private mutating func setQueryItemValue(key: String, value: String?) {
        removeQueryItemForKey(key)

        if let value = value {
            let item = NSURLQueryItem(name: key, value: value)
            queryItems.append(item)
        }
    }

    private mutating func removeQueryItemForKey(key: String) {
        if let item = queryItemForKey(key), let idx = queryItems.indexOf(item) {
            queryItems.removeAtIndex(idx)
        }
    }
}
