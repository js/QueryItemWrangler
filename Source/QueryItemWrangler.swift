//
//  QueryItemWrangler.swift
//  QueryItemWrangler
//
//  Created by Johan Sørensen on 28/06/16.
//  Copyright © 2016 Johan Sørensen. All rights reserved.
//

import Foundation

public struct QueryItemWrangler {
    public fileprivate(set) var queryItems: [URLQueryItem]

    public init(items: [URLQueryItem]?) {
        self.queryItems = items ?? []
    }

    public subscript(key: String) -> String? {
        get {
            return queryItem(key: key)?.value
        }
        set {
            setQueryItem(key: key, value: newValue)
        }
    }

    public func queryItem(key: String) -> URLQueryItem? {
        return queryItems.filter({ $0.name == key }).first
    }

    public subscript<T>(key: QueryItemKey<T>) -> T? where T: QueryRepresentable {
        get {
            return self[key.key].flatMap({ T(queryItemValue: $0) })
        }
        set {
            self[key.key] = newValue?.queryItemValueRepresentation
        }
    }
}

extension QueryItemWrangler: CustomStringConvertible {
    public var description: String {
        let items = queryItems.map({ "\($0.name): \($0.value ?? "nil")" }).joined(separator: ", ")
        return "QueryItemWrangler{\(items)}"
    }
}

extension QueryItemWrangler: Equatable {}

public func ==(lhs: QueryItemWrangler, rhs: QueryItemWrangler) -> Bool {
    return lhs.queryItems == rhs.queryItems
}

extension QueryItemWrangler: Sequence {
    public func makeIterator() -> Iterator {
        return Iterator(items: queryItems)
    }

    public struct Iterator: IteratorProtocol {
        fileprivate var sequenceIndex = 0
        let items: [URLQueryItem]

        init(items: [URLQueryItem]) {
            self.items = items
        }

        mutating public func next() -> (String, String?)? {
            if sequenceIndex >= items.count {
                return nil
            }
            defer { sequenceIndex += 1 }
            let item = items[sequenceIndex]
            return (item.name, item.value)
        }
    }
}

fileprivate extension QueryItemWrangler {
    fileprivate mutating func setQueryItem(key: String, value: String?) {
        // NSURLQueryItem is immutable, so we have to remove & recreate when updating the value
        if let item = queryItem(key: key), let idx = queryItems.index(of: item) {
            queryItems.remove(at: idx)
        }

        if let value = value {
            let item = URLQueryItem(name: key, value: value)
            queryItems.append(item)
        }
    }
}
