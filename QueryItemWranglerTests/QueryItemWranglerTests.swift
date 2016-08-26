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
    let url = NSURL(string: "https://example.com?str=foo%20bar&num=42&flag=1&flag2=true")!
    var components: NSURLComponents!

    override func setUp() {
        super.setUp()
        components = NSURLComponents(URL: url, resolvingAgainstBaseURL: true)!
    }

    func testGetting() {
        let wrangler = QueryItemWrangler(items: components.queryItems)

        XCTAssertEqual(wrangler.get(QueryItemKey<String>("str")), Optional("foo bar"))
        XCTAssertEqual(wrangler.get(QueryItemKey<String>("nope")), nil)

        XCTAssertEqual(wrangler.get(QueryItemKey<Int>("num")), Optional(42))
        XCTAssertEqual(wrangler.get(QueryItemKey<Int>("nope")), nil)

        XCTAssertEqual(wrangler.get(QueryItemKey<Bool>("flag")), Optional(true))
        XCTAssertEqual(wrangler.get(QueryItemKey<Bool>("nope")), nil)
    }

    func testSetting() {
        var wrangler = QueryItemWrangler(items: components.queryItems)

        wrangler.set(QueryItemKey<String>("stringval"), value: "test")
        XCTAssertEqual(wrangler.get(QueryItemKey<String>("stringval")), Optional("test"))
        wrangler.set(QueryItemKey<String>("stringval"), value: nil)
        XCTAssertEqual(wrangler.get(QueryItemKey<String>("stringval")), nil)
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

    func testEquality() {
        let wrangler = QueryItemWrangler(items: components.queryItems)
        let other = QueryItemWrangler(items: components.queryItems)
        XCTAssertTrue(wrangler == other)
    }

    func testQueryItemForKey() {
        let wrangler = QueryItemWrangler(items: components.queryItems)
        let item = wrangler.queryItemForKey("num")
        XCTAssert(item != nil)
        XCTAssertEqual(item!.name, "num")
        XCTAssertEqual(item!.value, Optional("42"))
    }

    func testNillingItemRemovesIt() {
        var wrangler = QueryItemWrangler(items: components.queryItems)
        wrangler["num"] = nil
        XCTAssert(wrangler.queryItemForKey("num") == nil)
    }

    func testUnsupportedEdgeCases() {
        let url = NSURL(string: "https://example.com?ids=1&ids=2&ids=3")!
        let components = NSURLComponents(URL: url, resolvingAgainstBaseURL: true)!
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
        let expectedKeys = ["str", "num", "flag", "flag2"]
        XCTAssertEqual(keys, expectedKeys)
        let expectedValues = ["foo bar", "42", "1", "true"]
        XCTAssertEqual(values, expectedValues)
    }
}
