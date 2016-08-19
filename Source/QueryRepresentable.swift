//
//  QueryRepresentable.swift
//  QueryItemWrangler
//
//  Created by Sørensen, Johan on 19.08.2016.
//  Copyright © 2016 Johan Sørensen. All rights reserved.
//

import Foundation

public protocol QueryRepresentable {
    init?(queryItemValue: String)
    var queryItemValueRepresentation: String { get }
}

extension String: QueryRepresentable{
    public init?(queryItemValue: String) {
        self.init(queryItemValue)
    }

    public var queryItemValueRepresentation: String {
        return self
    }
}

extension Int: QueryRepresentable {
    public init?(queryItemValue: String) {
        self.init(queryItemValue)
    }

    public var queryItemValueRepresentation: String {
        return String(self)
    }
}

extension Bool: QueryRepresentable {
    public init?(queryItemValue: String) {
        self.init(["1", "true"].contains(queryItemValue))
    }

    public var queryItemValueRepresentation: String {
        return self ? "1" : "0"
    }
}

public struct QueryItemKey<Key where Key: QueryRepresentable> {
    internal let key: String

    public init(_ key: String) {
        self.key = key
    }
}
