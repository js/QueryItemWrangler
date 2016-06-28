//
//  QueryItemWrangler.swift
//  QueryItemWrangler
//
//  Created by Johan Sørensen on 28/06/16.
//  Copyright © 2016 Johan Sørensen. All rights reserved.
//

import Foundation

// TODO can we constrain to the supported Int?, String? and Bool types?
public struct QueryItemKey<T> {
    private let key: String

    public init(_ key: String) {
        self.key = key
    }
}

public struct QueryItemWrangler {
    public private(set) var queryItems: [NSURLQueryItem]

    public init(items: [NSURLQueryItem]?) {
        self.queryItems = items ?? []
    }

    subscript(key: String) -> String? {
        get {
            return queryItemForKey(key)?.value
        }
        set {
            setQueryItemValue(key, value: newValue)
        }
    }

    subscript(key: QueryItemKey<String?>) -> String? {
        get {
            return self[key.key]
        }
        set {
            self[key.key] = newValue
        }
    }

    subscript(key: QueryItemKey<String>) -> String {
        // returns an empty String ("") if the key is not present in the query items
        get {
            let optionalKey = QueryItemKey<String?>(key.key)
            return self[optionalKey] ?? ""
        }
        set {
            let optionalKey = QueryItemKey<String?>(key.key)
            self[optionalKey] = newValue
        }
    }

    subscript(key: QueryItemKey<Int?>) -> Int? {
        get {
            return self[key.key].flatMap({ Int($0) })
        }
        set {
            if let value = newValue {
                self[key.key] = String(value)
            } else {
                self[key.key] = nil
            }
        }
    }

    subscript(key: QueryItemKey<Int>) -> Int {
        // returns 0 if the key is not present in the query items
        get {
            let optionalKey = QueryItemKey<Int?>(key.key)
            return self[optionalKey] ?? 0
        }
        set {
            let optionalKey = QueryItemKey<Int?>(key.key)
            self[optionalKey] = newValue
        }
    }

    subscript(key: QueryItemKey<Bool>) -> Bool {
        get {
            if let value = self[key.key] {
                // FIXME: should "true" (and whatever else) be configurable on the QueryItem somehow?
                return ["1", "true"].contains(value)
            } else {
                return false
            }
        }
        set {
            self[key.key] = newValue ? "1" : "0"
        }
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
