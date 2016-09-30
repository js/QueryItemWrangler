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

    public func get<T: QueryRepresentable>(key: QueryItemKey<T>) -> T? {
        return self[key.key].flatMap({ T(queryItemValue: $0) })
    }

    public mutating func set<T: QueryRepresentable>(key: QueryItemKey<T>, value: T?) {
        self[key.key] = value?.queryItemValueRepresentation
    }

    public func queryItem(key: String) -> URLQueryItem? {
        return queryItems.filter({ $0.name == key }).first
    }

    // MARK: Typed Subscripts
    // (if swift supported generic subscripts these wouldn't be needed)

    public subscript(key: QueryItemKey<String>) -> String? {
        get { return get(key: key) }
        set { set(key: key, value: newValue) }
    }

    public subscript(key: QueryItemKey<Int>) -> Int? {
        get { return get(key: key) }
        set { set(key: key, value: newValue) }
    }

    public subscript(key: QueryItemKey<Bool>) -> Bool? {
        get { return get(key: key) }
        set { set(key: key, value: newValue) }
    }

    public subscript(key: QueryItemKey<URL>) -> URL? {
        get { return get(key: key) }
        set { set(key: key, value: newValue) }
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
