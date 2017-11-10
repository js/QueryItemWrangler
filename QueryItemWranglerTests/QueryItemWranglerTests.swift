//
//  QueryItemWranglerTests.swift
//  QueryItemWranglerTests
//
//  Created by Johan Sørensen on 28/06/16.
//  Copyright © 2016 Johan Sørensen. All rights reserved.
//

import XCTest
@testable import QueryItemWrangler

class QueryItemWranglerTests: XCTestCase {
    let url = URL(string: "https://example.com?str=foo%20bar&num=42&flag=1&flag2=true&url=http%3A%2F%2Fexample.com")!
    var components: URLComponents!

    override func setUp() {
        super.setUp()
        components = URLComponents(url: url, resolvingAgainstBaseURL: true)!
    }

    func testStringValues() {
        var wrangler = QueryItemWrangler(items: components.queryItems)
        XCTAssertEqual(wrangler["str"], Optional("foo bar"))
        wrangler["str"] = "foo"
        XCTAssertEqual(wrangler["str"], Optional("foo"))

        XCTAssertEqual(wrangler[QueryItemKey<String>("str")], Optional("foo"))
        wrangler[QueryItemKey<String>("str")] = "baz"
        XCTAssertEqual(wrangler[QueryItemKey<String>("str")], Optional("baz"))
        XCTAssertEqual(wrangler[QueryItemKey<String>("nonexistant")], nil)
    }

    func testIntValues() {
        var wrangler = QueryItemWrangler(items: components.queryItems)
        XCTAssertEqual(wrangler[QueryItemKey<Int>("num")], Optional(42))
        wrangler[QueryItemKey<Int>("num")] = 84
        XCTAssertEqual(wrangler[QueryItemKey<Int>("num")], Optional(84))
        XCTAssertEqual(wrangler[QueryItemKey<Int>("nonexistant")], nil)
    }

    func testBoolValues() {
        var wrangler = QueryItemWrangler(items: components.queryItems)
        XCTAssertEqual(wrangler[QueryItemKey<Bool>("flag")], Optional(true))
        wrangler[QueryItemKey<Bool>("newflag")] = true
        XCTAssertEqual(wrangler[QueryItemKey<Bool>("newflag")], Optional(true))
        XCTAssertEqual(wrangler[QueryItemKey<Bool>("flag2")], Optional(true))

        XCTAssertEqual(wrangler[QueryItemKey<Bool>("nonexistant")], nil)
    }

    func testURLValue() {
        var wrangler = QueryItemWrangler(items: components.queryItems)
        XCTAssertEqual(wrangler["url"], Optional("http://example.com"))

        let url = URL(string: "http://example.com")!
        XCTAssertEqual(wrangler[QueryItemKey<URL>("url")], Optional(url))
        let newUrl = URL(string: "http://example.com/another")!
        wrangler[QueryItemKey<URL>("url")] = newUrl
        XCTAssertEqual(wrangler[QueryItemKey<URL>("url")], Optional(newUrl))
        XCTAssertEqual(wrangler[QueryItemKey<URL>("nonexistant")], nil)
    }

    func testEquality() {
        let wrangler = QueryItemWrangler(items: components.queryItems)
        let other = QueryItemWrangler(items: components.queryItems)
        XCTAssertTrue(wrangler == other)
    }

    func testQueryItemForKey() {
        let wrangler = QueryItemWrangler(items: components.queryItems)
        let item = wrangler.queryItem(key: "num")
        XCTAssert(item != nil)
        XCTAssertEqual(item!.name, "num")
        XCTAssertEqual(item!.value, Optional("42"))
    }

    func testNillingItemRemovesIt() {
        var wrangler = QueryItemWrangler(items: components.queryItems)
        wrangler["num"] = nil
        XCTAssert(wrangler.queryItem(key: "num") == nil)
    }

    func testUnsupportedEdgeCases() {
        let url = URL(string: "https://example.com?ids=1&ids=2&ids=3")!
        let components = URLComponents(url: url, resolvingAgainstBaseURL: true)!
        let wrangler = QueryItemWrangler(items: components.queryItems)
        // TODO: should we support a `QueryItemKey<[String]>("ids")`key type (and [Int])?
        XCTAssertEqual(wrangler[QueryItemKey<String>("ids")], Optional("1"))
    }

    // MARK - Collection conformance

    func testSequence() {
        let wrangler = QueryItemWrangler(items: components.queryItems)
        var keys: [String] = []
        var values: [String] = []
        for (key, value) in wrangler {
            keys.append(key)
            XCTAssertNotNil(value)
            values.append(value!)
        }
        let expectedKeys = ["str", "num", "flag", "flag2", "url"]
        XCTAssertEqual(keys, expectedKeys)
        let expectedValues = ["foo bar", "42", "1", "true", "http://example.com"]
        XCTAssertEqual(values, expectedValues)
    }
}
