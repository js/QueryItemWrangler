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

    public func get<T: QueryRepresentable>(key: QueryItemKey<T>) -> T? {
        return self[key.key].flatMap({ T(queryItemValue: $0) })
    }

    public mutating func set<T: QueryRepresentable>(key: QueryItemKey<T>, value: T?) {
        self[key.key] = value?.queryItemValueRepresentation
    }

    public func queryItemForKey(key: String) -> NSURLQueryItem? {
        return queryItems.filter({ $0.name == key }).first
    }

    // MARK: Typed Subscripts
    // (if swift supported generic subscripts these wouldn't be needed)

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

extension QueryItemWrangler: SequenceType {
    public func generate() -> Generator {
        return Generator(items: queryItems)
    }

    public struct Generator: GeneratorType {
        private var sequenceIndex = 0
        let items: [NSURLQueryItem]

        init(items: [NSURLQueryItem]) {
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

private extension QueryItemWrangler {
    private mutating func setQueryItemValue(key: String, value: String?) {
        // NSURLQueryItem is immutable, so we have to remove & recreate when updating the value
        if let item = queryItemForKey(key), let idx = queryItems.indexOf(item) {
            queryItems.removeAtIndex(idx)
        }

        if let value = value {
            let item = NSURLQueryItem(name: key, value: value)
            queryItems.append(item)
        }
    }
}
