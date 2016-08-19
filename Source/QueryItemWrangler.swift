//
//  QueryItemWrangler.swift
//  QueryItemWrangler
//
//  Created by Johan Sørensen on 28/06/16.
//  Copyright © 2016 Johan Sørensen. All rights reserved.
//

import Foundation

public protocol QueryRepresentable {}
extension String: QueryRepresentable {}
extension Int: QueryRepresentable {}
extension Bool: QueryRepresentable {}

public struct QueryItemKey<Key where Key: QueryRepresentable> {
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



    public subscript(key: String) -> String? {
        get {
            return queryItemForKey(key)?.value
        }
        set {
            setQueryItemValue(key, value: newValue)
        }
    }

    public subscript(key: QueryItemKey<String>) -> String? {
        get {
            return self[key.key]
        }
        set {
            self[key.key] = newValue
        }
    }

    public subscript(key: QueryItemKey<Int>) -> Int? {
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

    public subscript(key: QueryItemKey<Bool>) -> Bool {
        get {
            if let value = self[key.key] {
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
